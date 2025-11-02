// lib/features/trips/logic/edit_trip_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:traveller/models/trip_model.dart';
import 'package:traveller/routes.dart';

import '../creat_trip/trip_service.dart';

class EditTripController extends GetxController {
  final TripModel trip;
  final TripService _tripService = TripService();

  EditTripController({required this.trip});

  // Form key
  final formKey = GlobalKey<FormState>();

  // Controllers
  final originController = TextEditingController();
  final destinationController = TextEditingController();
  final descriptionController = TextEditingController();
  final availableSeatsController = TextEditingController();
  final pricePerSeatController = TextEditingController();
  final phoneController = TextEditingController();
  final additionalNotesController = TextEditingController();

  // Observable variables
  final Rx<DateTime?> selectedDateTime = Rx<DateTime?>(null);
  final RxBool allowSmoking = false.obs;
  final RxBool allowPets = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingUserData = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTripData();
  }

  // Load trip data into form
  void _loadTripData() {
    originController.text = trip.origin;
    destinationController.text = trip.destination;
    descriptionController.text = trip.description;
    availableSeatsController.text = trip.availableSeats.toString();
    pricePerSeatController.text = trip.pricePerSeat.toString();
    phoneController.text = trip.phoneNumber;
    additionalNotesController.text = trip.additionalNotes ?? '';
    selectedDateTime.value = trip.time;
    allowSmoking.value = trip.allowSmoking;
    allowPets.value = trip.allowPets;
  }

  // Select date and time
  Future<void> selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime.value ?? DateTime.now().add(const Duration(days: 1)),
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
        initialTime: TimeOfDay.fromDateTime(selectedDateTime.value ?? DateTime.now()),
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
        '',
        'Please select trip date and time',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[600],
        colorText: Colors.white,
      );
      return false;
    }

    if (selectedDateTime.value!.isBefore(DateTime.now())) {
      Get.snackbar(
        '',
        'Trip time must be in the future',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[600],
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  // Update trip
  Future<void> updateTrip() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;

      final updateData = {
        'origin': originController.text.trim(),
        'destination': destinationController.text.trim(),
        'time': selectedDateTime.value!.toIso8601String(),
        'description': descriptionController.text.trim(),
        'availableSeats': int.parse(availableSeatsController.text),
        'pricePerSeat': double.parse(pricePerSeatController.text),
        'phoneNumber': phoneController.text.trim(),
        'allowSmoking': allowSmoking.value,
        'allowPets': allowPets.value,
        'additionalNotes': additionalNotesController.text.trim(),
      };

      final String? error = await _tripService.updateTrip(trip.tripId, updateData);

      if (error == null) {
        Get.snackbar(
          '',
          'Trip updated successfully! Sent for admin re-approval.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[600],
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        
        // Navigate back
        Get.offAndToNamed(AppRoutes.myTrips);
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
        'Failed to update trip: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    originController.dispose();
    destinationController.dispose();
    descriptionController.dispose();
    availableSeatsController.dispose();
    pricePerSeatController.dispose();
    phoneController.dispose();
    additionalNotesController.dispose();
    super.onClose();
  }
}