// lib/features/home/home_binding.dart
import 'package:get/get.dart';
import 'package:traveller/features/home/logic/home_controller.dart';
import 'home_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Inject HomeService
    Get.lazyPut<HomeService>(() => HomeService());
    
    // Inject HomeController
    Get.lazyPut<HomeController>(() => HomeController());
  }
}