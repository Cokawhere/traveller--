import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:traveller/enums/request_enum.dart';

class RequestModel {
  final String requestId;
  final String companionId;
  final String travelerId;
  final RequestStatus status;
  final DateTime createdAt;

  RequestModel({
    required this.requestId,
    required this.companionId,
    required this.travelerId,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'companionId': companionId,
      'travelerId': travelerId,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RequestModel.fromMap(Map<String, dynamic> map) {
    return RequestModel(
      requestId: map['requestId'] ?? '',
      companionId: map['companionId'] ?? '',
      travelerId: map['travelerId'] ?? '',
      status: _stringToStatus(map['status'] ?? 'pending'),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static RequestStatus _stringToStatus(String statusString) {
    switch (statusString) {
      case 'pending':
        return RequestStatus.pending;
      case 'accepted':
        return RequestStatus.accepted;
      case 'rejected':
        return RequestStatus.rejected;
      case 'completed':
        return RequestStatus.completed;
      default:
        return RequestStatus.pending;
    }
  }

  factory RequestModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RequestModel.fromMap(data);
  }
}