import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.0.0";

const mpesaApiUrl = "https://sandbox.safaricom.co.ke/mpesa/c2b/v1/simulate";

serve(async (req) => {
  try {
    const { userId } = await req.json();

    // 1. Create a Supabase client
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    // 2. Get the user's M-Pesa credentials from Supabase Vault
    //    (This is a placeholder, actual implementation will depend on how you store secrets)
    const { data: secretData, error: secretError } = await supabase
      .from("user_secrets")
      .select("mpesa_credentials")
      .eq("user_id", userId)
      .single();

    if (secretError) {
      throw new Error(`Failed to retrieve M-Pesa credentials: ${secretError.message}`);
    }

    const mpesaCredentials = secretData.mpesa_credentials;

    // 3. Fetch transactions from M-Pesa API (this is a placeholder)
    //    In a real scenario, you would make a POST request to the M-Pesa API
    //    with the necessary authentication headers and body.
    const mpesaResponse = await fetch(mpesaApiUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${mpesaCredentials.access_token}`,
      },
      body: JSON.stringify({
        // ... M-Pesa API request body
      }),
    });

    if (!mpesaResponse.ok) {
      throw new Error(`M-Pesa API request failed: ${mpesaResponse.statusText}`);
    }

    const transactions = await mpesaResponse.json();

    // 4. Insert new transactions into the Supabase database
    const { error: insertError } = await supabase.from("transactions").insert(
      transactions.map((tx: any) => ({
        description: tx.description,
        amount: tx.amount,
        date: tx.date,
        user_id: userId,
        category_id: "uncategorized", // Default category
      }))
    );

    if (insertError) {
      throw new Error(`Failed to insert transactions: ${insertError.message}`);
    }

    return new Response(JSON.stringify({ success: true }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
