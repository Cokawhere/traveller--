import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  final String adminId;
  final String name;
  final String email;
  final String password; // Hashed in real app
  final String phone;

  AdminModel({
    required this.adminId,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'adminId': adminId,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
    };
  }

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      adminId: map['adminId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      phone: map['phone'] ?? '',
    );
  }

  factory AdminModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AdminModel.fromMap(data);
  }
}