import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardaya_app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GuardaYaApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
