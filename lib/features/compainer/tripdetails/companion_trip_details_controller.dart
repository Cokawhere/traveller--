// lib/screens/companion_trip_details_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:traveller/features/auth/services/auth.dart';
import 'package:traveller/models/trip_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../traveler/creat_trip/trip_service.dart';

class CompanionTripDetailsController extends GetxController {
  final String tripId;
  final TripService _tripService = TripService();
  final AuthService _authService = AuthService();

  CompanionTripDetailsController({required this.tripId});

  // Observable variables
  final Rx<TripModel?> trip = Rx<TripModel?>(null);
  final Rx<Map<String, dynamic>?> myRequest = Rx<Map<String, dynamic>?>(null);
  final RxBool isLoading = true.obs;

  String? companionId;
  String? companionName;

  @override
  void onInit() {
    super.onInit();
    loadUserAndTripData();
  }

  // Load user and trip data
  Future<void> loadUserAndTripData() async {
    try {
      isLoading.value = true;

      // Get user data
      final userData = await _authService.getDetailedUserData();
      if (userData == null) {
        Get.snackbar(
          'Error',
          'Failed to load user data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
        );
        Get.back();
        return;
      }

      companionId = userData['userId'] ?? '';
      companionName = userData['name'] ?? '';

      // Load trip details
      await loadTripDetails();

      // Check if user already sent a request
      await checkExistingRequest();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load trip details
  Future<void> loadTripDetails() async {
    try {
      final tripData = await _tripService.getTripById(tripId);

      if (tripData == null) {
        Get.snackbar(
          'Error',
          'Trip not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
        );
        Get.back();
        return;
      }

      trip.value = tripData;
    } catch (e) {
      print('Error loading trip: $e');
    }
  }

  // Check if companion already sent a request
  Future<void> checkExistingRequest() async {
    if (companionId == null) return;

    try {
      final requests = await _tripService.getTripRequests(tripId);

      // Find request from this companion
      final existingRequest = requests.firstWhereOrNull(
        (req) => req['companionId'] == companionId,
      );

      myRequest.value = existingRequest;
    } catch (e) {
      print('Error checking request: $e');
    }
  }

  // Send join request
  Future<void> sendRequest(String message) async {
    if (companionId == null || companionName == null) {
      Get.snackbar(
        'Error',
        'User data not loaded',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
      return;
    }

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.blue)),
        barrierDismissible: false,
      );

      final error = await _tripService.createRequest(
        tripId: tripId,
        companionId: companionId!,
        companionName: companionName!,
        message: message.isNotEmpty ? message : null,
      );

      Get.back(); // Close loading dialog

      if (error == null) {
        Get.snackbar(
          'Success',
          'Request sent successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[600],
          colorText: Colors.white,
        );

        // Reload to show request status
        await checkExistingRequest();
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
        'Failed to send request: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    }
  }

  // Call traveler (only if request accepted)
  Future<void> callTraveler() async {
    if (trip.value == null) return;

    final phoneNumber = trip.value!.phoneNumber;

    try {
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
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to make call: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    }
  }

  // View location (only if request accepted)
  Future<void> viewLocation() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.blue)),
        barrierDismissible: false,
      );

      final location = await _tripService.getTripLocation(tripId);

      Get.back(); // Close loading dialog

      if (location != null) {
        final lat = location['latitude'];
        final lng = location['longitude'];

        // Check if location is valid (not 0,0)
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

        // Open Google Maps
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
}
