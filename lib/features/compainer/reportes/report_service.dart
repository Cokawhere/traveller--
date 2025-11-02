// lib/services/report_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:traveller/models/report_model.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create report
  Future<String?> createReport({
    required String tripId,
    required String reporterId,
    required String reporterName,
    required String travelerId,
    required String travelerName,
    required String reason,
    required String description,
  }) async {
    try {
      final reportRef = _firestore.collection('reports').doc();

      await reportRef.set({
        'reportId': reportRef.id,
        'tripId': tripId,
        'reporterId': reporterId,
        'reporterName': reporterName,
        'travelerId': travelerId,
        'travelerName': travelerName,
        'reason': reason,
        'description': description,
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'pending',
      });

      return null;
    } catch (e) {
      print('Error creating report: $e');
      return 'Failed to submit report: ${e.toString()}';
    }
  }

  // Get all reports (for admin)
  Future<List<ReportModel>> getAllReports() async {
    try {
      final snapshot = await _firestore
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting reports: $e');
      return [];
    }
  }

  // Get pending reports (for admin)
  Future<List<ReportModel>> getPendingReports() async {
    try {
      final snapshot = await _firestore
          .collection('reports')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting pending reports: $e');
      return [];
    }
  }

  // Update report status (admin)
  Future<String?> updateReportStatus(String reportId, String status) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return null;
    } catch (e) {
      return 'Failed to update report status: ${e.toString()}';
    }
  }

  // Get reports by companion
  Future<List<ReportModel>> getReportsByCompanion(String companionId) async {
    try {
      final snapshot = await _firestore
          .collection('reports')
          .where('reporterId', isEqualTo: companionId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting companion reports: $e');
      return [];
    }
  }
}