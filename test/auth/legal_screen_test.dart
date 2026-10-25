import 'package:daleel_plus/presentation/features/auth/screens/legal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Legal documents are readable and scrollable in Arabic', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: LegalScreen(),
        ),
      ),
    );
    expect(find.text('الشروط والخصوصية'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('حالة هذه الوثيقة'), 400);
    expect(find.textContaining('مسودة بتاريخ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
