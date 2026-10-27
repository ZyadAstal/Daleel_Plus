import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daleel_plus/main.dart';

void main() {
  group('Daleel+ Foundation Boot Tests', () {
    testWidgets('DaleelApp boots and renders Daleel+ title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Daleel+'), findsOneWidget);
    });
  });
}
