import 'package:daleel_plus/presentation/shared/widgets/widgets.dart';
import 'package:daleel_plus/presentation/shared/theme/app_text_styles.dart';
import 'package:daleel_plus/presentation/shared/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daleel_plus/data/models/registration_options.dart';
import 'package:daleel_plus/presentation/shared/constants/app_colors.dart';
import 'package:daleel_plus/presentation/features/auth/widgets/auth_widgets.dart';
import 'package:daleel_plus/presentation/features/auth/state/forgot_password_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<ForgotPasswordController>(
    init: ForgotPasswordController(),
    global: false,
    dispose: (state) => state.controller?.onDelete(),
    builder: (c) => _render(context, c),
  );

  Widget _render(BuildContext context, ForgotPasswordController c) =>
      MobilePage(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            AppSizes.space24,
            AppSizes.space4 * 8,
            AppSizes.space24,
            AppSizes.space4 * 8,
          ),
          child: Form(
            key: c.form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: SizedBox(
                    width: AppSizes.space4 * 24,
                    height: AppSizes.space4 * 24,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: AppSizes.space4 * 22,
                          height: AppSizes.space4 * 22,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubdued,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: AppSizes.space4 * 15,
                              height: AppSizes.space4 * 15,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.08235294117647059,
                                    ),
                                    blurRadius: AppSizes.space8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.lock_reset_rounded,
                                color: AppColors.primary,
                                size: AppSizes.space4 * 8,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          bottom: AppSizes.space8,
                          child: Container(
                            padding: EdgeInsets.all(AppSizes.space8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSubdued,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.verified_user_outlined,
                              size: AppSizes.space16,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.space4 * 5),
                Text(
                  'استعادة كلمة المرور',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading1.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSizes.space8),
                Text(
                  'أدخل بريدك الإلكتروني المسجل\nوسنرسل لك رابطًا آمنًا لإعادة تعيين كلمة المرور.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSizes.space4 * 7),
                Container(
                  padding: EdgeInsets.all(AppSizes.space4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubdued,
                    borderRadius: BorderRadius.circular(AppSizes.space4 * 8),
                  ),
                  child: Row(
                    children: [
                      _methodTab(
                        context,
                        c,
                        'رقم الجوال',
                        Icons.phone_android_outlined,
                        true,
                      ),
                      _methodTab(
                        context,
                        c,
                        'البريد الإلكتروني',
                        Icons.alternate_email,
                        false,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSizes.space4 * 7),
                Container(
                  padding: EdgeInsets.all(AppSizes.space16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.surfaceSubdued),
                    borderRadius: BorderRadius.circular(AppSizes.space16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: c.phone
                                        ? 'رقم الجوال أو الواتساب المسجل'
                                        : 'البريد الإلكتروني المسجل',
                                  ),
                                  TextSpan(
                                    text: ' *',
                                    style: AppTextStyles.body.copyWith(
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              style: AppTextStyles.caption,
                            ),
                          ),
                          SizedBox(width: AppSizes.space8),
                          Text(
                            c.phone ? 'رسالة SMS' : 'رسالة بريدية',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSizes.space4 * 3),
                      TextFormField(
                        key: ValueKey(c.phone),
                        controller: c.contact,
                        textDirection: TextDirection.ltr,
                        keyboardType: c.phone
                            ? TextInputType.phone
                            : TextInputType.emailAddress,
                        autofillHints: [
                          c.phone
                              ? AutofillHints.telephoneNumberNational
                              : AutofillHints.email,
                        ],
                        decoration: InputDecoration(
                          hintText: c.phone ? '059xxxxxxx' : 'name@example.com',
                          filled: true,
                          fillColor: AppColors.surfaceSubdued,
                          prefixIcon: c.phone
                              ? _countryPicker(context, c)
                              : Icon(
                                  Icons.alternate_email,
                                  size: AppSizes.space4 * 5,
                                  color: AppColors.primary,
                                ),
                          suffixIcon: c.phone
                              ? Icon(
                                  Icons.phone_android_outlined,
                                  size: AppSizes.space4 * 5,
                                  color: AppColors.textSecondary,
                                )
                              : null,
                        ),
                        validator: (input) {
                          final value = input?.trim() ?? '';
                          if (value.isEmpty) {
                            return c.phone
                                ? 'أدخل رقم الجوال'
                                : 'أدخل البريد الإلكتروني';
                          }
                          if (c.phone &&
                              !RegExp(r'^\+?[0-9][0-9\s-]{5,18}$')
                                  .hasMatch(value)) {
                            return 'أدخل رقم جوال صحيحًا';
                          }
                          if (!c.phone &&
                              !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                  .hasMatch(value)) {
                            return 'أدخل بريدًا إلكترونيًا صحيحًا';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => c.submit(),
                      ),
                      SizedBox(height: AppSizes.space4 * 3),
                      Text(
                        c.phone
                            ? 'يرجى التأكد من أن الرقم مربوط بتطبيق واتساب أو يستقبل رسائل نصية.'
                            : 'يرجى إدخال البريد الإلكتروني المرتبط بحسابك.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSizes.space16),
                      Container(
                        padding: EdgeInsets.all(AppSizes.space16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubdued,
                          borderRadius: BorderRadius.circular(AppSizes.space8),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 17,
                              backgroundColor: AppColors.white,
                              child: Icon(
                                Icons.lock_clock_outlined,
                                size: AppSizes.space4 * 5,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: AppSizes.space4 * 3),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(text: 'سيتم إرسال رابط آمن '),
                                    TextSpan(
                                      text: 'إلى بريدك الإلكتروني',
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' لإعادة تعيين كلمة المرور. لا تشارك الرابط مع أي شخص.',
                                    ),
                                  ],
                                ),
                                style: AppTextStyles.caption.copyWith(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSizes.space24),
                AppPrimaryButton(
                  text: 'إرسال رابط إعادة التعيين',
                  isLoading: c.busy,
                  onPressed: c.busy ? null : c.submit,
                ),
                SizedBox(height: AppSizes.space4 * 5),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'تذكرت كلمة المرور؟',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.back<void>(),
                      child: Text('تسجيل الدخول'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  Widget _methodTab(
    BuildContext context,
    ForgotPasswordController c,
    String label,
    IconData icon,
    bool phone,
  ) => Expanded(
    child: InkWell(
      borderRadius: BorderRadius.circular(AppSizes.space4 * 7),
      onTap: () => c.selectMethod(phone),
      child: AnimatedContainer(
        duration: Duration(
          milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 220,
        ),
        padding: EdgeInsets.symmetric(
          vertical: AppSizes.space4 * 3,
          horizontal: AppSizes.space4,
        ),
        decoration: BoxDecoration(
          color: c.phone == phone
              ? AppColors.white
              : AppColors.white.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(AppSizes.space4 * 7),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppSizes.space16,
              color: c.phone == phone
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            SizedBox(width: AppSizes.space8),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: c.phone == phone
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _countryPicker(BuildContext context, ForgotPasswordController c) =>
      Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.space8),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: c.country,
            menuWidth: AppSizes.space4 * 30,
            menuMaxHeight: AppSizes.space4 * 80,
            style: AppTextStyles.caption.copyWith(
              fontFamily: 'Cairo',

              color: AppColors.textPrimary,
            ),
            selectedItemBuilder: (_) => phoneCountryCodes
                .map(
                  (country) => Center(
                    child: Text(country, textDirection: TextDirection.ltr),
                  ),
                )
                .toList(),
            items: phoneCountryCodes
                .map(
                  (country) => DropdownMenuItem(
                    value: country,
                    child: Text(
                      country,
                      textDirection: TextDirection.ltr,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => c.change(() => c.country = value!),
          ),
        ),
      );
}
