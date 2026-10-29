import 'package:daleel_plus/presentation/shared/widgets/widgets.dart';
import 'package:daleel_plus/main.dart';
import 'package:daleel_plus/data/repositories/session_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_auth_repository.dart';

void main() {
  registerTestAuth();
  testWidgets(
    'First use shows introduction; skip persists across app restarts',
    (tester) async {
      await tester.pumpWidget(const DaleelApp());
      await tester.pumpAndSettle();
      expect(find.text('ابدأ رحلتك الآن'), findsOneWidget);
      await tester.tap(find.text('ابدأ رحلتك الآن'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('تخطّي'));
      await tester.pumpAndSettle();
      expect(await SessionPreferences().hasCompletedOnboarding(), isTrue);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.pumpWidget(const DaleelApp());
      await tester.pumpAndSettle();
      expect(find.text('ابدأ رحلتك الآن'), findsNothing);
      expect(find.text('كل خدماتك في مكان واحد'), findsNothing);
      expect(
        find.widgetWithText(AppPrimaryButton, 'تسجيل الدخول'),
        findsOneWidget,
      );
    },
  );
  testWidgets('A previously completed introduction goes directly to login', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      SessionPreferences.onboardingKey: true,
    });
    await tester.pumpWidget(const DaleelApp());
    await tester.pumpAndSettle();
    expect(find.text('ابدأ رحلتك الآن'), findsNothing);
    expect(
      find.widgetWithText(AppPrimaryButton, 'تسجيل الدخول'),
      findsOneWidget,
    );
  });
}
