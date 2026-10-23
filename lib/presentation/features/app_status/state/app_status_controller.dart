import 'package:get/get.dart';

class AppStatusController extends GetxController {
  // --- Actions & Callbacks ---
  void openSuggestion(String title) {
    Get.snackbar(
      'الانتقال',
      'سيتم الفتح بـ Get.to(() => const Page()) لـ "$title" عند ربط واجهات الفريق',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goToHome() {
    Get.snackbar(
      'الرئيسية',
      'سيتم الانتقال بـ Get.offAll(() => const HomeScreen()) عند تجهيز شاشة الرئيسية',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goToSearch() {
    Get.snackbar(
      'البحث والتصنيفات',
      'سيتم الانتقال بـ Get.to(() => const SearchScreen()) عند تجهيز شاشة البحث',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void resetFilters() {
    Get.snackbar(
      'إعادة ضبط',
      'تم إعادة ضبط فلاتر البحث بنجاح',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void checkConnection() {
    Get.snackbar(
      'فحص الاتصال',
      'جاري فحص حالة الاتصال بالشبكة...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void openOfflineContent() {
    Get.snackbar(
      'المحتوى المحفوظ',
      'فتح قائمة الملاحظات والملخصات المحفوظة أوفلاين...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void retryAction() {
    Get.snackbar(
      'إعادة المحاولة',
      'جاري إعادة تنفيذ العملية...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goToOrders() {
    Get.snackbar(
      'سجل الطلبات',
      'سيتم الانتقال بـ Get.to(() => const OrdersScreen()) عند تجهيز شاشة الطلبات',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
