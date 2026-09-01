import 'package:supabase_flutter/supabase_flutter.dart';

class Env {
  Env._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://hiqssgqpjyheehwfaxla.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_AsMrqQuhsyqhI99F-sqheQ_sLVu1kob',
  );

  static Future<void> init() async {
    if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
      );
    }
    // If not configured, the app will run in mock/offline mode.
    // Repositories will guard against unconfigured Supabase clients.
  }

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Convenience accessor — throws if Supabase is not initialized.
  static SupabaseClient get supabase => Supabase.instance.client;
}
