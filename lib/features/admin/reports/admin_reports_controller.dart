// lib/features/admin/reports_management/admin_reports_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:traveller/models/report_model.dart';

import '../admin_service.dart';

class AdminReportsController extends GetxController {
  final AdminService _adminService = AdminService();

  final RxList<ReportModel> allReports = <ReportModel>[].obs;
  final RxList<ReportModel> filteredReports = <ReportModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedFilter = 'all'.obs;
  final RxMap<String, int> stats = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadReports();
    ever(selectedFilter, (_) => _applyFilters());
  }

  Future<void> loadReports() async {
    try {
      isLoading.value = true;
      final reports = await _adminService.getAllReports();
      allReports.value = reports;
      _calculateStats();
      _applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load reports: ${e.toString()}',
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
      'total': allReports.length,
      'pending': allReports.where((r) => r.status == 'pending').length,
      'resolved': allReports.where((r) => r.status == 'resolved').length,
      'dismissed': allReports.where((r) => r.status == 'dismissed').length,
    };
  }

  void _applyFilters() {
    if (selectedFilter.value == 'all') {
      filteredReports.value = List.from(allReports);
    } else {
      filteredReports.value = allReports
          .where((report) => report.status == selectedFilter.value)
          .toList();
    }
  }

  Future<void> updateReportStatus(String reportId, String status,
      {String? note}) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.blue)),
        barrierDismissible: false,
      );

      final error =
          await _adminService.updateReportStatus(reportId, status, note: note);

      Get.back();

      if (error == null) {
        Get.snackbar(
          'Success',
          'Report status updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[600],
          colorText: Colors.white,
        );
        await loadReports();
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
        'Failed to update report: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteReport(String reportId) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.blue)),
        barrierDismissible: false,
      );

      final error = await _adminService.deleteReport(reportId);

      Get.back();

      if (error == null) {
        Get.snackbar(
          'Success',
          'Report deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[600],
          colorText: Colors.white,
        );
        await loadReports();
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
        'Failed to delete report: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    }
  }
}
