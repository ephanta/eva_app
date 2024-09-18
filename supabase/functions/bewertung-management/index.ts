import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.1";
import { decode } from "https://deno.land/x/djwt@v2.8/mod.ts";

// Environment variables
const supabaseUrl = Deno.env.get("URL_ACCOUNT_D");
const supabaseKey = Deno.env.get("SERVICE_ROLE_KEY_ACCOUNT_D");
const authUrl = Deno.env.get("URL_ACCOUNT_A");
const authKey = Deno.env.get("SERVICE_ROLE_KEY_ACCOUNT_A");

if (!supabaseUrl || !supabaseKey || !authUrl || !authKey) {
  console.error("Missing required environment variables");
  Deno.exit(1);
}

// Supabase clients for Database D and Database A
const supabase = createClient(supabaseUrl, supabaseKey); // Database D
const supabaseAuth = createClient(authUrl, authKey); // Database A

// Validate token and extract user ID
async function validateAndGetUserId(token: string) {
  try {
    const { data: { user }, error } = await supabase.auth.getUser(token);
    if (error || !user) {
      throw new Error("Invalid token: Unable to validate.");
    }
    return user.id;
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
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const token = authHeader.split(" ")[1];
    const userId = await validateAndGetUserId(token);

    let result;
    switch (method) {
      case "GET":
        result = await handleGetRequest(url, userId);
        break;
      case "POST":
        const postBody = await req.json();
        result = await handlePostRequest(postBody, userId);
        break;
      case "PUT":
        const putBody = await req.json();
        result = await handlePutRequest(putBody, userId);
        break;
      case "DELETE":
        result = await handleDeleteRequest(url, userId);
        break;
      default:
        throw { message: "Method not allowed", status: 405 };
    }

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: result.status || 200,
    });
  } catch (error) {
    console.error("Request error:", error);
    return new Response(JSON.stringify({ error: error.message || "Internal Server Error" }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: error.status || 500,
    });
  }
});

// Handle GET request: Retrieve ratings
async function handleGetRequest(url: URL, userId: string) {
  const recipeId = url.searchParams.get("recipe_id");
  if (!recipeId) {
    throw { message: "Missing recipe_id parameter", status: 400 };
  }

  const { data, error } = await supabase
    .from("Bewertung")
    .select("*")
    .eq("recipe_id", recipeId);

  if (error) throw { message: error.message, status: 500 };
  return { data };
}

// Handle POST request: Add a new rating
async function handlePostRequest(body: any, userId: string) {
  const { recipe_id, rating, comment } = body;

  if (!recipe_id || !rating) {
    throw { message: "Missing required fields", status: 400 };
  }

  const { data, error } = await supabase
    .from("Bewertung")
    .insert({ user_id: userId, recipe_id, rating, comment })
    .select();

  if (error) throw { message: error.message, status: 500 };
  return { data, status: 201 };
}

// Handle PUT request: Update an existing rating
async function handlePutRequest(body: any, userId: string) {
  const { id, rating, comment } = body;

  if (!id) {
    throw { message: "Missing rating id", status: 400 };
  }

  const { data, error } = await supabase
    .from("Bewertung")
    .update({ rating, comment })
    .eq("id", id)
    .eq("user_id", userId)
    .select();

  if (error) throw { message: error.message, status: 500 };
  return { data };
}

// Handle DELETE request: Remove a rating
async function handleDeleteRequest(url: URL, userId: string) {
  const id = url.searchParams.get("id");

  if (!id) {
    throw { message: "Missing id parameter", status: 400 };
  }

  const { error } = await supabase
    .from("Bewertung")
    .delete()
    .eq("id", id)
    .eq("user_id", userId);

  if (error) throw { message: error.message, status: 500 };
  return { message: "Rating deleted successfully" };
}