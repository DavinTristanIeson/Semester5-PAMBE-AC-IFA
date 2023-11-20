import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/validation.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/controllers/local_recipe.dart';
import 'package:pambe_ac_ifa/controllers/notification.dart';
import 'package:pambe_ac_ifa/controllers/recipe.dart';
import 'package:pambe_ac_ifa/controllers/review.dart';
import 'package:pambe_ac_ifa/controllers/user.dart';
import 'package:pambe_ac_ifa/database/firebase/auth.dart';
import 'package:pambe_ac_ifa/database/firebase/lib/images.dart';
import 'package:pambe_ac_ifa/database/firebase/notification.dart';
import 'package:pambe_ac_ifa/database/firebase/recipe.dart';
import 'package:pambe_ac_ifa/database/firebase/review.dart';
import 'package:pambe_ac_ifa/database/firebase/user.dart';
import 'package:pambe_ac_ifa/database/sqflite/lib/image.dart';
import 'package:pambe_ac_ifa/database/sqflite/tables/recipe.dart';
import 'package:pambe_ac_ifa/database/sqflite/tables/recipe_images.dart';
import 'package:pambe_ac_ifa/init.dart';
import 'package:pambe_ac_ifa/switch.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sqflite/sqflite.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Database db = await initializeSqfliteDatabase(override: false);
  final recipeTable = RecipeTable(
    db,
    imageManager:
        LocalRecipeImageManager(imageManager: LocalFileImageManager()),
  );
  recipeTable.cleanupUnusedImages();

  final userManager = FirebaseUserManager(
      imageManager: FirebaseImageManager(storagePath: 'user'));
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
          create: (context) =>
              AuthProvider(authManager: FirebaseAuthManager())),
      ProxyProvider<AuthProvider, NotificationController>(
        create: (context) => NotificationController(
            notificationManager: FirebaseNotificationManager(), userId: null),
        update: AuthProvider.registerUidToProvider,
      ),
      ChangeNotifierProxyProvider<AuthProvider, UserController>(
        create: (context) => UserController(
            userManager: FirebaseUserManager(
                imageManager: FirebaseImageManager(storagePath: "user"))),
        update: AuthProvider.registerUidToProvider,
      ),
      ChangeNotifierProxyProvider<AuthProvider, RecipeController>(
        create: (context) => RecipeController(
            recipeManager: FirebaseRecipeManager(FirebaseFirestore.instance,
                userManager: userManager,
                imageManager: FirebaseImageManager(storagePath: "recipes")),
            userId: null),
        update: AuthProvider.registerUidToProvider,
      ),
      ChangeNotifierProxyProvider<AuthProvider, LocalRecipeController>(
        create: (context) => LocalRecipeController(recipeTable: recipeTable),
        update: AuthProvider.registerUidToProvider,
      ),
      ChangeNotifierProxyProvider<AuthProvider, ReviewController>(
        create: (context) =>
            ReviewController(reviewManager: FirebaseReviewManager()),
        update: AuthProvider.registerUidToProvider,
      )
    ],
    child: const AcReactiveFormConfig(child: RecipeLibApp()),
  ));
}

class RecipeLibApp extends StatelessWidget {
  const RecipeLibApp({super.key});

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
        outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
                foregroundColor: AcColors.secondary,
                side: const BorderSide(color: AcColors.secondary))),
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
          surfaceTintColor: Colors.transparent,
          elevation: AcSizes.md,
          centerTitle: true,
          titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: AcColors.primary,
              fontSize: AcSizes.fontLarge),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            unselectedItemColor: AcColors.background,
            backgroundColor: AcColors.secondary,
            showUnselectedLabels: false,
            unselectedIconTheme: IconThemeData(color: AcColors.hoverColor)));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe.Lib',
      theme: createTheme(),
      home: const RecipeLibSwitch(),
    );
  }
}
