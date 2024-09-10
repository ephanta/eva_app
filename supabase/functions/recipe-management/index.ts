import { createClient } from "https://esm.sh/@supabase/supabase-js";

// Initialize Supabase Client for Account D (recipe management)
const supabase = createClient(
  Deno.env.get("URL_ACCOUNT_D") || "",
  Deno.env.get("SERVICE_ROLE_KEY_ACCOUNT_D") || ""
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

    // Basic auth check (JWT from Account A)
    const authHeader = req.headers.get("Authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json; charset=UTF-8" },
      });
    }

    switch (method) {
      case "POST": {
        const body = await req.json();
        const { user_id, name, beschreibung, zutaten, kochanweisungen } = body;
        if (!user_id || !name) {
          return new Response(
            JSON.stringify({ error: "Missing required fields" }),
            {
              status: 400,
              headers: { ...corsHeaders, "Content-Type": "application/json; charset=UTF-8" },
            }
          );
        }

        const { data, error } = await supabase
          .from("Rezepte")
          .insert([{ benutzer_id: user_id, name, beschreibung, zutaten, kochanweisungen }])
          .select();

        if (error) {
          throw error;
        }

        return new Response(JSON.stringify({ data }), {
          headers: { ...corsHeaders, "Content-Type": "application/json; charset=UTF-8" },
          status: 200,
        });
      }

      case "GET": {
        const userId = url.searchParams.get("user_id");
        if (!userId) {
          return new Response(
            JSON.stringify({ error: "Missing user_id parameter" }),
            {
              status: 400,
              headers: { ...corsHeaders, "Content-Type": "application/json; charset=UTF-8" },
            }
          );
        }

        const { data, error } = await supabase
          .from("Rezepte")
          .select("*")
          .eq("benutzer_id", userId);

        if (error) {
          throw error;
        }

        return new Response(JSON.stringify({ data }), {
          headers: { ...corsHeaders, "Content-Type": "application/json; charset=UTF-8" },
          status: 200,
        });
      }

      case "PUT": {
        const recipeId = url.searchParams.get("id");
        const body = await req.json();

        if (!recipeId) {
          return new Response(
            JSON.stringify({ error: "Missing id parameter" }),
            {
              status: 400,
              headers: { ...corsHeaders, "Content-Type": "application/json; charset=UTF-8" },
            }
          );
        }

        const { name, beschreibung, zutaten, kochanweisungen } = body;
        const { data, error } = await supabase
          .from("Rezepte")
          .update({ name, beschreibung, zutaten, kochanweisungen })
          .eq("id", recipeId)
          .select();

        if (error) {
          throw error;
        }

        return new Response(JSON.stringify({ data }), {
          headers: { ...corsHeaders, "Content-Type": "application/json; charset=UTF-8" },
          status: 200,
        });
      }

      case "DELETE": {
        const recipeId = url.searchParams.get("id");

        if (!recipeId) {
          return new Response(
            JSON.stringify({ error: "Missing id parameter" }),
            {
              status: 400,
              headers: { ...corsHeaders, "Content-Type": "application/json; charset=UTF-8" },
            }
          );
        }

        const { data, error } = await supabase
          .from("Rezepte")
          .delete()
          .eq("id", recipeId);

        if (error) {
          throw error;
        }

        return new Response(
          JSON.stringify({ message: "Recipe deleted successfully" }),
          {
            headers: { ...corsHeaders, "Content-Type": "application/json; charset=UTF-8" },
            status: 200,
          }
        );
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
        headers: { ...corsHeaders, "Content-Type": "application/json; charset=UTF-8" },
        status: 500,
      }
    );
  }
});
