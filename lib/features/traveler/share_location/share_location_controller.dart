// lib/screens/share_location_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:traveller/enums/trip_enum.dart';
import 'package:traveller/features/auth/services/auth.dart';
import 'package:traveller/features/traveler/creat_trip/trip_service.dart';
import 'package:traveller/models/trip_model.dart';

class ShareLocationController extends GetxController {
  final TripService _tripService = TripService();
  final AuthService _authService = AuthService();

  final RxList<TripModel> activeTrips = <TripModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSharingLocation = false.obs;

  String? userId;

  @override
  void onInit() {
    super.onInit();
    loadActiveTrips();
  }

  // Load active trips
  Future<void> loadActiveTrips() async {
    try {
      isLoading.value = true;

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

      // Get all trips
      final allTrips = await _tripService.getTravelerTrips(userId!);

      // Filter only approved trips
      activeTrips.value = allTrips
          .where((trip) => trip.status == TripStatus.approved)
          .toList();
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

  // Check and request location permission
  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar(
        'Location Service Disabled',
        'Please enable location services',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[600],
        colorText: Colors.white,
      );
      return false;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'Permission Denied',
          'Location permission is required',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Permission Denied',
        'Please enable location permission in settings',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  // Get current location
  Future<Position?> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get location: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
      return null;
    }
  }

  // Share location
  Future<void> shareLocation(String tripId) async {
    try {
      isSharingLocation.value = true;

      // Check permission
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        isSharingLocation.value = false;
        return;
      }

      // Get current location
      final position = await _getCurrentLocation();
      if (position == null) {
        isSharingLocation.value = false;
        return;
      }

      // Update location in Firebase
      final error = await _tripService.updateTripLocation(
        tripId: tripId,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (error == null) {
        Get.snackbar(
          '',
          'Location shared successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[600],
          colorText: Colors.white,
        );

        // Reload trips to show updated location
        await loadActiveTrips();
        
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
        'Failed to share location: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    } finally {
      isSharingLocation.value = false;
    }
  }

  // Update location (refresh)
  Future<void> updateLocation(String tripId) async {
    await shareLocation(tripId);
  }

  // Stop sharing location
  Future<void> stopSharing(String tripId) async {
    try {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.location_off, color: Colors.orange[600]),
              const SizedBox(width: 8),
              const Text('Stop Sharing'),
            ],
          ),
          content: const Text('Are you sure you want to stop sharing your location?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.back();
                
                final error = await _tripService.updateTripLocation(
                  tripId: tripId,
                  latitude: 0.0,
                  longitude: 0.0,
                );

                if (error == null) {
                  Get.snackbar(
                    '',
                    'Location sharing stopped',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.orange[600],
                    colorText: Colors.white,
                  );

                  await loadActiveTrips();
                } else {
                  Get.snackbar(
                    'Error',
                    error,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red[600],
                    colorText: Colors.white,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Stop'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to stop sharing: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    }
  }
}