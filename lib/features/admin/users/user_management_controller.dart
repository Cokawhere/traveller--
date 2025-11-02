// lib/features/admin/user_management/user_management_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../admin_service.dart';

class UserManagementController extends GetxController {
  final AdminService _adminService = AdminService();

  final RxList<Map<String, dynamic>> allUsers = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredUsers = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedFilter = 'all'.obs;
  final RxMap<String, int> stats = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
    ever(selectedFilter, (_) => _applyFilters());
  }

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      final users = await _adminService.getAllUsers();
      allUsers.value = users;
      _calculateStats();
      _applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load users: ${e.toString()}',
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
      'total': allUsers.length,
      'travelers': allUsers.where((u) => u['role'] == 'traveler').length,
      'companiers': allUsers.where((u) => u['role'] == 'companier').length,
      'admins': allUsers.where((u) => u['role'] == 'admin').length,
    };
  }

  void _applyFilters() {
    if (selectedFilter.value == 'all') {
      filteredUsers.value = List.from(allUsers);
    } else {
      filteredUsers.value = allUsers
          .where((user) => user['role'] == selectedFilter.value)
          .toList();
    }
  }

  Future<void> deleteUser(String userId, String role) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final error = await _adminService.deleteUser(userId, role);

      Get.back();

      if (error == null) {
        Get.snackbar(
          'Success',
          'User deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[600],
          colorText: Colors.white,
        );
        await loadUsers();
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
        'Failed to delete user: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    }
  }
}