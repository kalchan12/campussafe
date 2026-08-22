import 'package:flutter_test/flutter_test.dart';
import 'package:campussafe_mobile/core/utils/validators.dart';

void main() {
  group('Validator Tests', () {
    group('Email Validation', () {
      test('should return null for valid email', () {
        expect(Validators.email('test@example.com'), isNull);
      });

      test('should return error for empty email', () {
        expect(Validators.email(''), isNotNull);
      });

      test('should return error for null email', () {
        expect(Validators.email(null), isNotNull);
      });

      test('should return error for invalid email', () {
        expect(Validators.email('invalid-email'), isNotNull);
      });
    });

    group('Password Validation', () {
      test('should return null for valid password', () {
        expect(Validators.password('Password123'), isNull);
      });

      test('should return error for empty password', () {
        expect(Validators.password(''), isNotNull);
      });

      test('should return error for short password', () {
        expect(Validators.password('Pass1'), isNotNull);
      });

      test('should return error for password without uppercase', () {
        expect(Validators.password('password123'), isNotNull);
      });

      test('should return error for password without lowercase', () {
        expect(Validators.password('PASSWORD123'), isNotNull);
      });

      test('should return error for password without number', () {
        expect(Validators.password('Password'), isNotNull);
      });
    });

    group('Required Validation', () {
      test('should return null for non-empty value', () {
        expect(Validators.required('test'), isNull);
      });

      test('should return error for empty value', () {
        expect(Validators.required(''), isNotNull);
      });

      test('should return error for null value', () {
        expect(Validators.required(null), isNotNull);
      });

      test('should return custom field name in error', () {
        final error = Validators.required('', 'Name');
        expect(error, contains('Name'));
      });
    });

    group('Phone Validation', () {
      test('should return null for valid phone', () {
        expect(Validators.phone('+1234567890'), isNull);
      });

      test('should return error for empty phone', () {
        expect(Validators.phone(''), isNotNull);
      });

      test('should return error for invalid phone', () {
        expect(Validators.phone('123'), isNotNull);
      });
    });

    group('Confirm Password Validation', () {
      test('should return null when passwords match', () {
        expect(Validators.confirmPassword('Password123', 'Password123'), isNull);
      });

      test('should return error when passwords do not match', () {
        expect(Validators.confirmPassword('Password123', 'Password456'), isNotNull);
      });

      test('should return error for empty confirm password', () {
        expect(Validators.confirmPassword('', 'Password123'), isNotNull);
      });
    });
  });
}
