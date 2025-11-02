// lib/features/trips/logic/create_trip_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:traveller/features/auth/services/auth.dart';
import 'package:traveller/routes.dart';

import 'trip_service.dart';

class CreateTripController extends GetxController {
  final TripService _tripService = TripService();
  final AuthService _authService = AuthService();

  // Form key
  final formKey = GlobalKey<FormState>();

  // Controllers
  final originController = TextEditingController();
  final destinationController = TextEditingController();
  final descriptionController = TextEditingController();
  final availableSeatsController = TextEditingController();
  final pricePerSeatController = TextEditingController();
  final carNameController = TextEditingController();
  final carModelController = TextEditingController();
  final phoneController = TextEditingController();
  final additionalNotesController = TextEditingController();

  // Observable variables
  final Rx<DateTime?> selectedDateTime = Rx<DateTime?>(null);
  final RxBool allowSmoking = false.obs;
  final RxBool allowPets = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingUserData = true.obs;

  // User data
  String? userId;
  String? userName;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  // Load user data
  Future<void> loadUserData() async {
    try {
      isLoadingUserData.value = true;

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

      userId = userData['travelerId'] ?? '';
      userName = userData['name'] ?? '';
      
      // Pre-fill car information
      carNameController.text = userData['carName'] ?? '';
      carModelController.text = userData['carModel'] ?? '';
      phoneController.text = userData['phone'] ?? '';

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load user data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
      Get.back();
    } finally {
      isLoadingUserData.value = false;
    }
  }

  // Select date and time
  Future<void> selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[600]!,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.blue[600]!,
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        selectedDateTime.value = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }
  }

  // Get formatted date time
  String getFormattedDateTime() {
    if (selectedDateTime.value == null) return '';
    return DateFormat('MMM dd, yyyy - hh:mm a').format(selectedDateTime.value!);
  }

  // Validate form
  bool validateForm() {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (selectedDateTime.value == null) {
      Get.snackbar(
        'Validation Error',
        'Please select trip date and time',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[600],
        colorText: Colors.white,
      );
      return false;
    }

    if (selectedDateTime.value!.isBefore(DateTime.now())) {
      Get.snackbar(
        'Validation Error',
        'Trip time must be in the future',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[600],
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  // Create trip
  Future<void> createTrip() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;

      final tripData = {
        'travelerId': userId,
        'travelerName': userName,
        'origin': originController.text.trim(),
        'destination': destinationController.text.trim(),
        'time': selectedDateTime.value!.toIso8601String(),
        'description': descriptionController.text.trim(),
        'availableSeats': int.parse(availableSeatsController.text),
        'pricePerSeat': double.parse(pricePerSeatController.text),
        'carName': carNameController.text.trim(),
        'carModel': carModelController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'allowSmoking': allowSmoking.value,
        'allowPets': allowPets.value,
        'additionalNotes': additionalNotesController.text.trim(),
      };

      final String? error = await _tripService.createTrip(tripData);

      if (error == null) {
        Get.snackbar(
          '',
          'Trip created successfully! Waiting for admin approval.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[600],
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        // Clear form
        clearForm();
        
        // Navigate to My Trips - Fixed Navigation
        Get.offAndToNamed(AppRoutes.myTrips);
      } else {
        Get.snackbar(
          '',
          error,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        '',
        'Failed to create trip: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Clear form
  void clearForm() {
    originController.clear();
    destinationController.clear();
    descriptionController.clear();
    availableSeatsController.clear();
    pricePerSeatController.clear();
    additionalNotesController.clear();
    selectedDateTime.value = null;
    allowSmoking.value = false;
    allowPets.value = false;
  }

  @override
  void onClose() {
    originController.dispose();
    destinationController.dispose();
    descriptionController.dispose();
    availableSeatsController.dispose();
    pricePerSeatController.dispose();
    carNameController.dispose();
    carModelController.dispose();
    phoneController.dispose();
    additionalNotesController.dispose();
    super.onClose();
  }
}