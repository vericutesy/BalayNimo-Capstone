import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String userId;
  final String name;
  final String email;
  final String role; // Tenant, Landlord, or Admin
  final String verificationStatus;

  const AppUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.verificationStatus,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      userId: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'Tenant',
      verificationStatus: data['verificationStatus'] ?? 'unverified',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'verificationStatus': verificationStatus,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}