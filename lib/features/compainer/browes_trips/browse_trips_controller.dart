// lib/screens/browse_trips_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:traveller/models/trip_model.dart';

import '../../traveler/creat_trip/trip_service.dart';

class BrowseTripsController extends GetxController {
  final TripService _tripService = TripService();

  final RxList<TripModel> allTrips = <TripModel>[].obs;
  final RxList<TripModel> filteredTrips = <TripModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadTrips();

    // Listen to search and filter changes
    ever(searchQuery, (_) => _applyFilters());
    ever(selectedFilter, (_) => _applyFilters());
  }

  // Load all approved trips
  Future<void> loadTrips() async {
    try {
      isLoading.value = true;

      final trips = await _tripService.getApprovedTrips();
      
      allTrips.value = trips;
      _applyFilters();
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

  // Apply filters and search
  void _applyFilters() {
    List<TripModel> result = List.from(allTrips);

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((trip) {
        return trip.origin.toLowerCase().contains(query) ||
            trip.destination.toLowerCase().contains(query) ||
            trip.travelerName.toLowerCase().contains(query);
      }).toList();
    }

    // Apply time filter
    final now = DateTime.now();
    switch (selectedFilter.value) {
      case 'upcoming':
        result = result.where((trip) => trip.time.isAfter(now)).toList();
        break;
      case 'past':
        result = result.where((trip) => trip.time.isBefore(now)).toList();
        break;
      case 'all':
      default:
        // Show all
        break;
    }

    // Sort by time (upcoming first)
    result.sort((a, b) => a.time.compareTo(b.time));

    filteredTrips.value = result;
  }

  // View trip details
  void viewTripDetails(TripModel trip) {
    Get.toNamed(
      '/compainer-trip-details',
      arguments: trip.tripId,
    );
  }

  // Get trips count
  Map<String, int> getTripsCount() {
    final now = DateTime.now();
    int upcoming = allTrips.where((trip) => trip.time.isAfter(now)).length;
    int past = allTrips.where((trip) => trip.time.isBefore(now)).length;

    return {
      'all': allTrips.length,
      'upcoming': upcoming,
      'past': past,
    };
  }
}