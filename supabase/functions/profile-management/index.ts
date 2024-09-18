import { createClient } from "https://esm.sh/@supabase/supabase-js";
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

// Supabase clients for Database D (profiles) and Database A (auth)
const supabase = createClient(supabaseUrl, supabaseKey); // Database D
const supabaseAuth = createClient(authUrl, authKey); // Database A

// Validate and extract user ID from the token (Database A)
async function validateAndGetUserId(token) {
  try {
    const [, payload] = decode(token);
    const userId = payload.sub;

    if (!userId) {
      throw new Error("Invalid token: No user ID found.");
    }

    const { data, error } = await supabaseAuth.auth.getUser(token);
    if (error || !data) {
      throw new Error("Invalid token: Could not validate token.");
    }

    return userId;
  } catch (error) {
    console.error("Token validation error:", error);
    throw new Error("Unauthorized: Invalid token.");
  }
}

// Main function for handling requests
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

    // Extract authorization token
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
        result = await handleGetRequest(url, userId);
        break;
      case "PUT":
        const putBody = await req.json();
        result = await handlePutRequest(putBody, userId);
        break;
      default:
        return new Response(JSON.stringify({ error: "Method not allowed" }), {
          status: 405,
          headers: { ...corsHeaders, "Content-Type": "application/json; charset=UTF-8" },
        });
    }

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json; charset=UTF-8" },
      status: 200,
    });
  } catch (error) {
    console.error("Request error:", error);
    return new Response(JSON.stringify({ error: error.message || "Internal Server Error" }), {
      headers: { ...corsHeaders, "Content-Type": "application/json; charset=UTF-8" },
      status: error.status || 500,
    });
  }
});

// Get profile data (Database D)
async function handleGetRequest(url, userId) {
  const { data, error } = await supabase
    .from("profil")
    .select("*")
    .eq("user_id", userId)
    .single();

  if (error) {
    console.error("Error fetching profile:", error);
    throw { message: "Error fetching profile", status: 400 };
  }

  return data;
}

// Update profile data (Database D)
async function handlePutRequest(body, userId) {
  const { username, avatar_url, bio, allergies } = body;

  // Check if 'allergies' is an array; if not, convert it to one
  const parsedAllergies = Array.isArray(allergies) ? allergies : [];

  const { data, error } = await supabase
    .from("profil")
    .update({ username, avatar_url, bio, allergies: parsedAllergies })
    .eq("user_id", userId)
    .select();

  if (error) throw { message: "Error updating profile", status: 400 };

  return data;
}
