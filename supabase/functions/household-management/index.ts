import { createClient } from "https://esm.sh/@supabase/supabase-js";

// Initialize Supabase Client for Account B (households)
const supabase = createClient(
  Deno.env.get("SUPABASE_URL_ACCOUNT_B") || "",
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY_ACCOUNT_B") || ""
);

Deno.serve(async (req) => {
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
    "Access-Control-Allow-Headers": "Authorization, Content-Type",
  };

  try {
    const { method } = req;
    const url = new URL(req.url);

    // Handle OPTIONS preflight request for CORS
    if (method === "OPTIONS") {
      return new Response(null, {
        headers: corsHeaders,
      });
    }

    // Extract JWT token for auth (Account A)
    const authHeader = req.headers.get("Authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const jwt = authHeader.split(" ")[1];

    switch (method) {
      case "GET": {
        const userId = url.searchParams.get("user_id");
        if (!userId) {
          return new Response(
            JSON.stringify({ error: "Missing user_id parameter" }),
            {
              status: 400,
              headers: { ...corsHeaders, "Content-Type": "application/json" },
            }
          );
        }

        // Fetch the user's households from `Account B`
        const { data, error } = await supabase
          .from("household_member")
          .select("household_id")
          .eq("member_uid", userId);

        if (error) {
          throw new Error("Error fetching households");
        }

        return new Response(JSON.stringify({ data }), {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 200,
        });
      }

      default:
        return new Response("Method not allowed", {
          status: 405,
          headers: corsHeaders,
        });
    }
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500,
      }
    );
  }
});
