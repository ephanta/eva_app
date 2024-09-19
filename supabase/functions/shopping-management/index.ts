import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.1";

// Load environment variables
const supabaseUrl = Deno.env.get("URL_ACCOUNT_D");
const supabaseKey = Deno.env.get("SERVICE_ROLE_KEY_ACCOUNT_D");
const supabaseAuthUrl = Deno.env.get("URL_ACCOUNT_A");
const supabaseAuthKey = Deno.env.get("SERVICE_ROLE_KEY_ACCOUNT_A");

if (!supabaseUrl || !supabaseKey || !supabaseAuthUrl || !supabaseAuthKey) {
  console.error("Missing environment variables");
  Deno.exit(1);
}

// Initialize Supabase clients
const supabase = createClient(supabaseUrl, supabaseKey);
const supabaseAuth = createClient(supabaseAuthUrl, supabaseAuthKey);

// Debug logging function
function debug(...args: any[]) {
  console.log(JSON.stringify(args));
}

// Function to validate token and extract user ID
async function validateAndGetUserId(token: string) {
  try {
    const { data: { user }, error } = await supabaseAuth.auth.getUser(token);
    if (error || !user) {
      console.error("Error in token validation:", error.message);
      throw new Error("Invalid token: Unable to validate.");
    }
    if (!user) {
      throw new Error("Invalid token: No user found.");
    }
    return user.id;
  } catch (error) {
    console.error("Token validation error:", error.message);
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
    console.error("Request error:", error.message);
    return new Response(JSON.stringify({ error: error.message || "Internal Server Error" }), {
      headers: { ...corsHeaders, "Content-Type": "application/json; charset=UTF-8" },
      status: error.status || 500,
    });
  }
});

// Handle GET request: Retrieve shopping list for a household
async function handleGetRequest(url: URL, userId: string) {
  const householdId = url.searchParams.get("household_id");
  if (!householdId) {
    throw { message: "Missing household_id parameter", status: 400 };
  }

  debug("Checking membership", { householdId, userId });

  // Check if the user is a member of the household
  const { data: membership, error: membershipError } = await supabase
    .from("household_member")
    .select("*")
    .eq("household_id", householdId)
    .eq("member_uid", userId)
    .single();

  if (membershipError) {
    console.error("Membership error:", membershipError.message);
    throw { message: "Error checking membership", status: 500 };
  }

  if (!membership) {
    console.log("User is not a member of this household");
    throw { message: "User is not a member of this household", status: 403 };
  }

  debug("Fetching shopping list");

  const { data, error } = await supabase
    .from("shopping_list")
    .select("*")
    .eq("household_id", householdId);

  if (error) {
    console.error("Fetch error:", error.message);
    throw { message: error.message, status: 500 };
  }

  return { data };
}

// Handle POST request: Add new item to the shopping list
async function handlePostRequest(body: any, userId: string) {
  const { household_id, item_name, amount } = body;

  if (!household_id || !item_name) {
    throw { message: "Missing required fields", status: 400 };
  }

  // Check if the household exists
  const { data: household, error: householdError } = await supabase
    .from("households")
    .select("id")
    .eq("id", household_id)
    .single();

  if (householdError) {
    console.error("Household error:", householdError.message);
    throw { message: "Error checking household", status: 500 };
  }

  if (!household) {
    console.log("Household not found");
    throw { message: "Household not found", status: 404 };
  }

  // Check if the user is a member of the household
  const { data: membership, error: membershipError } = await supabase
    .from("household_member")
    .select("*")
    .eq("household_id", household_id)
    .eq("member_uid", userId)
    .single();

  if (membershipError) {
    console.error("Membership error:", membershipError.message);
    throw { message: "Error checking membership", status: 500 };
  }

  if (!membership) {
    console.log("User is not a member of this household");
    throw { message: "User is not a member of this household", status: 403 };
  }

  debug("Inserting item");

  // Insert the new item into the shopping list
  const { data, error } = await supabase
    .from("shopping_list")
    .insert({ household_id, item_name, amount, created_by: userId })
    .select();

  if (error) {
    console.error("Insert error:", error.message);
    throw { message: error.message, status: 500 };
  }

  return { data, status: 201 };
}

// Handle PUT request: Update an item's status (mark as purchased)
async function handlePutRequest(body: any, userId: string) {
  const { id, status } = body;

  if (!id || !status) {
    throw { message: "Missing required fields", status: 400 };
  }

  debug("Updating item", { id, status, userId });

  // Check if the item exists and get its household_id
  const { data: item, error: itemError } = await supabase
    .from("shopping_list")
    .select("household_id")
    .eq("id", id)
    .single();

  if (itemError || !item) {
    console.error("Item error:", itemError.message);
    throw { message: "Item not found", status: 404 };
  }

  // Check if the user is a member of the household
  const { data: membership, error: membershipError } = await supabase
    .from("household_member")
    .select("*")
    .eq("household_id", item.household_id)
    .eq("member_uid", userId)
    .single();

  if (membershipError || !membership) {
    console.error("Membership error:", membershipError.message);
    throw { message: "User is not a member of this household", status: 403 };
  }

  const updateData = {
    status,
    purchased_by: status === 'purchased' ? userId : null,
    purchased_at: status === 'purchased' ? new Date().toISOString() : null,
  };

  const { data, error } = await supabase
    .from("shopping_list")
    .update(updateData)
    .eq("id", id)
    .select();

  if (error) {
    console.error("Update error:", error.message);
    throw { message: error.message, status: 500 };
  }

  return { data };
}

// Handle DELETE request: Remove an item from the shopping list
async function handleDeleteRequest(url: URL, userId: string) {
  const itemId = url.searchParams.get("id");

  if (!itemId) {
    throw { message: "Missing id parameter", status: 400 };
  }

  debug("Deleting item", { itemId, userId });

  // Check if the item exists and get its household_id
  const { data: item, error: itemError } = await supabase
    .from("shopping_list")
    .select("household_id")
    .eq("id", itemId)
    .single();

  if (itemError || !item) {
    console.error("Item error:", itemError.message);
    throw { message: "Item not found", status: 404 };
  }

  // Check if the user is a member of the household
  const { data: membership, error: membershipError } = await supabase
    .from("household_member")
    .select("*")
    .eq("household_id", item.household_id)
    .eq("member_uid", userId)
    .single();

  if (membershipError || !membership) {
    console.error("Membership error:", membershipError.message);
    throw { message: "User is not a member of this household", status: 403 };
  }

  const { error } = await supabase
    .from("shopping_list")
    .delete()
    .eq("id", itemId);

  if (error) {
    console.error("Delete error:", error.message);
    throw { message: error.message, status: 500 };
  }

  return { message: "Item deleted successfully" };
}
