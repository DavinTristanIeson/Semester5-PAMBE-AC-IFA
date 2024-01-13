import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/components/field/text_input.dart';
import 'package:pambe_ac_ifa/pages/login/components/actions.dart';
import 'package:pambe_ac_ifa/pages/login/register.dart';
import 'package:pambe_ac_ifa/pages/startup/components.dart';

void main() {
  testWidgets("Test Register Screen", (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: RegisterScreen(),
    ));

    expect(find.byType(RecipeLibLogoTitle), findsOneWidget);
    expect(find.text("Recipe.Lib"), findsOneWidget);

    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text("common/back".i18n()), findsOneWidget);
    expect(find.text("common/enter_extra".i18n(["common/email".i18n()])),
        findsNWidgets(3));
    expect(find.text("common/enter_extra".i18n(["common/password".i18n()])),
        findsNWidgets(3));
    expect(find.text("screen/login/register/enter_password_extra".i18n()),
        findsNWidgets(1));
    expect(find.text("common/enter_extra".i18n(["common/name".i18n()])),
        findsNWidgets(3));
    expect(find.text("screen/login/register/about_you".i18n()), findsOneWidget);

    expect(find.byType(AcTextInput), findsNWidgets(5));
    expect(find.text("screen/home/guest/register".i18n()), findsOneWidget);

    expect(find.byType(LoginSubmitButton), findsOneWidget);
  });
}
