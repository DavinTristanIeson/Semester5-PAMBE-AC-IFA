import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/validation.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/models/user.dart';
import 'package:pambe_ac_ifa/pages/editor/main.dart';
import 'package:pambe_ac_ifa/pages/recipe/info.dart';
import 'package:pambe_ac_ifa/pages/recipe/viewer.dart';
import 'package:pambe_ac_ifa/providers/auth.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData createTheme() {
    return ThemeData(
        colorScheme: const ColorScheme(
          primary: AcColors.primary,
          secondary: AcColors.secondary,
          background: AcColors.background,
          brightness: Brightness.dark,
          surface: AcColors.card,
          error: AcColors.danger,
          tertiary: AcColors.subtle,
          onPrimary: AcColors.background,
          onSecondary: AcColors.black,
          onBackground: AcColors.primary,
          onSurface: AcColors.black,
          onError: AcColors.black,
          onTertiary: AcColors.white,
        ),
        splashColor: AcColors.splashColor,
        useMaterial3: true,
        fontFamily: "Roboto",
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          splashColor: AcColors.splashColor,
          hoverColor: AcColors.hoverColor,
          focusColor: AcColors.hoverColor,
        ),
        elevatedButtonTheme: buildElevatedButtonTheme(),
        textTheme: Typography.material2021().black,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AcColors.primary,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: AcSizes.fontEmphasis,
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AcColors.secondary,
          foregroundColor: AcColors.primary,
          elevation: AcSizes.md,
          centerTitle: true,
          titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: AcColors.primary,
              fontSize: AcSizes.fontLarge),
        ));
  }

  ElevatedButtonThemeData buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
                backgroundColor: AcColors.primary,
                foregroundColor: AcColors.background,
                textStyle: AcTypography.labelLarge)
            .copyWith(overlayColor: MaterialStateProperty.resolveWith((states) {
      if (states.containsAny([
        MaterialState.hovered,
        MaterialState.focused,
        MaterialState.selected
      ])) {
        return AcColors.hoverColor;
      } else if (states
          .containsAny([MaterialState.pressed, MaterialState.dragged])) {
        return AcColors.splashColor;
      } else {
        return null;
      }
    })));
  }

  List<SingleChildWidget> buildProviders() {
    return [
      ChangeNotifierProvider(create: (context) => AuthProvider()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: buildProviders(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: createTheme(),
        home: AcReactiveFormConfig(
            child: RecipeInfoPage(
                recipe: Recipe(
          creator: User(
              id: "0",
              name: "User",
              email: "placeholder@email.com",
              onlineImage: "https://www.google.com"),
          description: "Description",
          steps: [],
          title: "Recipe Title",
          localImage: "",
        ))),
      ),
    );
  }
}
