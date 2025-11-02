// lib/features/admin/services/admin_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:traveller/models/trip_model.dart';
import 'package:traveller/models/report_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============= USER MANAGEMENT =============
  
  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      
      List<Map<String, dynamic>> allUsers = [];

      for (var userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        final role = userData['role'];
        
        // Get detailed info based on role
        Map<String, dynamic> detailedData = {};
        
        switch (role) {
          case 'admin':
            final adminDoc = await _firestore.collection('admins').doc(userDoc.id).get();
            detailedData = adminDoc.exists ? adminDoc.data()! : {};
            break;
          case 'traveler':
            final travelerDoc = await _firestore.collection('travelers').doc(userDoc.id).get();
            detailedData = travelerDoc.exists ? travelerDoc.data()! : {};
            break;
          case 'companier':
            final companierDoc = await _firestore.collection('companiers').doc(userDoc.id).get();
            detailedData = companierDoc.exists ? companierDoc.data()! : {};
            break;
        }
        
        allUsers.add({
          ...userData,
          ...detailedData,
          'uid': userDoc.id,
        });
      }

      return allUsers;
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  // Get users by role
  Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();

      List<Map<String, dynamic>> users = [];

      for (var doc in snapshot.docs) {
        final userData = doc.data();
        
        // Get detailed info
        DocumentSnapshot detailedDoc;
        switch (role) {
          case 'admin':
            detailedDoc = await _firestore.collection('admins').doc(doc.id).get();
            break;
          case 'traveler':
            detailedDoc = await _firestore.collection('travelers').doc(doc.id).get();
            break;
          case 'companier':
            detailedDoc = await _firestore.collection('companiers').doc(doc.id).get();
            break;
          default:
            continue;
        }

        if (detailedDoc.exists) {
          users.add({
            ...userData,
            ...detailedDoc.data() as Map<String, dynamic>,
          });
        }
      }

      return users;
    } catch (e) {
      print('Error getting users by role: $e');
      return [];
    }
  }

  // Delete user
  Future<String?> deleteUser(String userId, String role) async {
    try {
      // Delete from users collection
      await _firestore.collection('users').doc(userId).delete();

      // Delete from role-specific collection
      switch (role) {
        case 'admin':
          await _firestore.collection('admins').doc(userId).delete();
          break;
        case 'traveler':
          await _firestore.collection('travelers').doc(userId).delete();
          break;
        case 'companier':
          await _firestore.collection('companiers').doc(userId).delete();
          break;
      }

      return null;
    } catch (e) {
      return 'Failed to delete user: ${e.toString()}';
    }
  }

  // ============= REPORTS MANAGEMENT =============
  
  // Get all reports
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
      print('Error getting all reports: $e');
      return [];
    }
  }

  // Get reports by status
  Future<List<ReportModel>> getReportsByStatus(String status) async {
    try {
      final snapshot = await _firestore
          .collection('reports')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting reports by status: $e');
      return [];
    }
  }

  // Update report status
  Future<String?> updateReportStatus(String reportId, String status, {String? note}) async {
    try {
      final updateData = {
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (note != null) {
        updateData['adminNote'] = note;
      }

      await _firestore.collection('reports').doc(reportId).update(updateData);

      return null;
    } catch (e) {
      return 'Failed to update report status: ${e.toString()}';
    }
  }

  // Delete report
  Future<String?> deleteReport(String reportId) async {
    try {
      await _firestore.collection('reports').doc(reportId).delete();
      return null;
    } catch (e) {
      return 'Failed to delete report: ${e.toString()}';
    }
  }

  // ============= TRIPS MANAGEMENT =============
  
  // Get all trips
  Future<List<TripModel>> getAllTrips() async {
    try {
      final snapshot = await _firestore
          .collection('trips')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TripModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting all trips: $e');
      return [];
    }
  }

  // Get trips by status
  Future<List<TripModel>> getTripsByStatus(String status) async {
    try {
      final snapshot = await _firestore
          .collection('trips')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TripModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting trips by status: $e');
      return [];
    }
  }

  // Get trip details with all related data
  Future<Map<String, dynamic>?> getTripFullDetails(String tripId) async {
    try {
      // Get trip data
      final tripDoc = await _firestore.collection('trips').doc(tripId).get();
      if (!tripDoc.exists) return null;

      final tripData = tripDoc.data()!;

      // Get requests
      final requestsSnapshot = await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('requests')
          .orderBy('createdAt', descending: true)
          .get();

      final requests = requestsSnapshot.docs
          .map((doc) => {...doc.data(), 'requestId': doc.id})
          .toList();

      // Get evaluations
      final evaluationsSnapshot = await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('evaluations')
          .orderBy('createdAt', descending: true)
          .get();

      final evaluations = evaluationsSnapshot.docs
          .map((doc) => doc.data())
          .toList();

      // Get traveler info
      final travelerDoc = await _firestore
          .collection('travelers')
          .doc(tripData['travelerId'])
          .get();

      final travelerInfo = travelerDoc.exists ? travelerDoc.data() : null;

      return {
        'trip': TripModel.fromFirestore(tripDoc),
        'requests': requests,
        'evaluations': evaluations,
        'travelerInfo': travelerInfo,
        'pendingRequestsCount': requests.where((r) => r['status'] == 'pending').length,
        'acceptedRequestsCount': requests.where((r) => r['status'] == 'accepted').length,
        'rejectedRequestsCount': requests.where((r) => r['status'] == 'rejected').length,
      };
    } catch (e) {
      print('Error getting trip full details: $e');
      return null;
    }
  }

  // Approve trip
  Future<String?> approveTrip(String tripId, String adminId) async {
    try {
      await _firestore.collection('trips').doc(tripId).update({
        'status': 'approved',
        'adminId': adminId,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return null;
    } catch (e) {
      return 'Failed to approve trip: ${e.toString()}';
    }
  }

  // Reject trip
  Future<String?> rejectTrip(String tripId, String adminId, {String? reason}) async {
    try {
      final updateData = {
        'status': 'rejected',
        'adminId': adminId,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (reason != null) {
        updateData['rejectionReason'] = reason;
      }

      await _firestore.collection('trips').doc(tripId).update(updateData);

      return null;
    } catch (e) {
      return 'Failed to reject trip: ${e.toString()}';
    }
  }

  // Delete trip
  Future<String?> deleteTrip(String tripId) async {
    try {
      // Delete trip and all subcollections
      await _firestore.collection('trips').doc(tripId).delete();
      
      return null;
    } catch (e) {
      return 'Failed to delete trip: ${e.toString()}';
    }
  }

  // ============= STATISTICS =============
  
  // Get admin dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Users count
      final usersSnapshot = await _firestore.collection('users').get();
      final travelersCount = usersSnapshot.docs.where((doc) => doc.data()['role'] == 'traveler').length;
      final companiersCount = usersSnapshot.docs.where((doc) => doc.data()['role'] == 'companier').length;
      final adminsCount = usersSnapshot.docs.where((doc) => doc.data()['role'] == 'admin').length;

      // Trips count
      final tripsSnapshot = await _firestore.collection('trips').get();
      final pendingTrips = tripsSnapshot.docs.where((doc) => doc.data()['status'] == 'pending_approval').length;
      final approvedTrips = tripsSnapshot.docs.where((doc) => doc.data()['status'] == 'approved').length;
      final completedTrips = tripsSnapshot.docs.where((doc) => doc.data()['status'] == 'completed').length;

      // Reports count
      final reportsSnapshot = await _firestore.collection('reports').get();
      final pendingReports = reportsSnapshot.docs.where((doc) => doc.data()['status'] == 'pending').length;
      final resolvedReports = reportsSnapshot.docs.where((doc) => doc.data()['status'] == 'resolved').length;

      return {
        'users': {
          'total': usersSnapshot.docs.length,
          'travelers': travelersCount,
          'companiers': companiersCount,
          'admins': adminsCount,
        },
        'trips': {
          'total': tripsSnapshot.docs.length,
          'pending': pendingTrips,
          'approved': approvedTrips,
          'completed': completedTrips,
        },
        'reports': {
          'total': reportsSnapshot.docs.length,
          'pending': pendingReports,
          'resolved': resolvedReports,
        },
      };
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return {};
    }
  }
}