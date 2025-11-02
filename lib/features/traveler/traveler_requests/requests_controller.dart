// lib/features/traveler/traveler_requests/requests_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:traveller/features/auth/services/auth.dart';
import 'package:traveller/features/traveler/creat_trip/trip_service.dart';
import 'package:traveller/routes.dart';

class MyRequestsController extends GetxController {
  final TripService _tripService = TripService();
  final AuthService _authService = AuthService();

  // Observable variables
  final RxList<Map<String, dynamic>> allRequests = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredRequests =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedFilter = 'all'.obs;

  String? userId;

  @override
  void onInit() {
    super.onInit();
    loadUserAndRequests();

    // Listen to filter changes
    ever(selectedFilter, (_) => _applyFilters());
  }

  // Load user data and requests
  Future<void> loadUserAndRequests() async {
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

      // Load requests
      await loadRequests();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load requests: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load all requests for traveler's trips
  Future<void> loadRequests() async {
    if (userId == null) return;

    try {
      // Get all traveler's trips
      final trips = await _tripService.getTravelerTrips(userId!);

      List<Map<String, dynamic>> requestsList = [];

      // Get requests for each trip
      for (var trip in trips) {
        final tripRequests = await _tripService.getTripRequests(trip.tripId);

        // Add trip data to each request
        for (var request in tripRequests) {
          request['tripId'] = trip.tripId;
          request['tripData'] = {
            'origin': trip.origin,
            'destination': trip.destination,
            'time': trip.time.toIso8601String(),
          };
          request['travelerPhone'] = trip.phoneNumber;
          requestsList.add(request);
        }
      }

      // Sort by date (newest first)
      requestsList.sort((a, b) {
        final aDate = DateTime.parse(a['createdAt']);
        final bDate = DateTime.parse(b['createdAt']);
        return bDate.compareTo(aDate);
      });

      allRequests.value = requestsList;
      _applyFilters();
    } catch (e) {
      print('Error loading requests: $e');
    }
  }

  // Apply filters
  void _applyFilters() {
    List<Map<String, dynamic>> result = List.from(allRequests);

    if (selectedFilter.value != 'all') {
      result =
          result.where((req) => req['status'] == selectedFilter.value).toList();
    }

    filteredRequests.value = result;
  }

  // Approve request
  Future<void> approveRequest(String requestId, String tripId, String companionName) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.blue)),
        barrierDismissible: false,
      );

      final error = await _tripService.approveRequest(tripId, requestId);

      Get.back();

      if (error == null) {
        Get.snackbar(
          'Success',
          'Request from $companionName approved!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[600],
          colorText: Colors.white,
        );

        // Reload requests
        await loadRequests();
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
        'Failed to approve request: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    }
  }

  // Reject request
  Future<void> rejectRequest(String requestId, String tripId, String companionName) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.blue)),
        barrierDismissible: false,
      );

      final error = await _tripService.rejectRequest(tripId, requestId);

      Get.back();

      if (error == null) {
        Get.snackbar(
          'Success',
          'Request from $companionName rejected',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[600],
          colorText: Colors.white,
        );

        // Reload requests
        await loadRequests();
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
        'Failed to reject request: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    }
  }

  // View trip details
  void viewTripDetails(String tripId) {
    Get.toNamed(AppRoutes.tripDetails, arguments: tripId);
  }

  // Get request counts
  Map<String, int> getRequestCounts() {
    int pending = allRequests.where((req) => req['status'] == 'pending').length;
    int accepted =
        allRequests.where((req) => req['status'] == 'accepted').length;
    int rejected =
        allRequests.where((req) => req['status'] == 'rejected').length;

    return {
      'all': allRequests.length,
      'pending': pending,
      'accepted': accepted,
      'rejected': rejected,
    };
  }
}