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

// Supabase clients
const supabase = createClient(supabaseUrl, supabaseKey);
const supabaseAuth = createClient(authUrl, authKey);

// Validate and extract user ID from the token
async function validateAndGetUserId(token: string) {
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

// Main function for serving requests
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
        result = await handleGetRequest(url, userId);
        break;
      case "POST":
        const postBody = await req.json();
        result = await handlePostRequest(postBody, userId);
        break;
      case "PUT":
        const putBody = await req.json();
        const householdId = url.searchParams.get("household_id");
        result = await handlePutRequest(householdId, putBody, userId);
        break;
      case "DELETE":
        const deleteHouseholdId = url.searchParams.get("household_id");
        const action = url.searchParams.get("action");
        result = await handleDeleteRequest(deleteHouseholdId, userId, action);
        break;
      default:
        throw { message: "Method not allowed", status: 405 };
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

// GET Request Handler
async function handleGetRequest(url: URL, userId: string) {
  const householdId = url.searchParams.get("household_id");
  const action = url.searchParams.get("action");

  if (action === "get_role" && householdId) {
    const { data, error } = await supabase
      .from("household_member")
      .select("role")
      .eq("household_id", householdId)
      .eq("member_uid", userId)
      .single();

    if (error) throw { message: error.message, status: 400 };
    return { role: data.role };
  } else if (action === "get_members" && householdId) {
    const { data, error } = await supabase
      .from("household_member")
      .select("member_uid, role")
      .eq("household_id", householdId);

    if (error) throw { message: error.message, status: 400 };
    return { members: data };
  } else {
    const [memberHouseholds, ownerHouseholds] = await Promise.all([
      supabase
        .from("household_member")
        .select("household_id, households(name, color)")  // Fetch related household details
        .eq("member_uid", userId),
      supabase
        .from("households")
        .select("id, name, color")
        .eq("owner_id", userId),
    ]);

    if (memberHouseholds.error) throw { message: memberHouseholds.error.message, status: 400 };
    if (ownerHouseholds.error) throw { message: ownerHouseholds.error.message, status: 400 };

    const allHouseholds = [
      ...memberHouseholds.data.map((row) => ({
        id: row.household_id,
        name: row.households.name,  // Access nested household details
        color: row.households.color,
      })),
      ...ownerHouseholds.data.map((row) => ({
        id: row.id,
        name: row.name,
        color: row.color,
      })),
    ];

    return { data: allHouseholds };
  }
}

// POST Request Handler
async function handlePostRequest(body: any, userId: string) {
  const { name, color, invite_code } = body;

  if (!name) {
    throw { message: "Missing required fields", status: 400 };
  }

  const generatedInviteCode = invite_code || Date.now().toString();

  const { data, error } = await supabase
    .from("households")
    .insert([{ name, color, owner_id: userId, invite_code: generatedInviteCode }])
    .select();

  if (error) throw { message: error.message, status: 400 };

  const householdId = data[0].id;
  const { error: memberError } = await supabase
    .from("household_member")
    .insert([{ household_id: householdId, member_uid: userId, role: "admin" }]);

  if (memberError) throw { message: memberError.message, status: 400 };

  return { data, status: 201 };
}

// PUT Request Handler
async function handlePutRequest(householdId: string | null, body: any, userId: string) {
  const { name, color } = body;

  if (!householdId || !name) {
    throw { message: "Missing household_id or name", status: 400 };
  }

  const { data: roleData, error: roleError } = await supabase
    .from("household_member")
    .select("role")
    .eq("household_id", householdId)
    .eq("member_uid", userId)
    .single();

  if (roleError) throw { message: roleError.message, status: 403 };
  if (roleData.role !== "admin") throw { message: "Unauthorized: User is not an admin of this household", status: 403 };

  const { data, error } = await supabase
    .from("households")
    .update({ name, color })
    .eq("id", householdId)
    .select();

  if (error) throw { message: error.message, status: 400 };

  return { data };
}

// DELETE Request Handler
async function handleDeleteRequest(householdId: string | null, userId: string, action: string | null) {
  if (!householdId) {
    throw { message: "Missing household_id parameter", status: 400 };
  }

  if (action === "leave") {
    const { error } = await supabase
      .from("household_member")
      .delete()
      .eq("household_id", householdId)
      .eq("member_uid", userId);

    if (error) throw { message: error.message, status: 400 };

    return { message: "Successfully left household" };
  } else {
    const { data: roleData, error: roleError } = await supabase
      .from("household_member")
      .select("role")
      .eq("household_id", householdId)
      .eq("member_uid", userId)
      .single();

    if (roleError) throw { message: roleError.message, status: 403 };
    if (roleData.role !== "admin") throw { message: "Unauthorized: User is not an admin of this household", status: 403 };

    const { error } = await supabase
      .from("households")
      .delete()
      .eq("id", householdId);

    if (error) throw { message: error.message, status: 400 };

    return { message: "Household deleted" };
  }
}
