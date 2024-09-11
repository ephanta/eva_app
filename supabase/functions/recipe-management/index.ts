import { createClient } from "https://esm.sh/@supabase/supabase-js";
import { decode } from "https://deno.land/x/djwt@v2.8/mod.ts";

// Load environment variables
const supabaseUrl = Deno.env.get("URL_ACCOUNT_D");
const supabaseKey = Deno.env.get("SERVICE_ROLE_KEY_ACCOUNT_D");
const authUrl = Deno.env.get("URL_ACCOUNT_A");
const authKey = Deno.env.get("SERVICE_ROLE_KEY_ACCOUNT_A");

if (!supabaseUrl || !supabaseKey || !authUrl || !authKey) {
  console.error("Missing environment variables");
  Deno.exit(1);
}

// Initialize Supabase clients
const supabase = createClient(supabaseUrl, supabaseKey);
const supabaseAuth = createClient(authUrl, authKey);

// Function to validate token and extract user ID
async function validateAndGetUserId(token) {
  try {
    const [, payload] = decode(token);
    const userId = payload.sub;

    if (!userId) {
      throw new Error("Invalid token: No user ID found.");
    }

    const { data, error } = await supabaseAuth.auth.getUser(token);
    if (error || !data) {
      throw new Error("Invalid token: Unable to validate.");
    }

    return userId;
  } catch (error) {
    console.error("Token validation error:", error);
    throw new Error("Unauthorized: Invalid token.");
  }
}

// Main handler for requests
Deno.serve(async (req) => {
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
    "Access-Control-Allow-Headers": "Authorization, Content-Type",
  };

  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const { method } = req;
    const url = new URL(req.url);

    const authHeader = req.headers.get("Authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json; charset=UTF-8" },
      });
    }

    const token = authHeader.split(" ")[1];
    const userId = await validateAndGetUserId(token);

    let result;
    switch (method) {
      case "GET":
        result = await handleGetRequest(userId);
        break;
      case "POST":
        const postBody = await req.json();
        result = await handlePostRequest(postBody, userId);
        break;
      case "PUT":
        const putBody = await req.json();
        const recipeId = url.searchParams.get("id");
        result = await handlePutRequest(recipeId, putBody, userId);
        break;
      case "DELETE":
        const deleteRecipeId = url.searchParams.get("id");
        result = await handleDeleteRequest(deleteRecipeId, userId);
        break;
      default:
        return new Response(JSON.stringify({ error: "Method not allowed" }), {
          status: 405,
          headers: { ...corsHeaders, "Content-Type": "application/json; charset=UTF-8" },
        });
    }

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json; charset=UTF-8" },
      status: result.status || 200,
    });
  } catch (error) {
    console.error("Request error:", error);
    return new Response(JSON.stringify({ error: error.message || "Internal Server Error" }), {
      headers: { ...corsHeaders, "Content-Type": "application/json; charset=UTF-8" },
      status: error.status || 500,
    });
  }
});

// Handle GET request: Retrieve all recipes for the user
async function handleGetRequest(userId) {
  const { data, error } = await supabase
    .from("Rezepte")
    .select("*")
    .eq("benutzer_id", userId);

  if (error) throw { message: error.message, status: 500 };
  return { data };
}

// Handle POST request: Add a new recipe for the user
async function handlePostRequest(body, userId) {
  const { name, beschreibung, zutaten, kochanweisungen } = body;

  if (!name) {
    throw { message: "Missing required fields: name", status: 400 };
  }

  const { data, error } = await supabase
    .from("Rezepte")
    .insert([{ benutzer_id: userId, name, beschreibung, zutaten, kochanweisungen }])
    .select();

  if (error) throw { message: error.message, status: 500 };
  return { data, status: 201 };
}

// Handle PUT request: Update an existing recipe
async function handlePutRequest(recipeId, body, userId) {
  if (!recipeId) {
    throw { message: "Missing id parameter", status: 400 };
  }

  const { name, beschreibung, zutaten, kochanweisungen } = body;
  const { data, error } = await supabase
    .from("Rezepte")
    .update({ name, beschreibung, zutaten, kochanweisungen })
    .eq("id", recipeId)
    .eq("benutzer_id", userId)
    .select();

  if (error) throw { message: error.message, status: 500 };
  return { data };
}

// Handle DELETE request: Delete a recipe
async function handleDeleteRequest(recipeId, userId) {
  if (!recipeId) {
    throw { message: "Missing id parameter", status: 400 };
  }

  const { error } = await supabase
    .from("Rezepte")
    .delete()
    .eq("id", recipeId)
    .eq("benutzer_id", userId);

  if (error) throw { message: error.message, status: 500 };
  return { message: "Recipe deleted successfully" };
}
