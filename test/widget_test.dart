import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/main.dart';

void main() {
  testWidgets('main ...', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: MyHomePage())));

    final phoneField = find.byKey(Key("phone-field"));

    await tester.enterText(phoneField, '9509999999');
    await tester.pumpAndSettle();

    // final EditableText formfield = tester.widget<EditableText>(find.text('phone-field'));

    expect(find.text('+7 (950)999-99-99'), findsOneWidget);
    // expect(phoneField, findsOneWidget);
  });
}
