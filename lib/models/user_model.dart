import 'package:traveller/enums/user_enum.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: _stringToRole(map['role'] ?? 'traveler'),
    );
  }

  static UserRole _stringToRole(String roleString) {
    switch (roleString) {
      case 'admin':
        return UserRole.admin;
      case 'traveler':
        return UserRole.traveler;
      case 'companier':
        return UserRole.companier;
      default:
        return UserRole.traveler;
    }
  }
}