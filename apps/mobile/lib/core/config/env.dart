import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Env {
  Env._();

  static bool _isInitialized = false;

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
      try {
        await Supabase.initialize(
          url: supabaseUrl,
          // ignore: deprecated_member_use
          anonKey: supabaseAnonKey,
          realtimeClientOptions: const RealtimeClientOptions(
            logLevel: RealtimeLogLevel.info,
          ),
        );
        _isInitialized = true;
      } catch (e) {
        debugPrint('Supabase initialization failed: $e');
        _isInitialized = false;
      }
    }
    // If not configured, the app will run in mock/offline mode.
    // Repositories will guard against unconfigured Supabase clients.
  }

  static bool get isConfigured {
    if (_isInitialized) return true;
    try {
      // Accessing client checks if Supabase instance is initialized
      Supabase.instance.client;
      _isInitialized = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Convenience accessor — throws if Supabase is not initialized.
  static SupabaseClient get supabase => Supabase.instance.client;
}

