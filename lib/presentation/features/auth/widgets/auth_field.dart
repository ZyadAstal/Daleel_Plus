import 'package:daleel_plus/presentation/shared/theme/app_text_styles.dart';
import 'package:daleel_plus/presentation/shared/constants/app_sizes.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:daleel_plus/presentation/shared/constants/app_colors.dart';

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.password = false,
    this.required = true,
    this.keyboard,
    this.controller,
    this.validator,
    this.autofill,
    this.trailing,
    this.leading,
    this.readOnly = false,
    this.inputFormatters,
  });
  final String label;
  final String hint;
  final IconData icon;
  final bool password;
  final bool required;
  final TextInputType? keyboard;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Iterable<String>? autofill;
  final Widget? trailing;
  final Widget? leading;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  @override
  Widget build(BuildContext context) =>
      GetBuilder<PasswordVisibilityController>(
        init: PasswordVisibilityController(),
        global: false,
        dispose: (state) => state.controller?.onDelete(),
        builder: (c) => _render(context, c),
      );

  Widget _render(BuildContext context, PasswordVisibilityController c) =>
      Padding(
        padding: EdgeInsets.only(bottom: AppSizes.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (required)
                  Text(
                    ' *',
                    style: AppTextStyles.body.copyWith(color: AppColors.error),
                  ),
              ],
            ),
            SizedBox(height: AppSizes.space8),
            TextFormField(
              readOnly: readOnly,
              controller: controller,
              keyboardType: keyboard,
              inputFormatters: inputFormatters,
              textDirection:
                  keyboard == TextInputType.emailAddress ||
                      keyboard == TextInputType.url ||
                      keyboard == TextInputType.phone
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              autofillHints: autofill,
              obscureText: password && !c.visible,
              enableSuggestions: !password,
              autocorrect: !password,
              style: AppTextStyles.label,
              validator:
                  validator ??
                  (value) => required && (value == null || value.trim().isEmpty)
                      ? 'يرجى إدخال هذا الحقل'
                      : null,
              decoration: InputDecoration(
                hintText: hint,
                hintTextDirection:
                    keyboard == TextInputType.emailAddress ||
                        keyboard == TextInputType.url ||
                        keyboard == TextInputType.phone
                    ? TextDirection.ltr
                    : TextDirection.rtl,
                prefixIcon:
                    leading ??
                    Icon(
                      icon,
                      size: AppSizes.space4 * 5,
                      color: AppColors.textSecondary,
                    ),
                suffixIcon: password
                    ? IconButton(
                        onPressed: c.toggle,
                        tooltip: c.visible
                            ? 'إخفاء كلمة المرور'
                            : 'إظهار كلمة المرور',
                        icon: Icon(
                          c.visible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: AppSizes.space4 * 5,
                          color: AppColors.textSecondary,
                        ),
                      )
                    : trailing,
              ),
            ),
          ],
        ),
      );
}

class PasswordVisibilityController extends GetxController {
  bool visible = false;
  void toggle() {
    visible = !visible;
    update();
  }
}
