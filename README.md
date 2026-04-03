# Debator

Debator is a Flutter MVP for structured, consent-based debate.

## Supabase Setup

This repo is linked to the Supabase project `ceydojmvpfydljoldskn` (`Debator` in the `Test Projects` organization).

The first backend pass includes:
- local Supabase project scaffolding in [`supabase/config.toml`](/Users/tobbi/Desktop/Debator/supabase/config.toml)
- the initial schema + RLS migration in [`20260403113120_initial_schema.sql`](/Users/tobbi/Desktop/Debator/supabase/migrations/20260403113120_initial_schema.sql)
- seeded debate topics in [`seed.sql`](/Users/tobbi/Desktop/Debator/supabase/seed.sql)
- Flutter-side Supabase bootstrap and environment wiring

## Running With Supabase

The safe default is still `mock` mode. To run the app against Supabase instead, use the local env file:

```bash
flutter run --dart-define-from-file=env/supabase.local.json
```

The tracked example file lives at [`supabase.example.json`](/Users/tobbi/Desktop/Debator/env/supabase.example.json).

Environment modes:
- `mock`: no Supabase required, routes into the product demo
- `staging`: requires Supabase credentials and enables the auth/app shell
- `production`: requires Supabase credentials and fails fast if configuration is missing

## Current Note

The project is linked and the initial SQL has already been applied in Supabase. This branch adds the routed welcome, auth, onboarding, and app-shell foundation plus typed environment config in [`app_config.dart`](/Users/tobbi/Desktop/Debator/lib/app/config/app_config.dart).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
