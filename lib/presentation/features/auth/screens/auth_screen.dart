import 'package:daleel_plus/presentation/shared/widgets/widgets.dart';
import 'package:daleel_plus/presentation/shared/theme/app_text_styles.dart';
import 'package:daleel_plus/presentation/shared/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:daleel_plus/presentation/features/auth/screens/legal_screen.dart';
import 'package:daleel_plus/data/models/registration_options.dart';
import 'package:daleel_plus/presentation/shared/constants/app_colors.dart';
import 'package:daleel_plus/presentation/features/auth/widgets/auth_field.dart';
import 'package:daleel_plus/presentation/features/auth/widgets/auth_widgets.dart';
import 'package:daleel_plus/presentation/features/auth/state/auth_controller.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({
    super.key,
    this.register = false,
    this.completeProfile = false,
    this.passwordSetup = false,
    this.accountType = AccountType.universityStudent,
    this.providerType,
    this.registrationMethod = RegistrationMethod.emailPassword,
    this.initialProfile,
    this.editing = false,
  });
  final bool register;
  final bool completeProfile;
  final bool passwordSetup;
  final AccountType accountType;
  final ProviderType? providerType;
  final RegistrationMethod registrationMethod;
  final Map<String, dynamic>? initialProfile;
  final bool editing;
  @override
  Widget build(BuildContext context) => GetBuilder<AuthController>(
    init: AuthController(
      register: register,
      completeProfile: completeProfile,
      passwordSetup: passwordSetup,
      accountType: accountType,
      providerType: providerType,
      initialProfile: initialProfile,
      editing: editing,
    ),
    global: false,
    dispose: (state) => state.controller?.onDelete(),
    builder: (c) => _render(context, c),
  );

  Widget _render(BuildContext context, AuthController c) => MobilePage(
    child: SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        MediaQuery.sizeOf(context).width < AppSizes.screenPadding * 15
            ? AppSizes.space16
            : AppSizes.screenPadding,
        MediaQuery.sizeOf(context).height < AppSizes.screenPadding * 30
            ? AppSizes.space16 * 2
            : AppSizes.topBarHeight,
        MediaQuery.sizeOf(context).width < 360 ? 16 : 24,
        AppSizes.space24,
      ),
      child: Form(
        key: c.form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!register) ...[
              Center(child: BrandLogo(size: AppSizes.space4 * 27)),
              SizedBox(height: AppSizes.space4 * 3),
            ],
            Align(
              alignment: register
                  ? AlignmentDirectional.centerStart
                  : Alignment.center,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.space4 * 3,
                  vertical: AppSizes.space4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubdued,
                  borderRadius: BorderRadius.circular(AppSizes.space4 * 5),
                ),
                child: Text(
                  register
                      ? (c.provider
                            ? '🚀 انضم لشبكة مزودي الخدمات الأكاديمية'
                            : '🚀 ابدأ رحلتك الأكاديمية')
                      : '🟢 مرحبًا بعودتك مجددًا!',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSizes.space4 * 3),
            Text(
              editing
                  ? 'تعديل بيانات الحساب'
                  : register
                  ? (c.provider
                        ? 'انضم كشريك ومزود خدمة'
                        : 'انضم إلى مجتمع خطوتي')
                  : 'تسجيل الدخول',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading1.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: AppSizes.space8),
            Text(
              register
                  ? (c.provider
                        ? 'وسّع نطاق وصولك لآلاف الطلاب الجامعيين والباحثين'
                        : 'خطوتك الأولى نحو تجربة جامعية ذكية ومنظمة ومميزة')
                  : 'أدخل بيانات حسابك للمتابعة والوصول لخدماتك وخطواتك الأكاديمية',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSizes.space4 * 7),
            if (register) ...[
              Container(
                padding: EdgeInsets.all(AppSizes.space4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubdued,
                  borderRadius: BorderRadius.circular(AppSizes.space16),
                ),
                child: Row(
                  children: [
                    _accountTab(context, c, 'طالب / خريج', Icons.school, false),
                    _accountTab(
                      context,
                      c,
                      'مقدّم خدمة / جهة',
                      Icons.storefront_outlined,
                      true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSizes.space24),
              if (c.provider) ...[
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'نوع جهة تقديم الخدمة'),
                      TextSpan(
                        text: ' *',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  style: AppTextStyles.label,
                ),
                SizedBox(height: AppSizes.space4 * 3),
                FormField<ProviderType>(
                  key: ValueKey('provider-type-$c.provider'),
                  initialValue: c.providerType,
                  validator: (value) =>
                      value == null ? 'اختر نوع جهة تقديم الخدمة' : null,
                  builder: (field) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) => Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children:
                              [
                                    ProviderType.education,
                                    ProviderType.privateTutor,
                                    ProviderType.printing,
                                    ProviderType.opportunities,
                                  ]
                                  .map(
                                    (type) => SizedBox(
                                      width: (constraints.maxWidth - 12) / 2,
                                      child: ChoiceChip(
                                        key: ValueKey(type),
                                        label: Text(
                                          c.providerLabel(type),
                                          style: AppTextStyles.caption.copyWith(
                                            color: c.providerType == type
                                                ? AppColors.white
                                                : AppColors.primary,
                                          ),
                                        ),
                                        avatar: Icon(
                                          c.providerIcon(type),
                                          size: AppSizes.space16,
                                          color: c.providerType == type
                                              ? AppColors.white
                                              : AppColors.primary,
                                        ),
                                        selected: c.providerType == type,
                                        showCheckmark: false,
                                        backgroundColor: Color(0xFFF1F5F9),
                                        selectedColor: AppColors.primary,
                                        side: BorderSide(
                                          color: c.providerType == type
                                              ? AppColors.primary
                                              : AppColors.primary,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        onSelected: (_) {
                                          c.change(() => c.providerType = type);
                                          field.didChange(type);
                                        },
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                      if (field.hasError)
                        Text(
                          field.errorText!,
                          style: AppTextStyles.caption.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: AppSizes.space4 * 5),
              ],
              AuthField(
                key: ValueKey('name-$c.provider'),
                controller: c.fields['name'],
                label: c.provider ? 'اسم المركز / مقدم الخدمة' : 'الاسم الكامل',
                hint: c.provider
                    ? 'مثال: أكاديمية رواد المستقبل ...'
                    : 'الاسم الثلاثي أو الرباعي',
                icon: c.provider
                    ? Icons.storefront_outlined
                    : Icons.badge_outlined,
                autofill: [AutofillHints.name],
              ),
            ],
            AuthField(
              controller: c.email,
              readOnly: completeProfile,
              label: register
                  ? (c.provider
                        ? 'البريد الإلكتروني التجاري / المهني'
                        : 'البريد الإلكتروني الجامعي أو الشخصي')
                  : 'البريد الإلكتروني',
              hint: register ? 'student@university.edu.ps' : 'name@example.com',
              icon: Icons.alternate_email,
              keyboard: TextInputType.emailAddress,
              autofill: [AutofillHints.username],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال هذا الحقل';
                }
                if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                    .hasMatch(value.trim())) {
                  return 'أدخل بريدًا إلكترونيًا صحيحًا';
                }
                return null;
              },
            ),
            if (register) ...[
              AuthField(
                controller: c.fields['phone'],
                label: 'رقم الجوال',
                validator: (value) =>
                    RegExp(r'^[0-9]{9}$').hasMatch(value ?? '')
                    ? null
                    : 'أدخل رقم جوال من 9 أرقام دون مقدمة الدولة',
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                ],
                hint: '591234567',
                icon: Icons.phone_outlined,
                keyboard: TextInputType.phone,
                autofill: [AutofillHints.telephoneNumber],
                leading: Container(
                  margin: EdgeInsets.all(AppSizes.space8),
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.space8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubdued,
                    borderRadius: BorderRadius.circular(AppSizes.space4 * 3),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isDense: true,
                      value: c.countryCode,
                      menuMaxHeight: AppSizes.space4 * 80,
                      menuWidth: AppSizes.space4 * 30,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textPrimary,
                        fontFamily: 'Cairo',
                      ),
                      selectedItemBuilder: (context) => phoneCountryCodes
                          .map(
                            (country) =>
                                Text(country, textDirection: TextDirection.ltr),
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
                      onChanged: (code) =>
                          c.change(() => c.countryCode = code!),
                    ),
                  ),
                ),
              ),
              if (c.provider) ...[
                AuthField(
                  controller: c.fields['field'],
                  label: 'المجال التخصصي الأساسي',
                  hint: 'أدخل المجال التخصصي الأساسي',
                  icon: Icons.category_outlined,
                ),
                AuthField(
                  controller: c.fields['location'],
                  label: 'المدينة أو المنطقة للمقر الأساسي',
                  hint: 'أدخل المدينة أو المنطقة',
                  icon: Icons.location_on_outlined,
                ),
                AuthField(
                  controller: c.fields['portfolio'],
                  label: 'رابط السجل التجاري أو البورتفوليو',
                  hint: 'https://facebook.com/your-center',
                  icon: Icons.link,
                  keyboard: TextInputType.url,
                  required: false,
                ),
              ] else ...[
                if (c.academic) ...[
                  AuthField(
                    controller: c.fields['university'],
                    label: 'الجامعة / الكلية',
                    hint: 'اختر الجامعة أو الصرح الأكاديمي',
                    icon: Icons.account_balance_outlined,
                  ),
                  AuthField(
                    controller: c.fields['specialization'],
                    label: 'التخصص الدراسي',
                    hint: 'مثلاً: هندسة البرمجيات، إدارة أعمال، طب...',
                    icon: Icons.menu_book_outlined,
                  ),
                ],
                AuthField(
                  controller: c.fields['interests'],
                  label: 'الاهتمامات',
                  hint: 'مثال: البرمجة، التصميم، UI/UX...',
                  icon: Icons.menu_book_outlined,
                ),
              ],
            ],
            if (!completeProfile || passwordSetup)
              AuthField(
                label: 'كلمة المرور',
                hint: '••••••••',
                icon: Icons.lock_outline,
                password: true,
                controller: c.password,
                autofill: [
                  register ? AutofillHints.newPassword : AutofillHints.password,
                ],
                validator: (value) => value == null || value.isEmpty
                    ? 'يرجى إدخال كلمة المرور'
                    : register && value.length < 8
                    ? 'استخدم 8 أحرف على الأقل'
                    : null,
              ),
            if (register) ...[
              if (!completeProfile || passwordSetup) ...[
                AuthField(
                  label: 'تأكيد كلمة المرور',
                  hint: '••••••••',
                  icon: Icons.verified_outlined,
                  password: true,
                  validator: (value) => value == null || value.isEmpty
                      ? 'يرجى تأكيد كلمة المرور'
                      : value != c.password.text
                      ? 'كلمتا المرور غير متطابقتين'
                      : null,
                ),
                Builder(
                  builder: (context) {
                    final value = c.password.text;
                    final strength =
                        (value.length >= 8 ? 1 : 0) +
                        (RegExp(r'[0-9]').hasMatch(value) ? 1 : 0) +
                        (RegExp(r'[^a-zA-Z0-9]').hasMatch(value) ? 1 : 0);
                    return Row(
                      children: [
                        ...List.generate(
                          4,
                          (index) => Expanded(
                            child: Container(
                              height: AppSizes.space4,
                              margin: EdgeInsetsDirectional.only(
                                end: AppSizes.space4,
                              ),
                              decoration: BoxDecoration(
                                color: index < strength
                                    ? AppColors.success
                                    : AppColors.border,
                                borderRadius: BorderRadius.circular(
                                  AppSizes.space4,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 4,
                          child: Text(
                            value.isEmpty
                                ? 'يفضل 8 أحرف وأرقام على الأقل'
                                : [
                                    'ضعيفة',
                                    'ضعيفة',
                                    'متوسطة',
                                    'قوية',
                                  ][strength],
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
              SizedBox(height: AppSizes.space24),
              if (!editing)
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: AppSizes.space8,
                    horizontal: AppSizes.space4 * 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubdued,
                    borderRadius: BorderRadius.circular(AppSizes.space16),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: c.agreed,
                        onChanged: (value) => c.change(() => c.agreed = value!),
                        activeColor: AppColors.primary,
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: 'أوافق على '),
                              WidgetSpan(
                                child: InkWell(
                                  onTap: () =>
                                      Get.to<void>(() => LegalScreen()),
                                  child: Text(
                                    'الشروط والأحكام وسياسة الخصوصية',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              TextSpan(text: ' لمنصة دليل + التعليمية.'),
                            ],
                          ),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: AppSizes.space24),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      value: c.remember,
                      onChanged: c.busy
                          ? null
                          : (value) => c.change(() => c.remember = value!),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: Text('تذكّرني', style: AppTextStyles.caption),
                    ),
                  ),
                  Flexible(
                    child: TextButton(
                      onPressed: c.resetPassword,
                      child: Text(
                        'نسيت كلمة المرور؟',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.space4 * 3),
            ],
            AppPrimaryButton(
              text: completeProfile
                  ? 'حفظ بيانات الحساب'
                  : register
                  ? 'إنشاء الحساب والمتابعة'
                  : 'تسجيل الدخول',
              isLoading: c.busy,
              onPressed: c.busy ? null : c.submit,
            ),
            if (!register) ...[
              SizedBox(height: AppSizes.space24),
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.space4 * 3,
                    ),
                    child: Text(
                      'أو الدخول عبر',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.border)),
                ],
              ),
              SizedBox(height: AppSizes.space16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: null,
                      icon: Icon(Icons.apple, color: AppColors.textPrimary),
                      label: Text(
                        'Apple',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSizes.space4 * 3),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: c.busy ? null : c.googleSignIn,
                      child: Text(
                        'Google',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.space24),
              Container(
                padding: EdgeInsets.all(AppSizes.space16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubdued,
                  borderRadius: BorderRadius.circular(AppSizes.space16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified,
                      color: AppColors.success,
                      size: AppSizes.space4 * 8,
                    ),
                    SizedBox(width: AppSizes.space4 * 3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'حساب موثّق للطلاب',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'وصول فوري لكافة خدماتك المتعلقة بالحرم الجامعي',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: AppSizes.space24),
            if (!completeProfile)
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    register ? 'لديك حساب بالفعل؟' : 'ليس لديك حساب؟',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: c.busy ? null : c.switchMode,
                    child: Text(
                      register ? 'تسجيل الدخول' : 'إنشاء حساب جديد',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ),
  );

  Widget _accountTab(
    BuildContext context,
    AuthController c,
    String label,
    IconData icon,
    bool provider,
  ) => Expanded(
    child: InkWell(
      borderRadius: BorderRadius.circular(AppSizes.space4 * 3),
      onTap: () => c.changeAccount(provider),
      child: AnimatedContainer(
        duration: Duration(
          milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 220,
        ),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          vertical: AppSizes.space4 * 3,
          horizontal: AppSizes.space8,
        ),
        decoration: BoxDecoration(
          color: c.provider == provider
              ? AppColors.white
              : AppColors.white.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(AppSizes.space4 * 3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppSizes.space4 * 5,
              color: c.provider == provider
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            SizedBox(width: AppSizes.space8),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: c.provider == provider
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
}
