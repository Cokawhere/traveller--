import 'package:cloud_firestore/cloud_firestore.dart';

class TravelerModel {
  final String travelerId;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String socialMedia;
  final int yearsOfDriving;
  final String carName;
  final String carModel;

  TravelerModel({
    required this.travelerId,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.socialMedia,
    required this.yearsOfDriving,
    required this.carName,
    required this.carModel,
  });

  Map<String, dynamic> toMap() {
    return {
      'travelerId': travelerId,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'socialMedia': socialMedia,
      'yearsOfDriving': yearsOfDriving,
      'carName': carName,
      'carModel': carModel,
    };
  }

  factory TravelerModel.fromMap(Map<String, dynamic> map) {
    return TravelerModel(
      travelerId: map['travelerId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      phone: map['phone'] ?? '',
      socialMedia: map['socialMedia'] ?? '',
      yearsOfDriving: map['yearsOfDriving'] ?? 0,
      carName: map['carName'] ?? '',
      carModel: map['carModel'] ?? '',
    );
  }

  factory TravelerModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TravelerModel.fromMap(data);
  }
}