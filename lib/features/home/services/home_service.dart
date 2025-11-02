// lib/features/home/services/home_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:traveller/models/user_model.dart';

class HomeService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user data from users collection
  Future<UserModel?> getCurrentUserData() async {
    try {
      auth.User? user = _auth.currentUser;
      if (user == null) return null;

      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Get detailed user data based on role
  Future<Map<String, dynamic>?> getDetailedUserData() async {
    try {
      auth.User? user = _auth.currentUser;
      if (user == null) return null;

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return null;

      String role = (userDoc.data() as Map<String, dynamic>)['role'];

      DocumentSnapshot detailedDoc;
      switch (role) {
        case 'admin':
          detailedDoc =
              await _firestore.collection('admins').doc(user.uid).get();
          break;
        case 'traveler':
          detailedDoc =
              await _firestore.collection('travelers').doc(user.uid).get();
          break;
        case 'companier':
          detailedDoc =
              await _firestore.collection('companiers').doc(user.uid).get();
          break;
        default:
          return null;
      }

      if (detailedDoc.exists) {
        return detailedDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting detailed user data: $e');
      return null;
    }
  }

  // Get current Firebase user
  auth.User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error logging out: $e');
      rethrow;
    }
  }

  // Check if user is authenticated
  bool isUserAuthenticated() {
    return _auth.currentUser != null;
  }

  // 🆕 Get traveler pending requests count
  Future<int> getTravelerPendingRequestsCount(String travelerId) async {
    try {
      // Get all traveler's trips
      final tripsSnapshot = await _firestore
          .collection('trips')
          .where('travelerId', isEqualTo: travelerId)
          .get();

      int totalPending = 0;

      // Count pending requests for each trip
      for (var tripDoc in tripsSnapshot.docs) {
        final requestsSnapshot = await _firestore
            .collection('trips')
            .doc(tripDoc.id)
            .collection('requests')
            .where('status', isEqualTo: 'pending')
            .get();

        totalPending += requestsSnapshot.docs.length;
      }

      return totalPending;
    } catch (e) {
      print('Error getting traveler pending requests count: $e');
      return 0;
    }
  }

  // 🆕 Get companion accepted requests count
  Future<int> getCompanionAcceptedRequestsCount(String companionId) async {
    try {
      // Get all trips
      final tripsSnapshot = await _firestore
          .collection('trips')
          .where('status', isEqualTo: 'approved')
          .get();

      int acceptedCount = 0;

      // Count accepted requests for this companion
      for (var tripDoc in tripsSnapshot.docs) {
        final requestsSnapshot = await _firestore
            .collection('trips')
            .doc(tripDoc.id)
            .collection('requests')
            .where('companionId', isEqualTo: companionId)
            .where('status', isEqualTo: 'accepted')
            .get();

        acceptedCount += requestsSnapshot.docs.length;
      }

      return acceptedCount;
    } catch (e) {
      print('Error getting companion accepted requests count: $e');
      return 0;
    }
  }

  // Get user statistics (for activity section)
  Future<Map<String, int>> getUserStatistics(String userId, String role) async {
    try {
      Map<String, int> stats = {
        'totalTrips': 0,
        'activeTrips': 0,
        'completedTrips': 0,
        'pendingRequests': 0,
      };

      if (role == 'traveler') {
        final tripsSnapshot = await _firestore
            .collection('trips')
            .where('travelerId', isEqualTo: userId)
            .get();

        stats['totalTrips'] = tripsSnapshot.docs.length;

        for (var doc in tripsSnapshot.docs) {
          var data = doc.data();
          DateTime tripTime =
              DateTime.parse(data['time'] ?? DateTime.now().toIso8601String());
          if (tripTime.isAfter(DateTime.now())) {
            stats['activeTrips'] = stats['activeTrips']! + 1;
          } else {
            stats['completedTrips'] = stats['completedTrips']! + 1;
          }
        }

        final requestsSnapshot = await _firestore
            .collection('requests')
            .where('status', isEqualTo: 'pending')
            .get();

        int pendingCount = 0;
        for (var request in requestsSnapshot.docs) {
          String tripId = request.data()['tripId'];
          var tripDoc =
              await _firestore.collection('trips').doc(tripId).get();
          if (tripDoc.exists &&
              tripDoc.data()?['travelerId'] == userId) {
            pendingCount++;
          }
        }
        stats['pendingRequests'] = pendingCount;
      } else if (role == 'companier') {
        final requestsSnapshot = await _firestore
            .collection('requests')
            .where('companionId', isEqualTo: userId)
            .get();

        stats['totalTrips'] = requestsSnapshot.docs.length;

        for (var doc in requestsSnapshot.docs) {
          var status = doc.data()['status'];
          if (status == 'pending') {
            stats['pendingRequests'] = stats['pendingRequests']! + 1;
          } else if (status == 'accepted') {
            stats['activeTrips'] = stats['activeTrips']! + 1;
          } else if (status == 'completed') {
            stats['completedTrips'] = stats['completedTrips']! + 1;
          }
        }
      }

      return stats;
    } catch (e) {
      print('Error getting user statistics: $e');
      return {
        'totalTrips': 0,
        'activeTrips': 0,
        'completedTrips': 0,
        'pendingRequests': 0,
      };
    }
  }

  // Stream user data changes
  Stream<UserModel?> streamUserData() {
    auth.User? user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore.collection('users').doc(user.uid).snapshots().map(
      (doc) {
        if (doc.exists) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>);
        }
        return null;
      },
    );
  }
}