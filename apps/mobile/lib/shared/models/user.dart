import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final UserRole role;
  final String? campusBlock;
  final String? emergencyInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    this.campusBlock,
    this.emergencyInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      role: UserRole.fromString(json['role'] as String),
      campusBlock: json['campus_block'] as String?,
      emergencyInfo: json['emergency_info'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role.value,
      'campus_block': campusBlock,
      'emergency_info': emergencyInfo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    UserRole? role,
    String? campusBlock,
    String? emergencyInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      campusBlock: campusBlock ?? this.campusBlock,
      emergencyInfo: emergencyInfo ?? this.emergencyInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        phone,
        role,
        campusBlock,
        emergencyInfo,
        createdAt,
        updatedAt,
      ];
}

enum UserRole {
  student('student'),
  medicalResponder('medical_responder'),
  securityResponder('security_responder'),
  operator('operator'),
  administrator('administrator'),
  staff('staff');

  const UserRole(this.value);
  final String value;

  factory UserRole.fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.student,
    );
  }

  bool get isResponder =>
      this == UserRole.medicalResponder || this == UserRole.securityResponder;

  bool get isOperator =>
      this == UserRole.operator || this == UserRole.administrator;

  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.medicalResponder:
        return 'Medical Responder';
      case UserRole.securityResponder:
        return 'Security Responder';
      case UserRole.operator:
        return 'Campus Operator';
      case UserRole.administrator:
        return 'Administrator';
      case UserRole.staff:
        return 'University Staff';
    }
  }
}
