import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daleel_plus/data/repositories/auth_repository.dart';
import 'package:daleel_plus/presentation/features/auth/widgets/auth_widgets.dart';

class ForgotPasswordController extends GetxController {
  void change(VoidCallback action) {
    if (isClosed) return;
    action();
    update();
  }

  final form = GlobalKey<FormState>();
  final contact = TextEditingController();
  bool phone = false;
  bool busy = false;
  String country = '+970';

  @override
  void onClose() {
    contact.dispose();
    super.onClose();
  }

  void selectMethod(bool phone) {
    if (busy) return;
    if (phone) {
      AppSnackbar.show(
        'استعادة كلمة المرور متاحة حاليًا عبر البريد المرتبط بالحساب.',
      );
      return;
    }
    if (this.phone == phone) return;
    Get.focusScope?.unfocus();
    form.currentState?.reset();
    contact.clear();
    change(() => this.phone = phone);
  }

  Future<void> submit() async {
    if (busy || !form.currentState!.validate()) return;
    Get.focusScope?.unfocus();
    change(() => busy = true);
    try {
      await Get.find<AuthRepository>().resetPassword(contact.text);
      if (!isClosed) {
        AppSnackbar.show(
          'إذا كان البريد مرتبطًا بحساب، سيصلك رابط إعادة تعيين كلمة المرور. تحقق من الرسائل غير المرغوبة أيضًا.',
        );
      }
    } catch (e) {
      if (!isClosed) {
        AppSnackbar.show(authErrorMessage(e));
      }
    } finally {
      if (!isClosed) change(() => busy = false);
    }
  }
}
