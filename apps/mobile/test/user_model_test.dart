import 'package:flutter_test/flutter_test.dart';
import 'package:campussafe_mobile/shared/models/user.dart';

void main() {
  group('User Model & Actors Tests', () {
    test('should parse student user with emergency contacts from JSON', () {
      final now = DateTime.now();
      final json = {
        'id': 'usr-001',
        'email': 'student@astu.edu.et',
        'full_name': 'Abebe Bikila',
        'phone': '0911223344',
        'role': 'student',
        'campus_block': 'Block 4 Room 204',
        'emergency_info': 'Blood: O+',
        'parent_phone': '0922334455',
        'parent_name': 'Bikila Parent',
        'campus_admin_phone': '0920304050',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final user = User.fromJson(json);

      expect(user.id, 'usr-001');
      expect(user.role, UserRole.student);
      expect(user.role.displayName, 'Student');
      expect(user.parentPhone, '0922334455');
      expect(user.parentName, 'Bikila Parent');
      expect(user.campusAdminPhone, '0920304050');
    });

    test('should parse staff user with emergency contacts from JSON', () {
      final now = DateTime.now();
      final json = {
        'id': 'usr-002',
        'email': 'staff@astu.edu.et',
        'full_name': 'Dr. Almaz Kebede',
        'role': 'staff',
        'parent_phone': '0933445566',
        'campus_admin_phone': '0920304050',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final user = User.fromJson(json);

      expect(user.role, UserRole.staff);
      expect(user.role.displayName, 'University Staff');
      expect(user.parentPhone, '0933445566');
      expect(user.campusAdminPhone, '0920304050');
    });

    test('should convert user with emergency contacts to JSON', () {
      final now = DateTime.now();
      final user = User(
        id: 'usr-003',
        email: 'test@astu.edu.et',
        fullName: 'Test User',
        role: UserRole.student,
        parentPhone: '0911002200',
        parentName: 'Parent Guardian',
        campusAdminPhone: '0920304050',
        createdAt: now,
        updatedAt: now,
      );

      final json = user.toJson();

      expect(json['role'], 'student');
      expect(json['parent_phone'], '0911002200');
      expect(json['parent_name'], 'Parent Guardian');
      expect(json['campus_admin_phone'], '0920304050');
    });

    test('default campus_admin_phone fallback is 0920304050 when null in JSON', () {
      final now = DateTime.now();
      final json = {
        'id': 'usr-004',
        'email': 'fallback@astu.edu.et',
        'full_name': 'Fallback User',
        'role': 'student',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final user = User.fromJson(json);
      expect(user.campusAdminPhone, '0920304050');
    });
  });
}
