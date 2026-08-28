# CampusSafe — Campus Safety & Emergency Response System

CampusSafe is a campus-wide emergency communication, incident coordination, and safety monitoring platform connecting students, staff, responders, university operators, and IoT devices.

## Architecture

```
                         CAMPUSSAFE
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
   Flutter Mobile       Web Dashboard          ESP32 Nodes
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              │
                              ▼
                         SUPABASE
                              │
              ┌───────────────┼────────────────┐
              │               │                │
              ▼               ▼                ▼
          PostgreSQL         Auth            Realtime
              │
              ▼
       Notification Logic
              │
              ▼
             FCM (Firebase Cloud Messaging)
              │
    ┌─────────┼─────────┐
    ▼         ▼         ▼
 Doctor    Security  Relevant
 Device    Device    Responders
```

**Supabase** is the backend and single source of truth.  
**FCM** is the push notification delivery mechanism only.

---

## Technology Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter / Dart |
| Web Dashboard | Next.js / React / TypeScript |
| Backend | Supabase |
| Database | PostgreSQL (via Supabase) |
| Authentication | Supabase Auth |
| Realtime | Supabase Realtime |
| Push Notifications | Firebase Cloud Messaging (FCM) |
| IoT | ESP32 / C++ |
| Location | Mobile GPS (geolocator) |

---

## Repository Structure

```
campussafe/
├── apps/
│   ├── mobile/          # Flutter mobile application
│   └── dashboard/       # Next.js web dashboard
├── backend/
│   ├── migrations/      # Supabase PostgreSQL migrations (apply in order)
│   ├── functions/       # Supabase Edge Functions
│   │   └── send-notification/   # Server-side FCM delivery
│   └── seed/            # Development seed data
├── iot/                 # ESP32 firmware (future)
├── packages/shared/     # Shared types and contracts
├── docs/                # Architecture docs and ADRs
├── .env.example         # Environment variable template
├── PROJECT.md
├── ARCHITECTURE.md
├── AGENTS.md
├── PLAN.md
└── README.md
```

---

## Quick Start

### Prerequisites

- Flutter 3.x (see `apps/mobile/pubspec.yaml` for version constraints)
- Node.js 18+ (for dashboard)
- [Supabase CLI](https://supabase.com/docs/guides/cli) (for local dev / migrations)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) (for Firebase setup)

### 1. Clone and configure environment

```bash
cp .env.example .env
# Fill in SUPABASE_URL, SUPABASE_ANON_KEY, etc.
```

### 2. Apply database migrations

Using the Supabase CLI (with your project linked):

```bash
supabase db push
# or apply each file manually in order:
# backend/migrations/20260828000001_initial_schema.sql
# backend/migrations/20260828000002_rls_policies.sql
# backend/migrations/20260828000003_seed_data.sql  (dev only)
```

### 3. Configure Firebase (FCM)

Follow the [FlutterFire setup guide](https://firebase.flutter.dev/docs/overview):

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure (from apps/mobile/)
flutterfire configure
```

This generates:
- `apps/mobile/android/app/google-services.json`
- `apps/mobile/ios/Runner/GoogleService-Info.plist`
- `apps/mobile/lib/firebase_options.dart`

> These files are gitignored. Each developer/CI environment must generate their own.

### 4. Run the mobile app

```bash
cd apps/mobile
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

> **Dev mode:** If `SUPABASE_URL` is omitted, the app runs with mock data — existing UI works exactly as before.

### 5. Run the web dashboard

```bash
cd apps/dashboard
cp ../../.env.example .env.local
# Edit .env.local with NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY
npm install
npm run dev
```

### 6. Deploy Edge Functions

```bash
supabase functions deploy send-notification
# Set secrets in Supabase dashboard — NEVER commit them:
supabase secrets set FCM_SERVER_KEY=... FCM_PROJECT_ID=...
```

---

## Security

- All database access is enforced by Row Level Security (RLS).
- FCM server credentials live **only** in Supabase Edge Function secrets.
- The Flutter app uses the Supabase **anon** key only (safe to expose; RLS enforces boundaries).
- Never commit `.env`, `google-services.json`, `GoogleService-Info.plist`, or service account keys.

---

## Development Conventions

See [AGENTS.md](AGENTS.md) for full coding rules.

Key rules:
- Database changes require a migration file in `backend/migrations/`.
- UI widgets must not directly contain backend queries — use repositories.
- FCM server credentials must never appear in Flutter code.
- Supabase service-role key must never appear in Flutter code.
