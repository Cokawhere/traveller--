// lib/features/admin/trips_management/admin_trips_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:traveller/enums/trip_enum.dart';
import 'package:traveller/features/auth/services/auth.dart';
import 'package:traveller/models/trip_model.dart';
import '../admin_service.dart';

class AdminTripsController extends GetxController {
  final AdminService _adminService = AdminService();
  final AuthService _authService = AuthService();

  final RxList<TripModel> allTrips = <TripModel>[].obs;
  final RxList<TripModel> filteredTrips = <TripModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedFilter = 'all'.obs;
  final RxMap<String, int> stats = <String, int>{}.obs;

  String? adminId;

  @override
  void onInit() {
    super.onInit();
    loadAdminData();
    ever(selectedFilter, (_) => _applyFilters());
  }

  Future<void> loadAdminData() async {
    final userData = await _authService.getDetailedUserData();
    adminId = userData?['adminId'];
    await loadTrips();
  }

  Future<void> loadTrips() async {
    try {
      isLoading.value = true;
      final trips = await _adminService.getAllTrips();
      allTrips.value = trips;
      _calculateStats();
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

  void _calculateStats() {
    stats.value = {
      'total': allTrips.length,
      'pending':
          allTrips.where((t) => t.status.toString().contains('pending')).length,
      'approved': allTrips
          .where((t) => t.status.toString().contains('approved'))
          .length,
      'completed': allTrips
          .where((t) => t.status.toString().contains('completed'))
          .length,
      'rejected': allTrips
          .where((t) => t.status.toString().contains('rejected'))
          .length,
    };
  }

  void _applyFilters() {
    if (selectedFilter.value == 'all') {
      filteredTrips.value = List.from(allTrips);
    } else {
      filteredTrips.value = allTrips
          .where((trip) => trip.status.firebaseValue == selectedFilter.value)
          .toList();
    }
  }

  Future<void> approveTrip(String tripId) async {
    if (adminId == null) {
      Get.snackbar(
        'Error',
        'Admin ID not found',
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

      final error = await _adminService.approveTrip(tripId, adminId!);

      Get.back();

      if (error == null) {
        Get.snackbar(
          'Success',
          'Trip approved successfully',
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
        'Failed to approve trip: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    }
  }

  Future<void> rejectTrip(String tripId, {String? reason}) async {
    if (adminId == null) {
      Get.snackbar(
        'Error',
        'Admin ID not found',
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

      final error =
          await _adminService.rejectTrip(tripId, adminId!, reason: reason);

      Get.back();

      if (error == null) {
        Get.snackbar(
          'Success',
          'Trip rejected successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[600],
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
        'Failed to reject trip: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.blue)),
        barrierDismissible: false,
      );

      final error = await _adminService.deleteTrip(tripId);

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

  void viewTripDetails(String tripId) {
    Get.toNamed('/admin-trip-details', arguments: tripId);
  }
}
