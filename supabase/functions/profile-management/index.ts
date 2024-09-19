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
async function validateAndGetUserId(token: string): Promise<string> {
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

    console.log("User validated:", userId); // Logging user validation

    return userId;
  } catch (error) {
    console.error("Token validation error:", error);
    throw new Error("Unauthorized: Invalid token.");
  }
}

// Get profile data (Database D)
async function handleGetRequest(userId: string) {
  try {
    const { data, error } = await supabase
      .from("profil")
      .select("*")
      .eq("user_id", userId)
      .single();

    if (error) {
      console.error("Error fetching profile:", error);
      throw { message: "Error fetching profile", status: 400 };
    }

    // Ensure the dietary notes are properly handled
    if (!data.hinweise_zur_ernaehrung || data.hinweise_zur_ernaehrung.trim() === '') {
      data.hinweise_zur_ernaehrung = 'keine';
    }

    console.log("Profile data fetched successfully for user:", userId);

    return data;
  } catch (error) {
    console.error("Get request failed:", error);
    throw error;
  }
}

// Update profile data (Database D)
async function handlePutRequest(body: any, userId: string) {
  try {
    const { username, avatar_url, hinweise_zur_ernaehrung } = body;

    // Prepare the update object
    const updateData: any = {};

    if (username !== undefined) updateData.username = username;
    if (avatar_url !== undefined) updateData.avatar_url = avatar_url;

    if (hinweise_zur_ernaehrung !== undefined) {
      // Handle hinweise_zur_ernaehrung as a comma-separated string
      updateData.hinweise_zur_ernaehrung = Array.isArray(hinweise_zur_ernaehrung)
        ? hinweise_zur_ernaehrung.join(',')
        : hinweise_zur_ernaehrung || 'keine'; // Default to 'keine' if empty
    }

    updateData.updated_at = new Date().toISOString();

    console.log("Attempting to update profile for user:", userId);
    console.log("Update data:", updateData);

    const { data, error } = await supabase
      .from("profil")
      .update(updateData)
      .eq("user_id", userId)
      .select()
      .single();

    if (error) {
      console.error("Error updating profile:", error);
      throw { message: "Error updating profile", status: 400 };
    }

    console.log("Profile updated successfully for user:", userId);

    return data;
  } catch (error) {
    console.error("Put request failed:", error);
    throw error;
  }
}

// Main function for handling requests
Deno.serve(async (req) => {
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, PUT, OPTIONS",
    "Access-Control-Allow-Headers": "Authorization, Content-Type",
  };

  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const { method } = req;

    // Extract authorization token
    const authHeader = req.headers.get("Authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      console.error("Unauthorized access attempt, missing or invalid authorization header.");
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
      case "PUT":
        const putBody = await req.json();
        result = await handlePutRequest(putBody, userId);
        break;
      default:
        console.error("Method not allowed:", method);
        return new Response(JSON.stringify({ error: "Method not allowed" }), {
          status: 405,
          headers: { ...corsHeaders, "Content-Type": "application/json; charset=UTF-8" },
        });
    }

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    console.error("Request error:", error);
    return new Response(JSON.stringify({ error: error.message || "Internal Server Error" }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: error.status || 500,
    });
  }
});
