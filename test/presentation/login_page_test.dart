import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardaya_app/presentation/pages/login_page.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';

void main() {
  group('LoginPage', () {
    testWidgets('muestra error cuando faltan campos', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LoginPage()),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Ingrese usuario y contraseña'), findsOneWidget);
    });

    testWidgets('renderiza los campos de login correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LoginPage()),
        ),
      );

      expect(find.byType(TextField), findsExactly(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Iniciar Sesión'), findsOneWidget);
    });
  });
}
