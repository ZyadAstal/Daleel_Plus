import 'dart:async';

import 'package:daleel_plus/main.dart';
import 'package:daleel_plus/data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'fake_auth_repository.dart';

class VerificationSessionService extends FakeAuthRepository {
  final changes = StreamController<User?>.broadcast();

  @override
  Stream<User?> get session => changes.stream;

  @override
  Future<bool> refreshEmailVerification() async {
    final verified = await super.refreshEmailVerification();
    changes.add(currentUser);
    return verified;
  }
}

void main() {
  registerTestAuth();
  testWidgets(
    'Verified email proceeds automatically without tapping continue',
    (tester) async {
      final service = VerificationSessionService()
        ..currentUser = TestUser()
        ..needsEmailVerification = true;
      Get.replace<AuthRepository>(service);
      await tester.pumpWidget(const DaleelApp());
      await tester.pumpAndSettle();
      expect(find.text('تحقق من بريدك الإلكتروني'), findsOneWidget);
      service.needsEmailVerification = false;
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.text('تحقق من بريدك الإلكتروني'), findsNothing);
      expect(find.text('إكمال بيانات الحساب'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await service.changes.close();
    },
  );
  testWidgets('Verification polls quietly and checks again on resume', (
    tester,
  ) async {
    final service = Get.find<AuthRepository>() as FakeAuthRepository;
    service.currentUser = TestUser();
    service.needsEmailVerification = true;
    await tester.pumpWidget(const DaleelApp());
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    expect(service.verificationChecks, 1);
    expect(Get.isSnackbarOpen, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 10));
    expect(service.verificationChecks, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(service.verificationChecks, 2);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
    expect(service.verificationChecks, 2);
  });
  testWidgets('Unverified email stays at verification and throttles resends', (
    tester,
  ) async {
    final service = Get.find<AuthRepository>() as FakeAuthRepository;
    service.currentUser = TestUser();
    service.needsEmailVerification = true;
    await tester.pumpWidget(const DaleelApp());
    await tester.pumpAndSettle();
    expect(find.text('تحقق من بريدك الإلكتروني'), findsOneWidget);
    expect(find.text('حسابي'), findsNothing);
    expect(service.verificationEmails, 1);
    expect(
      tester
          .widget<TextButton>(
            find.widgetWithText(TextButton, 'أعد إرسال رابط التحقق'),
          )
          .onPressed,
      isNull,
    );
    await tester.ensureVisible(find.text('تأكيد ومتابعة'));
    await tester.tap(find.text('تأكيد ومتابعة'));
    await tester.pumpAndSettle();
    expect(find.textContaining('لم يتأكد البريد بعد'), findsOneWidget);
    expect(service.verificationEmails, 1);
    await closeTestSnackbars(tester);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
  testWidgets('Verified accounts do not see email verification', (
    tester,
  ) async {
    final service = Get.find<AuthRepository>() as FakeAuthRepository;
    service.currentUser = TestUser();
    service.needsEmailVerification = false;
    await tester.pumpWidget(const DaleelApp());
    await tester.pumpAndSettle();
    expect(find.text('تحقق من بريدك الإلكتروني'), findsNothing);
    expect(find.text('إكمال بيانات الحساب'), findsOneWidget);
  });
}
