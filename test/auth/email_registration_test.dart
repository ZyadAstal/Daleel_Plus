import 'package:daleel_plus/data/repositories/auth_repository.dart';
import 'package:daleel_plus/presentation/features/auth/screens/auth_screen.dart';
import 'package:daleel_plus/presentation/features/auth/widgets/auth_field.dart';
import 'package:daleel_plus/presentation/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'fake_auth_repository.dart';

void main() {
  registerTestAuth();
  testWidgets(
    'Email registration validates consent and sends a typed profile',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: const AuthScreen(register: true),
        ),
      );
      await tester.pumpAndSettle();
      for (final field
          in tester.widgetList<AuthField>(find.byType(AuthField)).toList()) {
        final input = find.descendant(
          of: find.widgetWithText(AuthField, field.label),
          matching: find.byType(TextFormField),
        );
        await tester.ensureVisible(input);
        await tester.enterText(
          input,
          field.label.contains('البريد')
              ? 'student@example.com'
              : field.password
              ? 'Password123!'
              : field.label.contains('الجوال')
              ? '591234567'
              : 'بيانات الاختبار',
        );
      }
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      final submit = find.text('إنشاء الحساب والمتابعة');
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.textContaining('يرجى الموافقة'), findsOneWidget);
      await closeTestSnackbars(tester);
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      await tester.tap(submit);
      await tester.pumpAndSettle();
      final repository = Get.find<AuthRepository>() as FakeAuthRepository;
      expect(repository.profile?['phone'], '+970591234567');
      expect(repository.profile?['accountType'], 'individual');
      expect(repository.profile?.containsKey('password'), isFalse);
      expect(find.text('حسابي'), findsOneWidget);
      await closeTestSnackbars(tester);
    },
  );
}
