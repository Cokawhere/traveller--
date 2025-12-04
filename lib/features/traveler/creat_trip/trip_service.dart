// lib/features/trips/services/trip_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:traveller/models/trip_model.dart';

class TripService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create new trip
  Future<String?> createTrip(Map<String, dynamic> tripData) async {
    try {
      final tripRef = _firestore.collection('trips').doc();
      final tripId = tripRef.id;

      await tripRef.set({
        'tripId': tripId,
        'travelerId': tripData['travelerId'],
        'travelerName': tripData['travelerName'],
        'origin': tripData['origin'],
        'destination': tripData['destination'],
        'time': tripData['time'],
        'description': tripData['description'],
        'availableSeats': tripData['availableSeats'],
        'pricePerSeat': tripData['pricePerSeat'],
        'status': 'pending_approval',
        'adminId': null,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': null,
        'isEdited': false,
        'companionId': null,
        'carName': tripData['carName'],
        'carModel': tripData['carModel'],
        'phoneNumber': tripData['phoneNumber'],
        'allowSmoking': tripData['allowSmoking'],
        'allowPets': tripData['allowPets'],
        'additionalNotes': tripData['additionalNotes'],
        'companions': [],
        'totalSeatsBooked': 0,
        'currentLat': null,
        'currentLng': null,
        'lastLocationUpdate': null,
      });

      return null;
    } catch (e) {
      return 'Failed to create trip: ${e.toString()}';
    }
  }

  // Update trip (for editing)
  Future<String?> updateTrip(
      String tripId, Map<String, dynamic> updateData) async {
    try {
      final tripDoc = await _firestore.collection('trips').doc(tripId).get();

      if (!tripDoc.exists) {
        return 'Trip not found';
      }

      final currentData = tripDoc.data() as Map<String, dynamic>;
      final currentStatus = currentData['status'];

      if (currentStatus != 'approved' && currentStatus != 'rejected') {
        return 'Trip cannot be edited in current status';
      }

      await _firestore.collection('trips').doc(tripId).update({
        ...updateData,
        'updatedAt': DateTime.now().toIso8601String(),
        'isEdited': true,
        'status': 'pending_approval',
        'adminId': null,
      });

      return null;
    } catch (e) {
      return 'Failed to update trip: ${e.toString()}';
    }
  }

  // Get pending requests count for a trip
  Future<int> getPendingRequestsCount(String tripId) async {
    try {
      final snapshot = await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('requests')
          .where('status', isEqualTo: 'pending')
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // Get all requests for a trip
  Future<List<Map<String, dynamic>>> getTripRequests(String tripId) async {
    try {
      final snapshot = await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('requests')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return {
          ...doc.data(),
          'requestId': doc.id,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get all requests made by a companion (using collectionGroup)
  Future<List<Map<String, dynamic>>> getCompanionRequests(
      String companionId) async {
    try {
      final snapshot = await _firestore
          .collectionGroup('requests')
          .where('companionId', isEqualTo: companionId)
          .get();

      return snapshot.docs.map((doc) {
        return {
          ...doc.data(),
          'requestId': doc.id,
          // 'tripId' is already in the document data
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get traveler's trips
  Future<List<TripModel>> getTravelerTrips(String travelerId) async {
    try {
      final snapshot = await _firestore
          .collection('trips')
          .where('travelerId', isEqualTo: travelerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return TripModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get trip by ID
  Future<TripModel?> getTripById(String tripId) async {
    try {
      final doc = await _firestore.collection('trips').doc(tripId).get();

      if (doc.exists) {
        return TripModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get all approved trips (for companions to browse)
  Future<List<TripModel>> getApprovedTrips() async {
    try {
      // DEBUG: Show ALL trips regardless of status
      final snapshot = await _firestore
          .collection('trips')
          // .where('status', isEqualTo: 'approved') // DISABLED FOR DEBUGGING
          .get();

      final now = DateTime.now();

      final trips = snapshot.docs
          .map((doc) => TripModel.fromFirestore(doc))
          // .where((trip) => trip.time.isAfter(now)) // DISABLED FOR DEBUGGING
          .toList();

      // Sort by time (upcoming first)
      trips.sort((a, b) => a.time.compareTo(b.time));

      return trips;
    } catch (e) {
      return [];
    }
  }

  // Get pending trips (for admin approval)
  Future<List<TripModel>> getPendingTrips() async {
    try {
      final snapshot = await _firestore
          .collection('trips')
          .where('status', isEqualTo: 'pending_approval')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  // Create Request (as subcollection)
  Future<String?> createRequest({
    required String tripId,
    required String companionId,
    required String companionName,
    String? message,
  }) async {
    try {
      final requestRef = _firestore
          .collection('trips')
          .doc(tripId)
          .collection('requests')
          .doc();

      await requestRef.set({
        'requestId': requestRef.id,
        'tripId': tripId,
        'companionId': companionId,
        'companionName': companionName,
        'message': message,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });

      return null;
    } catch (e) {
      return 'Failed to create request: ${e.toString()}';
    }
  }

  // Approve Request
  Future<String?> approveRequest(String tripId, String requestId) async {
    try {
      final requestDoc = await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('requests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        return 'Request not found';
      }

      final requestData = requestDoc.data()!;
      final companionId = requestData['companionId'];
      final companionName = requestData['companionName'];

      final tripDoc = await _firestore.collection('trips').doc(tripId).get();
      if (!tripDoc.exists) {
        return 'Trip not found';
      }

      final tripData = tripDoc.data()!;
      final availableSeats = tripData['availableSeats'] as int;
      final companions =
          List<Map<String, dynamic>>.from(tripData['companions'] ?? []);
      final totalBooked = tripData['totalSeatsBooked'] as int? ?? 0;

      if (totalBooked >= availableSeats) {
        return 'No seats available';
      }

      await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('requests')
          .doc(requestId)
          .update({
        'status': 'accepted',
        'acceptedAt': DateTime.now().toIso8601String(),
      });

      companions.add({
        'companionId': companionId,
        'companionName': companionName,
        'joinedAt': DateTime.now().toIso8601String(),
      });

      await _firestore.collection('trips').doc(tripId).update({
        'companions': companions,
        'totalSeatsBooked': totalBooked + 1,
      });

      return null;
    } catch (e) {
      return 'Failed to approve request: ${e.toString()}';
    }
  }

  // Reject Request
  Future<String?> rejectRequest(String tripId, String requestId) async {
    try {
      await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('requests')
          .doc(requestId)
          .update({
        'status': 'rejected',
        'rejectedAt': DateTime.now().toIso8601String(),
      });

      return null;
    } catch (e) {
      return 'Failed to reject request: ${e.toString()}';
    }
  }

  // Create Evaluation (as subcollection)
  Future<String?> createEvaluation({
    required String tripId,
    required String evaluatorId,
    required String evaluatorRole,
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
        'evaluatorRole': evaluatorRole,
        'rating': rating,
        'comment': comment,
        'createdAt': DateTime.now().toIso8601String(),
      });

      return null;
    } catch (e) {
      return 'Failed to create evaluation: ${e.toString()}';
    }
  }

  // Approve trip (admin only)
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

  // Reject trip (admin only)
  Future<String?> rejectTrip(String tripId, String adminId) async {
    try {
      await _firestore.collection('trips').doc(tripId).update({
        'status': 'rejected',
        'adminId': adminId,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return null;
    } catch (e) {
      return 'Failed to reject trip: ${e.toString()}';
    }
  }

  // Cancel trip (traveler)
  Future<String?> cancelTrip(String tripId) async {
    try {
      await _firestore.collection('trips').doc(tripId).update({
        'status': 'cancelled',
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return null;
    } catch (e) {
      return 'Failed to cancel trip: ${e.toString()}';
    }
  }

  // Complete trip
  Future<String?> completeTrip(String tripId) async {
    try {
      await _firestore.collection('trips').doc(tripId).update({
        'status': 'completed',
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return null;
    } catch (e) {
      return 'Failed to complete trip: ${e.toString()}';
    }
  }

  // Update trip status to in progress
  Future<String?> startTrip(String tripId) async {
    try {
      await _firestore.collection('trips').doc(tripId).update({
        'status': 'in_progress',
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return null;
    } catch (e) {
      return 'Failed to start trip: ${e.toString()}';
    }
  }

  // Stream trips by traveler
  Stream<List<TripModel>> streamTravelerTrips(String travelerId) {
    return _firestore
        .collection('trips')
        .where('travelerId', isEqualTo: travelerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList());
  }

  // Stream approved trips
  Stream<List<TripModel>> streamApprovedTrips() {
    return _firestore
        .collection('trips')
        .where('status', isEqualTo: 'approved')
        .where('time', isGreaterThan: DateTime.now().toIso8601String())
        .orderBy('time', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList());
  }

  // Delete trip
  Future<String?> deleteTrip(String tripId) async {
    try {
      await _firestore.collection('trips').doc(tripId).delete();
      return null;
    } catch (e) {
      return 'Failed to delete trip: ${e.toString()}';
    }
  }

  // 📍 Update trip location
  Future<String?> updateTripLocation({
    required String tripId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _firestore.collection('trips').doc(tripId).update({
        'currentLat': latitude,
        'currentLng': longitude,
        'lastLocationUpdate': DateTime.now().toIso8601String(),
      });

      return null;
    } catch (e) {
      return 'Failed to update location: ${e.toString()}';
    }
  }

  // 📍 Get trip location
  Future<Map<String, double>?> getTripLocation(String tripId) async {
    try {
      final doc = await _firestore.collection('trips').doc(tripId).get();

      if (doc.exists) {
        final data = doc.data();
        if (data?['currentLat'] != null && data?['currentLng'] != null) {
          return {
            'latitude': (data!['currentLat'] as num).toDouble(),
            'longitude': (data['currentLng'] as num).toDouble(),
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // DEBUG: Get all trips to check status
  Future<List<TripModel>> getAllTripsDebug() async {
    try {
      final snapshot = await _firestore.collection('trips').get();
      return snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }
}
