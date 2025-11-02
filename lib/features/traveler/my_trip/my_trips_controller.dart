// lib/features/trips/logic/my_trips_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:traveller/features/auth/services/auth.dart';
import 'package:traveller/models/trip_model.dart';
import 'package:traveller/enums/trip_enum.dart';
import 'package:traveller/routes.dart';

import '../creat_trip/trip_service.dart';

class MyTripsController extends GetxController {
  final TripService _tripService = TripService();
  final AuthService _authService = AuthService();

  // Observable variables
  final RxList<TripModel> trips = <TripModel>[].obs;
  final RxList<TripModel> filteredTrips = <TripModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'all'.obs;

  String? userId;

  @override
  void onInit() {
    super.onInit();
    loadUserAndTrips();

    // Listen to search and filter changes
    ever(searchQuery, (_) => _applyFilters());
    ever(selectedFilter, (_) => _applyFilters());
  }

  // Load user data and trips
  Future<void> loadUserAndTrips() async {
    try {
      isLoading.value = true;

      // Get user ID
      final userData = await _authService.getDetailedUserData();
      if (userData == null) {
        Get.snackbar(
          'Error',
          'Failed to load user data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
        );
        return;
      }

      userId = userData['travelerId'] ?? '';

      // Load trips
      await loadTrips();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load trips: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load trips
  Future<void> loadTrips() async {
    if (userId == null) return;

    try {
      final loadedTrips = await _tripService.getTravelerTrips(userId!);
      trips.value = loadedTrips;
      _applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load trips: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    }
  }

  // ✅ Get pending requests count for a trip
  Future<int> getRequestsCount(String tripId) async {
    return await _tripService.getPendingRequestsCount(tripId);
  }

  // Apply filters
  void _applyFilters() {
    List<TripModel> result = List.from(trips);

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((trip) {
        return trip.origin.toLowerCase().contains(query) ||
            trip.destination.toLowerCase().contains(query) ||
            trip.description.toLowerCase().contains(query);
      }).toList();
    }

    // Apply status filter
    switch (selectedFilter.value) {
      case 'active':
        result = result.where((trip) {
          return trip.status == TripStatus.approved ||
              trip.status == TripStatus.inProgress;
        }).toList();
        break;
      case 'completed':
        result = result.where((trip) {
          return trip.status == TripStatus.completed ||
              trip.status == TripStatus.cancelled;
        }).toList();
        break;
      case 'pending':
        result = result.where((trip) {
          return trip.status == TripStatus.pendingApproval ||
              trip.status == TripStatus.rejected;
        }).toList();
        break;
      case 'all':
      default:
        break;
    }

    filteredTrips.value = result;
  }

  // Navigate to create trip
  void navigateToCreateTrip() {
    Get.toNamed(AppRoutes.createTrip)?.then((_) => loadTrips());
  }

  // Edit trip
  void editTrip(TripModel trip) {
    Get.toNamed(AppRoutes.editTrip, arguments: trip)?.then((_) => loadTrips());
  }

  // Delete trip
  Future<void> deleteTrip(String tripId) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final error = await _tripService.deleteTrip(tripId);

      Get.back();

      if (error == null) {
        Get.snackbar(
          'Success',
          'Trip deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[600],
          colorText: Colors.white,
        );

        await loadTrips();
      } else {
        Get.snackbar(
          'Error',
          error,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Failed to delete trip: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    }
  }

  // ✅ View trip details - Navigate to new screen
  void viewTripDetails(TripModel trip) {
    Get.toNamed(AppRoutes.tripDetails, arguments: trip.tripId);
  }

  // Cancel trip
  Future<void> cancelTrip(String tripId) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final error = await _tripService.cancelTrip(tripId);

      Get.back();

      if (error == null) {
        Get.snackbar(
          'Success',
          'Trip cancelled successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[600],
          colorText: Colors.white,
        );

        await loadTrips();
      } else {
        Get.snackbar(
          'Error',
          error,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Failed to cancel trip: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    }
  }

  // Get trips count by status
  Map<String, int> getTripsCount() {
    int active = trips
        .where((trip) =>
            trip.status == TripStatus.approved ||
            trip.status == TripStatus.inProgress)
        .length;

    int completed = trips
        .where((trip) =>
            trip.status == TripStatus.completed ||
            trip.status == TripStatus.cancelled)
        .length;

    int pending = trips
        .where((trip) =>
            trip.status == TripStatus.pendingApproval ||
            trip.status == TripStatus.rejected)
        .length;

    return {
      'all': trips.length,
      'active': active,
      'completed': completed,
      'pending': pending,
    };
  }

}