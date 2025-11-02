// lib/models/report_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String reportId;
  final String tripId;
  final String reporterId; // companion ID
  final String reporterName;
  final String travelerId;
  final String travelerName;
  final String reason;
  final String description;
  final DateTime createdAt;
  final String status; // pending, resolved, dismissed

  ReportModel({
    required this.reportId,
    required this.tripId,
    required this.reporterId,
    required this.reporterName,
    required this.travelerId,
    required this.travelerName,
    required this.reason,
    required this.description,
    required this.createdAt,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'tripId': tripId,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'travelerId': travelerId,
      'travelerName': travelerName,
      'reason': reason,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

 factory ReportModel.fromMap(Map<String, dynamic> map) {
  return ReportModel(
    reportId: map['reportId'] ?? '',
    tripId: map['tripId'] ?? '',
    reporterId: map['reporterId'] ?? '',
    reporterName: map['reporterName'] ?? '',
    travelerId: map['travelerId'] ?? '',
    travelerName: map['travelerName'] ?? '',
    reason: map['reason'] ?? '',
    description: map['description'] ?? '',
    createdAt: map['createdAt'] is Timestamp
        ? (map['createdAt'] as Timestamp).toDate()
        : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    status: map['status'] ?? 'pending',
  );
}

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ReportModel.fromMap(data);
  }
}
