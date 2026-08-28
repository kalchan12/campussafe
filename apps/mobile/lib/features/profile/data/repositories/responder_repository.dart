import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_error.dart';
import '../../../../shared/models/responder.dart';

final responderRepositoryProvider = Provider<ResponderRepository>((ref) {
  return ResponderRepository(Supabase.instance.client);
});

class ResponderRepository {
  final SupabaseClient _supabase;

  ResponderRepository(this._supabase);

  Future<Result<void>> updateLocation(String userId, double latitude, double longitude) async {
    try {
      final response = await _supabase
          .from('responders')
          .update({
            'latitude': latitude,
            'longitude': longitude,
            'last_location_update': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('user_id', userId)
          .select()
          .maybeSingle();

      if (response == null) {
        // Responder record might not exist yet if they haven't explicitly gone on-duty
        // But we just ignore for background location updates
        return const Right(null);
      }

      return const Right(null);
    } catch (e) {
      return Left(NetworkError(message: 'Failed to update responder location: $e'));
    }
  }

  Future<Result<Responder>> setAvailability(String userId, String type, bool isAvailable) async {
    try {
      final response = await _supabase
          .from('responders')
          .upsert({
            'user_id': userId,
            'type': type,
            'availability': isAvailable ? 'available' : 'offline',
            'last_location_update': DateTime.now().toUtc().toIso8601String(),
          }, onConflict: 'user_id')
          .select()
          .single();

      return Right(Responder.fromJson(response));
    } catch (e) {
      return Left(NetworkError(message: 'Failed to update duty status: $e'));
    }
  }
}
