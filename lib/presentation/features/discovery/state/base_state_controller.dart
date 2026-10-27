import 'package:get/get.dart';

class BaseStateController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> safeExecute(Future<void> Function() action) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await action();
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'تنبيه',
        'حدث خطأ غير متوقع: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    errorMessage.value = '';
  }
}
