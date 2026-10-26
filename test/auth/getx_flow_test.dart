import 'package:daleel_plus/presentation/features/auth/state/auth_controller.dart';
import 'package:daleel_plus/presentation/features/auth/screens/auth_screen.dart';
import 'package:daleel_plus/presentation/features/auth/widgets/auth_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'fake_auth_repository.dart';

void main() {
  registerTestAuth();

  testWidgets(
    'Repeated mode changes replace the route and close its controller',
    (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: AuthScreen()));
      await tester.pumpAndSettle();

      for (var i = 0; i < 3; i++) {
        final previous = tester
            .state<GetBuilderState<AuthController>>(
              find.byType(GetBuilder<AuthController>),
            )
            .controller!;
        await tester.ensureVisible(find.text('إنشاء حساب جديد'));
        await tester.tap(find.text('إنشاء حساب جديد'));
        await tester.pumpAndSettle();
        expect(previous.isClosed, isTrue);
        expect(
          tester.widget<AuthScreen>(find.byType(AuthScreen)).register,
          isTrue,
        );

        final login = find.widgetWithText(TextButton, 'تسجيل الدخول');
        await tester.ensureVisible(login);
        await tester.tap(login);
        await tester.pumpAndSettle();
        expect(
          tester.widget<AuthScreen>(find.byType(AuthScreen)).register,
          isFalse,
        );
      }
    },
  );

  testWidgets(
    'Password fields keep independent visibility across form rebuilds',
    (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: AuthScreen(register: true)),
      );
      await tester.pumpAndSettle();
      final passwords = find.byWidgetPredicate(
        (widget) => widget is AuthField && widget.password,
      );
      final firstInput = find.descendant(
        of: passwords.first,
        matching: find.byType(TextFormField),
      );
      final secondInput = find.descendant(
        of: passwords.last,
        matching: find.byType(TextFormField),
      );
      final toggle = find.descendant(
        of: passwords.first,
        matching: find.byType(IconButton),
      );
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      await tester.enterText(firstInput, 'Test12345!');
      await tester.pump();
      expect(
        tester
            .widget<TextField>(
              find.descendant(of: firstInput, matching: find.byType(TextField)),
            )
            .obscureText,
        isFalse,
      );
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: secondInput,
                matching: find.byType(TextField),
              ),
            )
            .obscureText,
        isTrue,
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );
}
