import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';

/// Provides the Supabase client.
/// Guards against unconfigured state — if Supabase has not been initialised
/// (e.g. during tests or when env vars are missing) this will throw a clear
/// error rather than a confusing Supabase internal exception.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  if (!Env.isConfigured) {
    throw StateError(
      'Supabase is not configured. '
      'Provide SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define.',
    );
  }
  return Env.supabase;
});

/// Exposes the current Supabase auth state as a stream.
final supabaseAuthStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

/// Convenience provider for the currently signed-in user (nullable).
final currentSupabaseUserProvider = Provider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.currentUser;
});
