import 'package:get/get.dart';
import 'package:traveller/features/admin/reports/admin_reports_screen.dart';
import 'package:traveller/features/admin/trips/admin_trip_details_screen.dart' show AdminTripDetailsScreen;
import 'package:traveller/features/admin/trips/admin_trips_screen.dart';
import 'package:traveller/features/admin/users/user_management_screen.dart';
import 'package:traveller/features/auth/screens/login_screen.dart';
import 'package:traveller/features/auth/services/auth.dart';
import 'package:traveller/features/compainer/browes_trips/browse_trips_screen.dart';
import 'package:traveller/features/compainer/reportes/report_binding.dart';
import 'package:traveller/features/traveler/edit_trip/edit_trip_screen.dart';
import 'package:traveller/features/home/services/home_binding.dart';
import 'package:traveller/features/traveler/traveler_requests/requests_screen.dart';
import 'package:traveller/features/traveler/trip_details_traveler/traveler_trip_details_screen.dart';
import 'features/compainer/reportes/create_report_screen.dart';
import 'features/compainer/requests/requests_screen.dart';
import 'features/compainer/tripdetails/companion_trip_details_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/traveler/creat_trip/create_trip_screen.dart';
import 'features/home/screens/home_screenn.dart';
import 'features/traveler/my_trip/my_trips_screen.dart';
import 'features/traveler/share_location/share_location_screen.dart';
import 'features/auth/screens/register_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String myTrips = '/my-trips';
  static const String browseTrips = '/browse-trips';
  static const String tripDetails = '/trip-details';
  static const String shareLocation = '/share-location';
  static const String createTrip = '/create-trip';
  static const String editTrip = '/editTrip';
  static const String travelerRequests = '/traveler-requests';
  static const String compainerRequests = '/my-requests';
  static const String compainertripDetails = '/compainer-trip-details';
  static const String createReport = '/create-report';
  static const String userManagement = '/user-management';
  static const String reportManagement = '/report-management';
  static const String tripManagement = '/trip-management';
  static const String adminTripDetails = '/admin-trip-details';



  static final pages = [
    GetPage(name: initial, page: () => const AuthWrapper()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    GetPage(
      name: home,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: myTrips, page: () => MyTripsScreen()),
    GetPage(name: browseTrips, page: () => const BrowseTripsScreen()),
    GetPage(name: createTrip, page: () => CreateTripScreen()),
    GetPage(name: editTrip, page: () => EditTripScreen()),
    GetPage(
      name: tripDetails,
      page: () => TravelerTripDetailsScreen(),
    ),
    GetPage(name: shareLocation, page: () => const ShareLocationScreen()),
    GetPage(name: travelerRequests, page: () => MyRequestsScreen()),
    GetPage(name: compainerRequests, page: () => CompanionMyRequestsScreen()),
    GetPage(
      name: compainertripDetails,
      page: () => CompanionTripDetailsScreen(),
    ),
    GetPage(
      name: createReport,
      page: () => const CreateReportScreen(),
      binding: ReportBinding(),
    ),
    GetPage(name: userManagement, page: () => UserManagementScreen()),
    GetPage(name: reportManagement, page: () => AdminReportsScreen()),
    GetPage(name: tripManagement, page: () => AdminTripsScreen()),
    GetPage(name: adminTripDetails, page: () => const AdminTripDetailsScreen()),


  ];
}
