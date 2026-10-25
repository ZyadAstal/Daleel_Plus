import 'package:daleel_plus/presentation/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';

import 'fake_auth_repository.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:daleel_plus/main.dart';
import 'package:daleel_plus/data/models/registration_options.dart';

void main() {
  registerTestAuth();
  testWidgets(
    'Public registration uses email and validates provider selection',
    (tester) async {
      await tester.pumpWidget(const DaleelApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('ابدأ رحلتك الآن'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('تخطّي'));
      await tester.pumpAndSettle();
      expect(find.text('Google'), findsOneWidget);
      await tester.ensureVisible(find.text('إنشاء حساب جديد'));
      await tester.tap(find.text('إنشاء حساب جديد'));
      await tester.pumpAndSettle();
      expect(find.text('كلمة المرور'), findsOneWidget);
      expect(find.text('Google'), findsNothing);
      final countryPicker = find.byType(DropdownButton<String>);
      expect(
        tester.widget<DropdownButton<String>>(countryPicker).value,
        '+970',
      );
      await tester.ensureVisible(countryPicker);
      await tester.tap(countryPicker);
      await tester.pumpAndSettle();
      await tester.tap(find.text('+972').last);
      await tester.pumpAndSettle();
      expect(
        tester.widget<DropdownButton<String>>(countryPicker).value,
        '+972',
      );
      await tester.ensureVisible(find.text('مقدّم خدمة / جهة'));
      await tester.tap(find.text('مقدّم خدمة / جهة'));
      await tester.pumpAndSettle();
      for (final type in ProviderType.values) {
        expect(find.byKey(ValueKey(type)), findsOneWidget);
      }
      await tester.ensureVisible(find.text('إنشاء الحساب والمتابعة'));
      await tester.tap(find.text('إنشاء الحساب والمتابعة'));
      await tester.pumpAndSettle();
      expect(find.text('اختر نوع جهة تقديم الخدمة'), findsOneWidget);
      await tester.ensureVisible(find.text('مدرس خصوصي معتمد'));
      await tester.tap(find.text('مدرس خصوصي معتمد'));
      await tester.pumpAndSettle();
      expect(find.text('كلمة المرور'), findsOneWidget);
      expect(find.text('البريد الإلكتروني التجاري / المهني'), findsOneWidget);
      expect(
        tester
            .widget<ChoiceChip>(
              find.byKey(const ValueKey(ProviderType.privateTutor)),
            )
            .selected,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Welcome, onboarding, and student/provider forms', (
    tester,
  ) async {
    await tester.pumpWidget(const DaleelApp());
    await tester.pumpAndSettle();
    expect(find.text('دليل +'), findsOneWidget);
    await tester.tap(find.text('ابدأ رحلتك الآن'));
    await tester.pumpAndSettle();
    expect(find.text('كل خدماتك في مكان واحد'), findsOneWidget);
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    expect(find.text('اكتشف أحدث المنح والفرص'), findsOneWidget);
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    expect(find.text('قارن واختر الأنسب لميزانيتك'), findsOneWidget);
    await tester.tap(find.text('ابدأ الآن'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.widgetWithText(AppPrimaryButton, 'تسجيل الدخول'),
    );
    await tester.tap(find.widgetWithText(AppPrimaryButton, 'تسجيل الدخول'));
    await tester.pump();
    expect(find.text('يرجى إدخال كلمة المرور'), findsOneWidget);
    await tester.ensureVisible(find.text('إنشاء حساب جديد'));
    await tester.tap(find.text('إنشاء حساب جديد'));
    await tester.pumpAndSettle();
    expect(find.text('انضم إلى مجتمع خطوتي'), findsOneWidget);
    await tester.tap(find.text('مقدّم خدمة / جهة'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('مركز تدريب / أكاديمية'));
    await tester.tap(find.text('مركز تدريب / أكاديمية'));
    await tester.pumpAndSettle();
    expect(find.text('انضم كشريك ومزود خدمة'), findsOneWidget);
    expect(find.text('اسم المركز / مقدم الخدمة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Small screens and keyboard remain scrollable', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const DaleelApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('ابدأ رحلتك الآن'));
    await tester.tap(find.text('ابدأ رحلتك الآن'));
    await tester.pumpAndSettle();
    final title = tester.getRect(find.text('كل خدماتك في مكان واحد'));
    final nextButton = tester.getRect(
      find.widgetWithText(AppPrimaryButton, 'التالي'),
    );
    expect(title.bottom, lessThan(nextButton.top));
    await tester.tap(find.text('تخطّي'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('إنشاء حساب جديد'));
    await tester.tap(find.text('إنشاء حساب جديد'));
    await tester.pumpAndSettle();
    expect(find.text('طالب / خريج'), findsOneWidget);
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('إنشاء الحساب والمتابعة'));
    expect(tester.takeException(), isNull);
  });
}
