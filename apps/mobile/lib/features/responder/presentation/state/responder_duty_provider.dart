import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/env.dart';
import '../../../auth/presentation/state/auth_notifier.dart';

final responderDutyProvider = StateNotifierProvider<ResponderDutyNotifier, bool>((ref) {
  return ResponderDutyNotifier(ref);
});

class ResponderDutyNotifier extends StateNotifier<bool> {
  final Ref _ref;

  ResponderDutyNotifier(this._ref) : super(true);

  Future<void> toggleDuty(bool onDuty) async {
    state = onDuty;

    final authState = _ref.read(authNotifierProvider);
    final userId = authState.userId;

    if (userId != null && Env.isConfigured) {
      try {
        await Env.supabase
            .from('profiles')
            .update({'is_active': onDuty, 'updated_at': DateTime.now().toIso8601String()})
            .eq('id', userId);
      } catch (_) {
        // Silent fallback for offline or local dev
      }
    }
  }
}
