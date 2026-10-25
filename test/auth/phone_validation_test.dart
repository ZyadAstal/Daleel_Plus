import 'package:daleel_plus/main.dart';
import 'package:daleel_plus/presentation/features/auth/widgets/auth_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_auth_repository.dart';

void main() {
  registerTestAuth();
  testWidgets(
    'Registration phone limits input to nine digits and rejects short numbers',
    (tester) async {
      await tester.pumpWidget(const DaleelApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('ابدأ رحلتك الآن'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('تخطّي'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('إنشاء حساب جديد'));
      await tester.tap(find.text('إنشاء حساب جديد'));
      await tester.pumpAndSettle();
      final phone = find.descendant(
        of: find.widgetWithText(AuthField, 'رقم الجوال'),
        matching: find.byType(TextFormField),
      );
      await tester.ensureVisible(phone);
      await tester.enterText(phone, '59123456789abc');
      expect(tester.widget<TextFormField>(phone).controller!.text, '591234567');
      await tester.enterText(phone, '59123');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('إنشاء الحساب والمتابعة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('إنشاء الحساب والمتابعة'));
      await tester.pumpAndSettle();
      expect(
        find.text('أدخل رقم جوال من 9 أرقام دون مقدمة الدولة'),
        findsOneWidget,
      );
      await tester.ensureVisible(phone);
      await tester.enterText(phone, '591234567');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('إنشاء الحساب والمتابعة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('إنشاء الحساب والمتابعة'));
      await tester.pumpAndSettle();
      expect(
        find.text('أدخل رقم جوال من 9 أرقام دون مقدمة الدولة'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
