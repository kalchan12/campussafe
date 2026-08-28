/**
 * CampusSafe — Supabase Edge Function: send-notification
 *
 * Sends a Firebase Cloud Messaging (FCM) push notification to one or more
 * users when an emergency incident is created or updated.
 *
 * SECURITY: This function runs server-side only.
 * FCM server credentials NEVER leave this function.
 * The Flutter client NEVER sees the FCM server key.
 *
 * Invocation:
 *   POST https://<project>.supabase.co/functions/v1/send-notification
 *   Headers:
 *     Authorization: Bearer <supabase-service-role-key>
 *   Body:
 *     {
 *       "incident_id": "uuid",
 *       "title": "Emergency Alert",
 *       "body": "Medical emergency reported at Engineering Block",
 *       "recipient_ids": ["uuid", ...],   // optional — omit to send to responders
 *       "data": { "incident_id": "uuid" } // deep-link payload
 *     }
 *
 * Environment variables (set in Supabase dashboard — NOT committed to git):
 *   SUPABASE_URL           — your project URL
 *   SUPABASE_SERVICE_ROLE_KEY — service-role key (server-side only)
 *   FCM_SERVER_KEY         — Firebase Cloud Messaging server key (v1 uses access token)
 *   FCM_PROJECT_ID         — Firebase project ID
 */

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface NotificationPayload {
  incident_id?: string;
  title: string;
  body: string;
  recipient_ids?: string[];
  data?: Record<string, string>;
}

serve(async (req) => {
  // Handle CORS pre-flight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const fcmServerKey = Deno.env.get("FCM_SERVER_KEY");

    if (!fcmServerKey) {
      return new Response(
        JSON.stringify({ error: "FCM_SERVER_KEY not configured" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const payload: NotificationPayload = await req.json();
    const { title, body, incident_id, recipient_ids, data = {} } = payload;

    // Create a service-role Supabase client to bypass RLS
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    // Determine target tokens
    let targetTokens: { token: string; platform: string; user_id: string }[] = [];

    if (recipient_ids && recipient_ids.length > 0) {
      // Send to specific users
      const { data: tokens, error } = await supabase
        .from("notification_tokens")
        .select("token, platform, user_id")
        .in("user_id", recipient_ids)
        .eq("active", true);
      if (error) throw error;
      targetTokens = tokens ?? [];
    } else if (incident_id) {
      // Default: send to all active responders
      const { data: responders, error: respError } = await supabase
        .from("profiles")
        .select("id")
        .in("role", ["medical_responder", "security_responder"]);
      if (respError) throw respError;

      if (responders && responders.length > 0) {
        const responderIds = responders.map((r: { id: string }) => r.id);
        const { data: tokens, error: tokenError } = await supabase
          .from("notification_tokens")
          .select("token, platform, user_id")
          .in("user_id", responderIds)
          .eq("active", true);
        if (tokenError) throw tokenError;
        targetTokens = tokens ?? [];
      }
    }

    if (targetTokens.length === 0) {
      return new Response(
        JSON.stringify({ message: "No active tokens found for recipients" }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Build the notification data payload
    const notificationData: Record<string, string> = {
      ...data,
      ...(incident_id ? { incident_id } : {}),
    };

    // Send to each token via FCM HTTP v1
    const results = await Promise.allSettled(
      targetTokens.map(async ({ token, platform, user_id }) => {
        const fcmBody = {
          message: {
            token,
            notification: { title, body },
            data: notificationData,
            android: {
              priority: "high",
              notification: {
                channel_id: "campussafe_alerts",
                sound: "default",
              },
            },
            apns: {
              payload: {
                aps: {
                  alert: { title, body },
                  sound: "default",
                  badge: 1,
                },
              },
            },
          },
        };

        const fcmProjectId = Deno.env.get("FCM_PROJECT_ID");
        const fcmUrl = fcmProjectId
          ? `https://fcm.googleapis.com/v1/projects/${fcmProjectId}/messages:send`
          : "https://fcm.googleapis.com/fcm/send";

        const response = await fetch(fcmUrl, {
          method: "POST",
          headers: {
            Authorization: `Bearer ${fcmServerKey}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify(fcmBody),
        });

        const responseBody = await response.json();

        // Record the notification attempt in the database
        await supabase.from("notifications").insert({
          recipient_id: user_id,
          incident_id: incident_id ?? null,
          title,
          body,
          data: notificationData,
          delivered: response.ok,
          delivery_error: response.ok ? null : JSON.stringify(responseBody),
        });

        if (!response.ok) {
          throw new Error(`FCM error for token ${token}: ${JSON.stringify(responseBody)}`);
        }

        return { token, success: true };
      })
    );

    const succeeded = results.filter((r) => r.status === "fulfilled").length;
    const failed = results.filter((r) => r.status === "rejected").length;

    return new Response(
      JSON.stringify({
        message: `Notifications sent: ${succeeded} succeeded, ${failed} failed`,
        succeeded,
        failed,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    console.error("send-notification error:", err);
    return new Response(
      JSON.stringify({ error: err instanceof Error ? err.message : String(err) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
