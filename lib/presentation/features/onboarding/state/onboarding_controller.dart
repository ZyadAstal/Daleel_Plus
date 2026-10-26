import 'package:daleel_plus/presentation/features/auth/screens/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daleel_plus/data/repositories/session_preferences.dart';
import 'package:daleel_plus/presentation/features/auth/widgets/auth_widgets.dart';

class OnboardingController extends GetxController {
  void change(VoidCallback action) {
    if (isClosed) return;
    action();
    update();
  }

  final controller = PageController();
  int index = 0;
  bool finishing = false;
  final pages = [
    (
      image: 'services',
      badge: 'خدماتك أقرب مما تتخيّل',
      title: 'كل خدماتك في مكان واحد',
      description: 'تصفّح خدمات التعليم والتدريب، المدرسين المعتمدين، المكتبات والطباعة. كل ما تحتاجه لتسهيل حياتك الجامعية.',
      tags: ['تعليم وتدريب', 'مدرسون معتمدون', 'مكتبات وطباعة'],
    ),
    (
      image: 'opportunities',
      badge: 'فرص تصنع مستقبلك',
      title: 'اكتشف أحدث المنح والفرص',
      description: 'منح دراسية، فرص تدريب، وخصومات طلابية. اكتشف الفرص المناسبة لك وخذ خطوتك التالية بثقة.',
      tags: ['منح دراسية', 'تدريب مهني', 'خصومات طلابية'],
    ),
    (
      image: 'compare',
      badge: 'اختيار أفضل، بثقة أكبر',
      title: 'قارن واختر الأنسب لميزانيتك',
      description: 'قارن الأسعار، اقرأ التقييمات، واستمتع بخيارات تناسب احتياجاتك. احجز الخدمة المناسبة لك بكل سهولة وأمان.',
      tags: ['تقييمات موثوقة', 'أسعار مناسبة', 'حجز آمن'],
    ),
  ];
  Future<void> finish() async {
    if (finishing) return;
    change(() => finishing = true);
    try {
      await SessionPreferences().completeOnboarding();
      if (isClosed) return;
      Get.offAll<void>(() => const AuthGate());
    } catch (_) {
      if (!isClosed) {
        AppSnackbar.show('تعذّر حفظ الإعدادات. حاول مجددًا.');
      }
    } finally {
      if (!isClosed) change(() => finishing = false);
    }
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }
}
