import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daleel_plus/app/app.dart';
import 'package:daleel_plus/app/app_router.dart';
import 'package:daleel_plus/app/app_theme.dart';

void main() {
  group('Daleel+ Foundation & Routing Infrastructure Tests', () {
    testWidgets('DaleelApp boots and renders Scaffold on initial route', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const DaleelApp());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    test('All required feature named routes generate valid routes', () {
      final routesToVerify = [
        AppRoutes.initial,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.accountType,
        AppRoutes.profileSetup,
        AppRoutes.interests,
        AppRoutes.discovery,
        AppRoutes.search,
        AppRoutes.education,
        AppRoutes.libraries,
        AppRoutes.jobs,
        AppRoutes.tutors,
        AppRoutes.notifications,
      ];

      for (final routeName in routesToVerify) {
        final route = AppRouter.onGenerateRoute(RouteSettings(name: routeName));

        expect(
          route,
          isA<MaterialPageRoute>(),
          reason: 'Route "$routeName" should generate a MaterialPageRoute',
        );
      }
    });

    test('Unknown routes generate a valid fallback route', () {
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(name: '/non-existent-route'),
      );

      expect(route, isA<MaterialPageRoute>());
    });

    testWidgets('AppTheme is applied to MaterialApp', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const DaleelApp());
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.useMaterial3, isTrue);
      expect(
        materialApp.theme?.colorScheme.primary,
        equals(AppTheme.primaryColor),
      );
    });
  });
}
