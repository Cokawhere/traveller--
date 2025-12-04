// lib/services/evaluation_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class EvaluationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create evaluation (as subcollection of trip)
  Future<String?> createEvaluation({
    required String tripId,
    required String evaluatorId,
    required String evaluatorName,
    required String evaluatorRole, // 'companion' or 'traveler'
    required String targetId, // ID of person being evaluated
    required String targetName,
    required double rating,
    required String comment,
  }) async {
    try {
      final evaluationRef = _firestore
          .collection('trips')
          .doc(tripId)
          .collection('evaluations')
          .doc();

      await evaluationRef.set({
        'evaluationId': evaluationRef.id,
        'tripId': tripId,
        'evaluatorId': evaluatorId,
        'evaluatorName': evaluatorName,
        'evaluatorRole': evaluatorRole,
        'targetId': targetId,
        'targetName': targetName,
        'rating': rating,
        'comment': comment,
        'createdAt': DateTime.now().toIso8601String(),
      });

      return null;
    } catch (e) {
      return 'Failed to submit evaluation: ${e.toString()}';
    }
  }

  // Get evaluations for a trip
  Future<List<Map<String, dynamic>>> getTripEvaluations(String tripId) async {
    try {
      final snapshot = await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('evaluations')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }

  // Get evaluations received by a user (across all trips)
  Future<List<Map<String, dynamic>>> getUserEvaluations(String userId) async {
    try {
      // Get all trips
      final tripsSnapshot = await _firestore.collection('trips').get();

      List<Map<String, dynamic>> allEvaluations = [];

      // Get evaluations from each trip
      for (var tripDoc in tripsSnapshot.docs) {
        final evaluationsSnapshot = await _firestore
            .collection('trips')
            .doc(tripDoc.id)
            .collection('evaluations')
            .where('targetId', isEqualTo: userId)
            .get();

        for (var evalDoc in evaluationsSnapshot.docs) {
          final data = evalDoc.data();
          data['tripData'] = {
            'tripId': tripDoc.id,
            'origin': tripDoc.data()['origin'],
            'destination': tripDoc.data()['destination'],
          };
          allEvaluations.add(data);
        }
      }

      // Sort by date
      allEvaluations.sort((a, b) {
        final aDate = DateTime.parse(a['createdAt']);
        final bDate = DateTime.parse(b['createdAt']);
        return bDate.compareTo(aDate);
      });

      return allEvaluations;
    } catch (e) {
      return [];
    }
  }

  // Check if user already evaluated a trip
  Future<bool> hasUserEvaluated({
    required String tripId,
    required String evaluatorId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('evaluations')
          .where('evaluatorId', isEqualTo: evaluatorId)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get average rating for a user
  Future<double> getUserAverageRating(String userId) async {
    try {
      final evaluations = await getUserEvaluations(userId);

      if (evaluations.isEmpty) return 0.0;

      double total = 0;
      for (var eval in evaluations) {
        total += (eval['rating'] as num).toDouble();
      }

      return total / evaluations.length;
    } catch (e) {
      return 0.0;
    }
  }

  // Delete evaluation (admin only)
  Future<String?> deleteEvaluation(String tripId, String evaluationId) async {
    try {
      await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('evaluations')
          .doc(evaluationId)
          .delete();

      return null;
    } catch (e) {
      return 'Failed to delete evaluation: ${e.toString()}';
    }
  }
}
