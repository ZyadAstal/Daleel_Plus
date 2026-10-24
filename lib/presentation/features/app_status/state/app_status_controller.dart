import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppStatusController extends GetxController {
  // --- Actions & Callbacks ---
  void openSuggestion(String title, {VoidCallback? onTap}) {
    if (onTap != null) {
      onTap();
      return;
    }
    Get.snackbar(
      'الانتقال',
      'سيتم الفتح بـ Get.to(() => const Page()) لـ "$title" عند ربط واجهات الفريق',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goToHome({VoidCallback? onNavigate}) {
    if (onNavigate != null) {
      onNavigate();
      return;
    }
    Get.snackbar(
      'الرئيسية',
      'سيتم الانتقال بـ Get.offAll(() => const HomeScreen()) عند تجهيز شاشة الرئيسية',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goToSearch({VoidCallback? onNavigate}) {
    if (onNavigate != null) {
      onNavigate();
      return;
    }
    Get.snackbar(
      'البحث والتصنيفات',
      'سيتم الانتقال بـ Get.to(() => const SearchScreen()) عند تجهيز شاشة البحث',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void resetFilters({VoidCallback? onReset}) {
    if (onReset != null) {
      onReset();
      return;
    }
    Get.snackbar(
      'إعادة ضبط',
      'جاري إعادة ضبط فلاتر البحث...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void checkConnection({VoidCallback? onCheck}) {
    if (onCheck != null) {
      onCheck();
      return;
    }
    Get.snackbar(
      'فحص الاتصال',
      'جاري فحص حالة الاتصال بالشبكة...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void openOfflineContent({VoidCallback? onOpen}) {
    if (onOpen != null) {
      onOpen();
      return;
    }
    Get.snackbar(
      'المحتوى المحفوظ',
      'فتح قائمة الملاحظات والملخصات المحفوظة أوفلاين...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void retryAction({VoidCallback? onRetry}) {
    if (onRetry != null) {
      onRetry();
      return;
    }
    Get.snackbar(
      'إعادة المحاولة',
      'جاري إعادة تنفيذ العملية...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goToOrders({VoidCallback? onNavigate}) {
    if (onNavigate != null) {
      onNavigate();
      return;
    }
    Get.snackbar(
      'سجل الطلبات',
      'سيتم الانتقال بـ Get.to(() => const OrdersScreen()) عند تجهيز شاشة الطلبات',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void clearSearch({VoidCallback? onClear}) {
    if (onClear != null) {
      onClear();
      return;
    }
    Get.snackbar(
      'مسح البحث',
      'تم مسح كلمة البحث',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void copyErrorCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    Get.snackbar(
      'نسخ الرمز',
      'تم نسخ رمز الخطأ ($code) بنجاح',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
