import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pambe_ac_ifa/components/field/text_input.dart';

void main() {
  testWidgets("Test Tag Widget", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BoxTextInput(
          placeholder: "Test",
          value: "Abcde",
          onChanged: (TextEditingController controller, String? value) {},
        ),
      ),
    ));
    expect(find.text("Abcde"), findsOneWidget);
    expect(find.byType(TextFieldValueProvider), findsOneWidget);
  });
}
