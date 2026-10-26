import 'package:daleel_plus/main.dart';
import 'package:daleel_plus/data/repositories/auth_repository.dart';
import 'package:daleel_plus/presentation/features/auth/widgets/auth_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'fake_auth_repository.dart';

void main() {
  registerTestAuth();

  testWidgets(
    'Profile editing preloads values and saves without a new password',
    (tester) async {
      final service = Get.find<AuthRepository>() as FakeAuthRepository;
      service.currentUser = TestUser();
      service.profile = {
        'name': 'الاسم الحالي',
        'phone': '+972591234567',
        'countryCode': '+972',
        'accountType': 'individual',
        'university': 'الجامعة',
        'specialization': 'برمجة',
        'interests': 'تقنية',
      };
      await tester.pumpWidget(const DaleelApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('تعديل بيانات الحساب'));
      await tester.pumpAndSettle();
      expect(find.text('كلمة المرور'), findsNothing);
      expect(
        tester
            .widget<AuthField>(find.widgetWithText(AuthField, 'رقم الجوال'))
            .controller!
            .text,
        '591234567',
      );
      expect(
        tester
            .widget<DropdownButton<String>>(find.byType(DropdownButton<String>))
            .value,
        '+972',
      );
      final name = find.descendant(
        of: find.widgetWithText(AuthField, 'الاسم الكامل'),
        matching: find.byType(TextFormField),
      );
      await tester.ensureVisible(name);
      await tester.enterText(name, 'الاسم المعدل');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('حفظ بيانات الحساب'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('حفظ بيانات الحساب'));
      await tester.pumpAndSettle();
      expect(service.profile?['name'], 'الاسم المعدل');
      expect(service.profile?['phone'], '+972591234567');
      expect(find.text('حسابي'), findsOneWidget);
      await closeTestSnackbars(tester);
    },
  );

  testWidgets('An incomplete existing profile still offers completion', (
    tester,
  ) async {
    final service = Get.find<AuthRepository>() as FakeAuthRepository;
    service.currentUser = TestUser();
    service.profile = {'name': 'طالب'};
    await tester.pumpWidget(const DaleelApp());
    await tester.pumpAndSettle();
    expect(find.text('إكمال بيانات الحساب'), findsOneWidget);
    expect(find.text('تعديل بيانات الحساب'), findsNothing);
    await tester.tap(find.text('إكمال بيانات الحساب'));
    await tester.pumpAndSettle();
    expect(find.text('طالب'), findsOneWidget);
    expect(find.text('كلمة المرور'), findsNothing);
  });
}
