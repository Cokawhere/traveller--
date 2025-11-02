import 'package:get/get.dart';
import 'package:traveller/features/compainer/reportes/report_service.dart';

class ReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportService>(() => ReportService());
  }
}
