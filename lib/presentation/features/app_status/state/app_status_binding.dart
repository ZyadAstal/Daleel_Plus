import 'package:get/get.dart';
import 'app_status_controller.dart';

class AppStatusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppStatusController>(() => AppStatusController());
  }
}
