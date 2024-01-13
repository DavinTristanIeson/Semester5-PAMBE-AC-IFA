import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/pages/startup/components.dart';
import 'package:pambe_ac_ifa/pages/startup/main.dart';

void main() {
  testWidgets("Test Startup Screen", (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: StartupScreen(),
    ));

    expect(find.byType(RecipeLibLogoTitle), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(StartupMessageBoard), findsNWidgets(3));
    expect(find.text("screen/startup/get_started/startup_messege".i18n()),
        findsOneWidget);
    expect(find.text("screen/startup/get_started/startup_messege_extra".i18n()),
        findsOneWidget);
    expect(
        find.text(
            "screen/startup/get_started/startup_messege_extra_extra".i18n()),
        findsOneWidget);
    expect(find.text("Get Started"), findsOneWidget);
  });
}
