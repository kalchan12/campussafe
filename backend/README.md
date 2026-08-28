# CampusSafe — Backend

This directory contains all server-side assets for the CampusSafe project.

## Directory structure

```
backend/
├── migrations/          # PostgreSQL migration files (ordered by timestamp prefix)
│   ├── 20260828000001_initial_schema.sql   # Schema: all tables, triggers, indexes
│   ├── 20260828000002_rls_policies.sql     # Row Level Security for all tables
│   └── 20260828000003_seed_data.sql        # Dev seed: campus blocks, IoT devices
├── functions/
│   └── send-notification/
│       └── index.ts     # Edge Function: server-side FCM push notification delivery
└── seed/                # Additional seed scripts (future use)
```

## Applying Migrations

### Option 1: Supabase CLI (recommended)

```bash
# Link your project (first time only)
supabase link --project-ref your-project-id

# Push all migrations
supabase db push
```

### Option 2: Manual (Supabase SQL editor)

Apply migration files in order in the Supabase SQL editor:
1. `20260828000001_initial_schema.sql`
2. `20260828000002_rls_policies.sql`
3. `20260828000003_seed_data.sql` (development only)

## Edge Functions

### `send-notification`

Sends FCM push notifications to responders when incidents are created/updated.

**Required environment secrets** (set in Supabase dashboard → Project Settings → Edge Functions):
- `SUPABASE_URL` — auto-provided by Supabase
- `SUPABASE_SERVICE_ROLE_KEY` — auto-provided by Supabase
- `FCM_SERVER_KEY` — Firebase Cloud Messaging server key (or OAuth2 access token)
- `FCM_PROJECT_ID` — Firebase project ID

**Deploy:**
```bash
supabase functions deploy send-notification
```

**Invoke from your app or trigger:**
```bash
curl -X POST https://your-project.supabase.co/functions/v1/send-notification \
  -H "Authorization: Bearer $SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d '{"incident_id":"uuid","title":"Emergency","body":"Medical emergency at Engineering Block"}'
```

## Security Rules

- Never put `FCM_SERVER_KEY` or `SUPABASE_SERVICE_ROLE_KEY` in Flutter or Next.js code.
- The Flutter app uses only the **anon** key — RLS enforces all data access.
- All tables have RLS enabled — disable at your own risk.
- The `profiles.handle_new_user()` trigger auto-creates profiles on signup, but also
  call `upsert` in the mobile `AuthRepository.signUp()` to capture campus_block and role.
