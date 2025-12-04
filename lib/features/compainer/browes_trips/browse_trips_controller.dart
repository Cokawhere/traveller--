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

    // FIX: use debounce instead of ever
    debounce(searchQuery, (_) => _applyFilters(),
        time: const Duration(milliseconds: 300));
    debounce(selectedFilter, (_) => _applyFilters(),
        time: const Duration(milliseconds: 100));
  }

  Future<void> loadTrips() async {
    try {
      isLoading.value = true;

      // DEBUG: Check all trips in DB
      final allDocs = await _tripService.getAllTripsDebug();

      for (var doc in allDocs) {}

      final trips = await _tripService.getApprovedTrips();

      allTrips.value = trips;
      _applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load trips: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilters() {
    List<TripModel> result = List.from(allTrips);

    final q = searchQuery.value.toLowerCase();

    if (q.isNotEmpty) {
      result = result.where((trip) {
        return trip.origin.toLowerCase().contains(q) ||
            trip.destination.toLowerCase().contains(q) ||
            trip.travelerName.toLowerCase().contains(q);
      }).toList();
    }

    final now = DateTime.now();
    if (selectedFilter.value == 'upcoming') {
      result = result.where((trip) => trip.time.isAfter(now)).toList();
    } else if (selectedFilter.value == 'past') {
      result = result.where((trip) => trip.time.isBefore(now)).toList();
    }

    result.sort((a, b) => a.time.compareTo(b.time));
    filteredTrips.value = result;
  }

  void viewTripDetails(TripModel trip) {
    Get.toNamed('/compainer-trip-details', arguments: trip.tripId);
  }
}
