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

// Supabase clients for Database D and Database A
const supabase = createClient(supabaseUrl, supabaseKey); // Database D
const supabaseAuth = createClient(authUrl, authKey); // Database A

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

  if (!action) {
    throw { message: "Missing action parameter", status: 400 };
  }

  if (action === "get_households_by_user") {
    // Fetch households where the user is a member or admin
    const { data: households, error: householdError } = await supabase
      .from("household_member")
      .select("household_id")
      .eq("member_uid", userId);

    if (householdError) throw { message: householdError.message, status: 400 };

    const householdIds = households.map((h) => h.household_id);

    // Fetch household details for the relevant household IDs
    const { data: householdDetails, error: detailsError } = await supabase
      .from("households")
      .select("id, name, color")
      .in("id", householdIds);

    if (detailsError) throw { message: detailsError.message, status: 400 };

    return { data: householdDetails };
  } else if (householdId) {
    // Actions that require householdId
    if (action === "get_details") {
      const { data, error } = await supabase
        .from("households")
        .select("id, name, color, invite_code, owner_id")
        .eq("id", householdId)
        .single();

      if (error) throw { message: error.message, status: 400 };

      return { data };
    } else if (action === "get_role") {
      const { data, error } = await supabase
        .from("household_member")
        .select("role")
        .eq("household_id", householdId)
        .eq("member_uid", userId)
        .single();

      if (error) throw { message: error.message, status: 400 };
      return { role: data.role };
    } else if (action === "get_members") {
      const { data: members, error: membersError } = await supabase
        .from("household_member")
        .select("member_uid, role")
        .eq("household_id", householdId);

      if (membersError) throw { message: membersError.message, status: 400 };

      const userIds = members.map((member) => member.member_uid);
      const { data: userData, error: userDataError } = await supabase
        .from("profil")
        .select("user_id, username")
        .in("user_id", userIds);

      if (userDataError) throw { message: "Error fetching user data from profil table", status: 500 };

      const transformedMembers = members.map((member) => {
        const user = userData.find((u) => u.user_id === member.member_uid);
        return {
          member_uid: member.member_uid,
          role: member.role,
          username: user?.username || "Benutzer",
        };
      });

      return { members: transformedMembers };
    } else {
      throw { message: "Invalid action", status: 400 };
    }
  } else {
    throw { message: "Missing household_id parameter for this action", status: 400 };
  }
}

// POST Request Handler
async function handlePostRequest(body, userId) {
  const { name, color, invite_code, action } = body;

  if (action === "join") {
    if (!invite_code) {
      throw { message: "Missing invite code", status: 400 };
    }

    const { data: household, error: householdError } = await supabase
      .from("households")
      .select("id")
      .eq("invite_code", invite_code)
      .single();

    if (householdError) throw { message: "Invalid invite code", status: 400 };

    const { data: existingMember, error: existingMemberError } = await supabase
      .from("household_member")
      .select("household_id")
      .eq("household_id", household.id)
      .eq("member_uid", userId)
      .single();

    if (existingMember) {
      return { message: "User is already a member of this household.", status: 400 };
    }

    const { data, error } = await supabase
      .from("household_member")
      .insert({ household_id: household.id, member_uid: userId, role: "member" })
      .select();

    if (error) throw { message: error.message, status: 400 };

    return { data: { household_id: household.id }, status: 200 };
  } else {
    if (!name || !color) {
      throw { message: "Missing required fields: name or color", status: 400 };
    }

    const generatedInviteCode = invite_code || Date.now().toString();

    const { data, error } = await supabase
      .from("households")
      .insert([{ name, color, owner_id: userId, invite_code: generatedInviteCode }])
      .select();

    if (error) throw { message: error.message, status: 400 };

    const householdId = data[0].id;

    // Use 'admin' role for the household creator
    const creatorRole = 'admin';

    const { error: memberError } = await supabase
      .from("household_member")
      .insert([{ household_id: householdId, member_uid: userId, role: creatorRole }]);

    if (memberError) {
      // If insertion fails, attempt to delete the created household
      await supabase.from("households").delete().eq("id", householdId);
      throw { message: `Failed to add member: ${memberError.message}`, status: 400 };
    }

    return { data, status: 201 };
  }
}

// PUT Request Handler
async function handlePutRequest(householdId, body, userId) {
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
  if (roleData.role !== "admin") throw { message: "Unauthorized", status: 403 };

  const { data, error } = await supabase
    .from("households")
    .update({ name, color })
    .eq("id", householdId)
    .select();

  if (error) throw { message: error.message, status: 400 };

  return { data };
}

// DELETE Request Handler
async function handleDeleteRequest(householdId, userId, action) {
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
    if (roleData.role !== "admin") throw { message: "Unauthorized", status: 403 };

    const { error } = await supabase
      .from("households")
      .delete()
      .eq("id", householdId);

    if (error) throw { message: error.message, status: 400 };

    return { message: "Household deleted" };
  }
}