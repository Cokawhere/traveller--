import 'package:cloud_firestore/cloud_firestore.dart';

class EvaluationModel {
  final String evaluationId;
  final String companionId;
  final String travelerId;
  final String adminId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  EvaluationModel({
    required this.evaluationId,
    required this.companionId,
    required this.travelerId,
    required this.adminId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'evaluationId': evaluationId,
      'companionId': companionId,
      'travelerId': travelerId,
      'adminId': adminId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EvaluationModel.fromMap(Map<String, dynamic> map) {
    return EvaluationModel(
      evaluationId: map['evaluationId'] ?? '',
      companionId: map['companionId'] ?? '',
      travelerId: map['travelerId'] ?? '',
      adminId: map['adminId'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  factory EvaluationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EvaluationModel.fromMap(data);
  }
}