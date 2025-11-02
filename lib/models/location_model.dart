import 'package:cloud_firestore/cloud_firestore.dart';

class LocationShareModel {
  final String locationId;
  final String locationName;
  final DateTime timestamp;

  LocationShareModel({
    required this.locationId,
    required this.locationName,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'locationId': locationId,
      'locationName': locationName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LocationShareModel.fromMap(Map<String, dynamic> map) {
    return LocationShareModel(
      locationId: map['locationId'] ?? '',
      locationName: map['locationName'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  factory LocationShareModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return LocationShareModel.fromMap(data);
  }
}
