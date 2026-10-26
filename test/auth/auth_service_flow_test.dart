import 'package:daleel_plus/presentation/shared/widgets/widgets.dart';

import 'dart:async';

import 'package:daleel_plus/main.dart';
import 'package:daleel_plus/presentation/features/auth/widgets/auth_field.dart';
import 'package:daleel_plus/data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'fake_auth_repository.dart';

Future<void> openLogin(WidgetTester tester) async {
  await tester.pumpWidget(const DaleelApp());
  await tester.pumpAndSettle();
  await tester.tap(find.text('ابدأ رحلتك الآن'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('تخطّي'));
  await tester.pumpAndSettle();
}

void main() {
  registerTestAuth();
  testWidgets('Login waits for service and displays backend errors', (
    tester,
  ) async {
    final service = Get.find<AuthRepository>() as FakeAuthRepository;
    final pending = Completer<void>();
    service.pending = pending.future;
    service.failure = FirebaseAuthException(code: 'invalid-credential');
    await openLogin(tester);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'student@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Password123!');
    await tester.ensureVisible(
      find.widgetWithText(AppPrimaryButton, 'تسجيل الدخول'),
    );
    await tester.tap(find.widgetWithText(AppPrimaryButton, 'تسجيل الدخول'));
    await tester.pump();
    expect(
      tester.widget<AppPrimaryButton>(find.byType(AppPrimaryButton)).isLoading,
      isTrue,
    );
    expect(
      tester.widget<AppPrimaryButton>(find.byType(AppPrimaryButton)).isLoading,
      isTrue,
    );
    pending.complete();
    await tester.pumpAndSettle();
    expect(service.lastLoginEmail, 'student@example.com');
    expect(find.byType(GetSnackBar), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(
      find.text('البريد الإلكتروني أو كلمة المرور غير صحيحة.'),
      findsOneWidget,
    );
    expect(service.currentUser, isNull);
    await closeTestSnackbars(tester);
  });
  testWidgets('Google account without profile reaches completion form', (
    tester,
  ) async {
    await openLogin(tester);
    await tester.ensureVisible(find.text('Google'));
    await tester.tap(find.text('Google'));
    await tester.pumpAndSettle();
    expect(find.text('الاسم الكامل'), findsOneWidget);
    expect(find.text('كلمة المرور'), findsOneWidget);
    for (final field
        in tester.widgetList<AuthField>(find.byType(AuthField)).toList()) {
      if (field.readOnly) continue;
      final input = find.descendant(
        of: find.widgetWithText(AuthField, field.label),
        matching: find.byType(TextFormField),
      );
      await tester.ensureVisible(input);
      await tester.enterText(
        input,
        field.password
            ? 'Password123!'
            : field.label == 'رقم الجوال'
            ? '591234567'
            : 'بيانات الاختبار',
      );
    }
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('حفظ بيانات الحساب'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ بيانات الحساب'));
    await tester.pumpAndSettle();
    final service = Get.find<AuthRepository>() as FakeAuthRepository;
    expect(service.linkedPassword, 'Password123!');
    expect(service.profile?['name'], 'بيانات الاختبار');
    expect(service.profile?['phone'], '+970591234567');
    expect(find.text('حسابي'), findsOneWidget);
    await closeTestSnackbars(tester);
  });
}
