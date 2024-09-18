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
        result = await handleGetRequest(userId, url);
        break;
      case "POST":
        const postBody = await req.json();
        result = await handlePostRequest(postBody, userId);
        break;
      case "PUT":
        const putBody = await req.json();
        const datum = url.searchParams.get("datum");
        result = await handlePutRequest(putBody, datum, userId);
        break;
      case "DELETE":
        const deleteDatum = url.searchParams.get("datum");
        result = await handleDeleteRequest(deleteDatum, userId);
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

// Handle GET request: Retrieve the entire meal plan for a household
async function handleGetRequest(userId, url) {
  const householdId = url.searchParams.get("household_id");
  if (!householdId) {
    throw { message: "Missing household_id parameter", status: 400 };
  }

  const { data, error } = await supabase
    .from("wochenplaner")
    .select("datum, fruehstueck_rezept_id, mittagessen_rezept_id, abendessen_rezept_id")
    .eq("household_id", householdId)
    .order("datum", { ascending: true });

  if (error) throw { message: error.message, status: 500 };

  const planMap = {};
  for (const entry of data) {
    planMap[entry.datum] = {
      fruehstueck_rezept_id: entry.fruehstueck_rezept_id || null,
      mittagessen_rezept_id: entry.mittagessen_rezept_id || null,
      abendessen_rezept_id: entry.abendessen_rezept_id || null,
    };
  }

  return { data: planMap };
}

// Handle POST request: Add or update recipes for a specific day
async function handlePostRequest(body, userId) {
  console.log("Incoming body:", body);
  const { household_id, datum, fruehstueck_rezept_id, mittagessen_rezept_id, abendessen_rezept_id } = body;

  if (!household_id || !datum) {
    throw { message: "Missing required fields: household_id or datum", status: 400 };
  }

  // Insert or update the data while handling null values
  const { data, error } = await supabase
    .from("wochenplaner")
    .upsert({
      household_id,
      datum,
      fruehstueck_rezept_id: fruehstueck_rezept_id || null,
      mittagessen_rezept_id: mittagessen_rezept_id || null,
      abendessen_rezept_id: abendessen_rezept_id || null,
      benutzer_id: userId,
    })
    .select();

  console.log("Supabase response:", data, error);

  if (error) throw { message: error.message, status: 500 };
  return { data, status: 201 };
}

// Handle PUT request: Update meals for a specific day
async function handlePutRequest(body, datum, userId) {
  if (!datum) {
    throw { message: "Missing required parameter: datum", status: 400 };
  }

  const { fruehstueck_rezept_id, mittagessen_rezept_id, abendessen_rezept_id } = body;

  const { data, error } = await supabase
    .from("wochenplaner")
    .update({
      fruehstueck_rezept_id: fruehstueck_rezept_id || null,
      mittagessen_rezept_id: mittagessen_rezept_id || null,
      abendessen_rezept_id: abendessen_rezept_id || null,
    })
    .eq("datum", datum)
    .eq("benutzer_id", userId)
    .select();

  if (error) throw { message: error.message, status: 500 };
  return { data };
}

// Handle DELETE request: Remove a plan for a specific day
async function handleDeleteRequest(datum, userId) {
  if (!datum) {
    throw { message: "Missing required parameter: datum", status: 400 };
  }

  const { error } = await supabase
    .from("wochenplaner")
    .delete()
    .eq("datum", datum)
    .eq("benutzer_id", userId);

  if (error) throw { message: error.message, status: 500 };
  return { message: "Planner entry removed successfully" };
}
