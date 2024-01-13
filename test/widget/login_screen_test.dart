import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/components/field/text_input.dart';
import 'package:pambe_ac_ifa/pages/login/components/actions.dart';
import 'package:pambe_ac_ifa/pages/login/login.dart';
import 'package:pambe_ac_ifa/pages/startup/components.dart';

void main() {
  testWidgets("Test Login Screen", (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: LoginScreen(),
    ));

    expect(find.byType(RecipeLibLogoTitle), findsOneWidget);
    expect(find.text("Recipe.Lib"), findsOneWidget);

    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text("common/back".i18n()), findsOneWidget);
    expect(find.text("common/enter_extra".i18n(["common/email".i18n()])),
        findsNWidgets(2));
    expect(find.text("common/enter_extra".i18n(["common/password".i18n()])),
        findsNWidgets(2));
    expect(find.text("screen/home/guest/login".i18n()), findsOneWidget);

    expect(find.byType(AcTextInput), findsNWidgets(2));
    expect(find.text("screen/home/guest/login".i18n()), findsOneWidget);

    expect(find.byType(LoginSubmitButton), findsOneWidget);
  });
}
