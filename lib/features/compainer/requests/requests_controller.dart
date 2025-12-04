// lib/screens/companion_my_requests_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:traveller/features/auth/services/auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../traveler/creat_trip/trip_service.dart';
import '../evaluation/evaluation_service.dart';

class CompanionMyRequestsController extends GetxController {
  final TripService _tripService = TripService();
  final AuthService _authService = AuthService();
  final EvaluationService _evaluationService = EvaluationService();

  // Observable variables
  final RxList<Map<String, dynamic>> allRequests = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredRequests =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedFilter = 'all'.obs;

  String? userId;
  String? userName;

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

      userId = userData['userId'] ?? '';
      userName = userData['name'] ?? '';

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

  // Load all requests for companion
  Future<void> loadRequests() async {
    if (userId == null) return;

    try {
      // 1. Get all requests made by this companion
      final myRequests = await _tripService.getCompanionRequests(userId!);

      List<Map<String, dynamic>> requestsList = [];

      // 2. For each request, fetch the trip details
      for (var request in myRequests) {
        final tripId = request['tripId'];
        final trip = await _tripService.getTripById(tripId);

        if (trip != null) {
          request['tripData'] = {
            'origin': trip.origin,
            'destination': trip.destination,
            'time': trip.time.toIso8601String(),
            'travelerName': trip.travelerName,
            'travelerId': trip.travelerId,
            'phoneNumber': trip.phoneNumber,
          };
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
    } catch (e) {}
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

  // ⭐ Submit evaluation
  Future<void> submitEvaluation({
    required String tripId,
    required String travelerId,
    required String travelerName,
    required double rating,
    required String comment,
  }) async {
    if (userId == null || userName == null) return;

    try {
      // Check if already evaluated
      final hasEvaluated = await _evaluationService.hasUserEvaluated(
        tripId: tripId,
        evaluatorId: userId!,
      );

      if (hasEvaluated) {
        Get.snackbar(
          'Already Evaluated',
          'You have already evaluated this trip',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[600],
          colorText: Colors.white,
        );
        return;
      }

      final error = await _evaluationService.createEvaluation(
        tripId: tripId,
        evaluatorId: userId!,
        evaluatorName: userName!,
        evaluatorRole: 'companion',
        targetId: travelerId,
        targetName: travelerName,
        rating: rating,
        comment: comment,
      );

      if (error == null) {
        Get.snackbar(
          'Success',
          'Thank you for your evaluation!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[600],
          colorText: Colors.white,
        );
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
      Get.snackbar(
        'Error',
        'Failed to submit evaluation: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    }
  }

  // Call traveler
  void callTraveler(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      Get.snackbar(
        'Error',
        'Phone number not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
      return;
    }

    final url = 'tel:$phoneNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Get.snackbar(
        'Error',
        'Could not launch phone dialer',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    }
  }

  // View location
  Future<void> viewLocation(String tripId) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.blue)),
        barrierDismissible: false,
      );

      final location = await _tripService.getTripLocation(tripId);

      Get.back();

      if (location != null) {
        final lat = location['latitude'];
        final lng = location['longitude'];

        if (lat == 0.0 && lng == 0.0) {
          Get.snackbar(
            'Location Not Available',
            'The traveler has stopped sharing their location',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange[600],
            colorText: Colors.white,
          );
          return;
        }

        final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          Get.snackbar(
            'Error',
            'Could not open maps',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[600],
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Location Not Available',
          'The traveler has not shared their location yet',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[600],
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Failed to get location: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    }
  }

  // View trip details
  void viewTripDetails(String tripId) {
    Get.toNamed('/compainer-trip-details', arguments: tripId);
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
