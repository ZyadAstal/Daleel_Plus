import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daleel_plus/main.dart';
import 'package:daleel_plus/presentation/features/onboarding/screens/welcome_screen.dart';

import 'auth/fake_auth_repository.dart';

void main() {
  registerTestAuth();
  group('Daleel+ Foundation Boot Tests', () {
    testWidgets('DaleelApp boots and renders Daleel+ title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const DaleelApp());
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.text('دليل +'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(WelcomeScreen))),
        TextDirection.rtl,
      );
    });
  });
}
