import 'package:daleel_plus/main.dart';
import 'package:daleel_plus/data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'fake_auth_repository.dart';

void main() {
  registerTestAuth();
  testWidgets('Recovery validates email, calls shared service and returns', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const DaleelApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('ابدأ رحلتك الآن'));
    await tester.tap(find.text('ابدأ رحلتك الآن'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تخطّي'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('نسيت كلمة المرور؟'));
    await tester.tap(find.text('نسيت كلمة المرور؟'));
    await tester.pumpAndSettle();
    expect(find.text('استعادة كلمة المرور'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'invalid');
    await tester.ensureVisible(find.text('إرسال رابط إعادة التعيين'));
    await tester.tap(find.text('إرسال رابط إعادة التعيين'));
    await tester.pumpAndSettle();
    expect(find.text('أدخل بريدًا إلكترونيًا صحيحًا'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'student@example.com');
    await tester.ensureVisible(find.text('إرسال رابط إعادة التعيين'));
    await tester.tap(find.text('إرسال رابط إعادة التعيين'));
    await tester.pumpAndSettle();
    expect(
      (Get.find<AuthRepository>() as FakeAuthRepository).lastResetEmail,
      'student@example.com',
    );
    expect(find.textContaining('سيصلك رابط'), findsOneWidget);
    await closeTestSnackbars(tester);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('تسجيل الدخول'));
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();
    expect(find.text('نسيت كلمة المرور؟'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
