import 'package:flutter_test/flutter_test.dart';
import 'package:campussafe_mobile/shared/models/incident.dart';

void main() {
  group('Incident Model Tests', () {
    test('should create incident from JSON', () {
      final json = {
        'id': '1',
        'type': 'medical',
        'status': 'created',
        'priority': 1,
        'reporter_id': 'user1',
        'latitude': 0.0,
        'longitude': 0.0,
        'campus_block': 'Engineering',
        'description': 'Test incident',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final incident = Incident.fromJson(json);

      expect(incident.id, '1');
      expect(incident.type, EmergencyType.medical);
      expect(incident.status, IncidentStatus.created);
      expect(incident.priority, 1);
      expect(incident.reporterId, 'user1');
    });

    test('should convert incident to JSON', () {
      final incident = Incident(
        id: '1',
        type: EmergencyType.medical,
        status: IncidentStatus.created,
        priority: 1,
        reporterId: 'user1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final json = incident.toJson();

      expect(json['id'], '1');
      expect(json['type'], 'medical');
      expect(json['status'], 'created');
      expect(json['priority'], 1);
      expect(json['reporter_id'], 'user1');
    });

    test('emergency type should return correct display name', () {
      expect(EmergencyType.medical.displayName, 'Medical');
      expect(EmergencyType.security.displayName, 'Security');
      expect(EmergencyType.fire.displayName, 'Fire');
      expect(EmergencyType.accident.displayName, 'Accident');
      expect(EmergencyType.other.displayName, 'Other');
    });

    test('incident status should return correct display name', () {
      expect(IncidentStatus.created.displayName, 'Created');
      expect(IncidentStatus.received.displayName, 'Received');
      expect(IncidentStatus.assigned.displayName, 'Assigned');
      expect(IncidentStatus.responding.displayName, 'Responding');
      expect(IncidentStatus.arrived.displayName, 'Arrived');
      expect(IncidentStatus.resolved.displayName, 'Resolved');
    });

    test('incident should be active when not resolved or cancelled', () {
      final incident = Incident(
        id: '1',
        type: EmergencyType.medical,
        status: IncidentStatus.created,
        priority: 1,
        reporterId: 'user1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(incident.isActive, isTrue);
    });

    test('incident should not be active when resolved', () {
      final incident = Incident(
        id: '1',
        type: EmergencyType.medical,
        status: IncidentStatus.resolved,
        priority: 1,
        reporterId: 'user1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(incident.isActive, isFalse);
    });
  });
}
