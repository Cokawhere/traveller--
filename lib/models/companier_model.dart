import 'package:cloud_firestore/cloud_firestore.dart';

class CompanierModel {
  final String userId;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String socialMedia;

  CompanierModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.socialMedia,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'socialMedia': socialMedia,
    };
  }

  factory CompanierModel.fromMap(Map<String, dynamic> map) {
    return CompanierModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      phone: map['phone'] ?? '',
      socialMedia: map['socialMedia'] ?? '',
    );
  }

  factory CompanierModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CompanierModel.fromMap(data);
  }
}