import 'package:get/get.dart';
import 'package:traveller/enums/user_enum.dart';
import 'package:traveller/models/user_model.dart';
import 'package:traveller/routes.dart';
import '../services/home_service.dart';

class HomeController extends GetxController {
  final HomeService _homeService = HomeService();

  // Observable variables
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxInt pendingRequestsCount = 0.obs; // عدد الطلبات المعلقة للـ Traveler
  final RxInt acceptedRequestsCount =
      0.obs; // عدد الطلبات المقبولة للـ Companion

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  // Load user data
  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await _homeService.getCurrentUserData();

      if (user == null) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      currentUser.value = user;

      // تحميل عدد الطلبات بناءً على نوع المستخدم
      await loadRequestsCount();
    } catch (e) {
      errorMessage.value = 'Failed to load user data: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // تحميل عدد الطلبات
  Future<void> loadRequestsCount() async {
    try {
      if (currentUser.value == null) return;

      if (currentUser.value!.role == UserRole.traveler) {
        // للـ Traveler: عدد الطلبات المعلقة على رحلاته
        final count = await _homeService
            .getTravelerPendingRequestsCount(currentUser.value!.uid);
        pendingRequestsCount.value = count;
      } else if (currentUser.value!.role == UserRole.companier) {
        // للـ Companion: عدد الطلبات المقبولة له
        final count = await _homeService
            .getCompanionAcceptedRequestsCount(currentUser.value!.uid);
        acceptedRequestsCount.value = count;
      }
    } catch (e) {
      print('Error loading requests count: $e');
    }
  }

  // Refresh requests count
  Future<void> refreshRequestsCount() async {
    await loadRequestsCount();
  }

  // Logout
  Future<void> logout() async {
    try {
      await _homeService.logout();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Navigate to profile
  void navigateToProfile() {
    Get.toNamed(AppRoutes.profile);
  }

  // Navigate based on role-specific routes
  void navigateToRoute(String route) {
    try {
      Get.toNamed(route)?.then((_) {
        // تحديث العدد بعد الرجوع من صفحة الطلبات
        refreshRequestsCount();
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Route not found or under development.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Get role gradient colors
  List<int> getRoleGradientColors(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return [0xFFEF5350, 0xFFE53935];
      case UserRole.traveler:
        return [0xFF42A5F5, 0xFF1E88E5];
      case UserRole.companier:
        return [0xFF26A69A, 0xFF00897B];
    }
  }

  // Get role icon code
  int getRoleIconCode(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 0xe047;
      case UserRole.traveler:
        return 0xe071;
      case UserRole.companier:
        return 0xe0af;
    }
  }

  // Get role display name
  String getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.traveler:
        return 'Traveler';
      case UserRole.companier:
        return 'Companier';
    }
  }

  // Get role description
  String getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'System Administrator with full access';
      case UserRole.traveler:
        return 'Customer account for booking services';
      case UserRole.companier:
        return 'Business account for service providers';
    }
  }

  // Get role-specific menu items with badge counts
  List<Map<String, dynamic>> getRoleSpecificMenuItems(UserRole role) {
    List<Map<String, dynamic>> items = [];

    switch (role) {
      case UserRole.admin:
        items = [
          {
            'title': 'Users Management',
            'icon': 0xe7ef,
            'color': 0xFFE53935,
            'route': '/user-management',
            'badge': null,
          },
          {
            'title': 'Reports Management',
            'icon': 0xe037,
            'color': 0xFF8E24AA,
            'route': '/report-management',
            'badge': null,
          },
          {
            'title': 'View All Trips',
            'icon': 0xe6dd,
            'color': 0xFFEF5350,
            'route': '/trip-management',
            'badge': null,
          },
        ];
        break;

      case UserRole.traveler:
        items = [
          {
            'title': 'My Trips',
            'icon': 0xe071,
            'color': 0xFF43A047,
            'route': AppRoutes.myTrips,
            'badge': null,
          },
          {
            'title': 'Create Trip',
            'icon': 0xe055,
            'color': 0xFF00897B,
            'route': AppRoutes.createTrip,
            'badge': null,
          },
          {
            'title': 'Requests',
            'icon': 0xe3ee,
            'color': 0xFF1E88E5,
            'route': AppRoutes.travelerRequests,
            'badge': pendingRequestsCount.value > 0
                ? pendingRequestsCount.value
                : null, // 🔴 Badge للطلبات المعلقة
          },
          {
            'title': 'Share Location',
            'icon': 0xe55c,
            'color': 0xFFE53935,
            'route': AppRoutes.shareLocation,
            'badge': null,
          },
        ];
        break;

      case UserRole.companier:
        items = [
          {
            'title': 'Browse Trips',
            'icon': 0xe8b6,
            'color': 0xFF00897B,
            'route': AppRoutes.browseTrips,
            'badge': null,
          },
          {
            'title': 'My Requests',
            'icon': 0xe3ee,
            'color': 0xFFFB8C00,
            'route': AppRoutes.compainerRequests,
            'badge': acceptedRequestsCount.value > 0
                ? acceptedRequestsCount.value
                : null, // 🔴 Badge للطلبات المقبولة
          },
        ];
        break;
    }

    return items;
  }
}
