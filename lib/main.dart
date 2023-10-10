import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/validation.dart';
import 'package:pambe_ac_ifa/database/sqflite/loader.dart';
import 'package:pambe_ac_ifa/database/sqflite/migration.dart';
import 'package:pambe_ac_ifa/providers/auth.dart';
import 'package:pambe_ac_ifa/providers/database.dart';
import 'package:pambe_ac_ifa/switch.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  WidgetsFlutterBinding.ensureInitialized();
  MigrationManager migrationManager = MigrationManager([
    SqfliteMigration(1, create: (Transaction transaction) async {
      transaction.execute('''
          CREATE TABLE recipes (
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              user_id INTEGER, 
              title VARCHAR(255) NOT NULL,
              description VARCHAR(255), 
              created_at INTEGER
          );
      ''');
      transaction.execute('''
          CREATE TABLE recipe_steps (
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            recipe_id INTEGER, 
            content VARCHAR(255) NOT NULL, 
            type VARCHAR(255) NOT NULL, 
            timer INTEGER, 
            created_at INTEGER, 
            FOREIGN KEY (recipe_id) REFERENCES recipes(id)
          );
      ''');
    }, upgrade: (Transaction transaction) async {}),
  ]);
  Database db =
      await SqfliteDatabaseLoader(migrationManager).open('recipe-lib');

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AuthProvider()),
      ChangeNotifierProvider(create: (context) => DatabaseProvider(db)),
    ],
    child: MaterialApp(
      title: 'Recipe.Lib',
      theme: createTheme(),
      home: const AcReactiveFormConfig(child: RecipeLibSwitch()),
    ),
  ));
}
