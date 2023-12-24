import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/validation.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/controllers/delete_account.dart';
import 'package:pambe_ac_ifa/controllers/local_recipe.dart';
import 'package:pambe_ac_ifa/controllers/notification.dart';
import 'package:pambe_ac_ifa/controllers/recipe.dart';
import 'package:pambe_ac_ifa/controllers/review.dart';
import 'package:pambe_ac_ifa/controllers/sync_recipe.dart';
import 'package:pambe_ac_ifa/controllers/user.dart';
import 'package:pambe_ac_ifa/database/firebase/auth.dart';
import 'package:pambe_ac_ifa/database/firebase/bookmark.dart';
import 'package:pambe_ac_ifa/database/firebase/lib/images.dart';
import 'package:pambe_ac_ifa/database/firebase/notification.dart';
import 'package:pambe_ac_ifa/database/firebase/recipe.dart';
import 'package:pambe_ac_ifa/database/firebase/review.dart';
import 'package:pambe_ac_ifa/database/firebase/user.dart';
import 'package:pambe_ac_ifa/database/shared_preferences/keys.dart';
import 'package:pambe_ac_ifa/database/sqflite/lib/image.dart';
import 'package:pambe_ac_ifa/database/sqflite/tables/recipe.dart';
import 'package:pambe_ac_ifa/database/sqflite/tables/recipe_images.dart';
import 'package:pambe_ac_ifa/init.dart';
import 'package:pambe_ac_ifa/locale.dart';
import 'package:pambe_ac_ifa/modules/admanager.dart';
import 'package:pambe_ac_ifa/switch.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sqflite/sqflite.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localization/localization.dart';

List<String> testDeviceIds = ['F28159D58B6A0EDFB83F2050EE7EE431'];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  RequestConfiguration configuration =
      RequestConfiguration(testDeviceIds: testDeviceIds);
  MobileAds.instance.updateRequestConfiguration(configuration);
  AdManager.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Database db = await initializeSqfliteDatabase(override: false);
  final recipeTable = RecipeTable(
    db,
    imageManager:
        LocalRecipeImageManager(imageManager: LocalFileImageManager()),
  );
  compute((token) {
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    recipeTable.cleanupUnusedImages();
  }, ServicesBinding.rootIsolateToken!);

  final userManager = FirebaseUserManager(
      imageManager: FirebaseImageManager(storagePath: 'user'));
  final recipeManager = FirebaseRecipeManager(
      userManager: userManager,
      bookmarkManager: FirebaseRecipeBookmarkManager(),
      viewManager: FirebaseRecipeViewManager(),
      imageManager: FirebaseImageManager(storagePath: "recipes"));
  final authManager = FirebaseAuthManager();
  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (context) => AuthProvider(authManager: authManager)),
          ProxyProvider<AuthProvider, NotificationController>(
            create: (context) => NotificationController(
                notificationManager: FirebaseNotificationManager(),
                userId: null),
            update: AuthProvider.registerUidToProvider,
          ),
          ChangeNotifierProxyProvider<AuthProvider, UserController>(
            create: (context) => UserController(userManager: userManager),
            update: AuthProvider.registerUidToProvider,
          ),
          ChangeNotifierProxyProvider<AuthProvider, RecipeController>(
            create: (context) => RecipeController(
                bookmarkManager: recipeManager.bookmarkManager,
                viewManager: recipeManager.viewManager,
                recipeManager: recipeManager,
                userId: null),
            update: AuthProvider.registerUidToProvider,
          ),
          ChangeNotifierProxyProvider<AuthProvider, LocalRecipeController>(
            create: (context) =>
                LocalRecipeController(recipeTable: recipeTable),
            update: AuthProvider.registerUidToProvider,
          ),
          ChangeNotifierProxyProvider<AuthProvider, ReviewController>(
            create: (context) => ReviewController(
                reviewManager: FirebaseReviewManager(
                    userManager: userManager, recipeManager: recipeManager)),
            update: AuthProvider.registerUidToProvider,
          ),
          Provider(create: (context) {
            return DeleteAccountService(
                recipeManager: recipeManager,
                localRecipeManager: recipeTable,
                userManager: userManager,
                authManager: authManager);
          }),
          Provider(
            create: (context) {
              return SyncRecipeService(
                  recipeManager: recipeManager,
                  localRecipeManager: recipeTable);
            },
          ),
          Provider(
            create: (context) {
              return SyncAllRecipesService(
                  recipeManager: recipeManager,
                  localRecipeManager: recipeTable);
            },
          ),
        ],
        child: const AcReactiveFormConfig(
            child: LocaleManager(child: RecipeLibApp()))),
  );
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
    LocalJsonLocalization.delegate.directories = ['assets/i18n'];
    final language = LocaleService.of(context).language;
    return MaterialApp(
      title: 'Recipe.Lib',
      theme: createTheme(),
      home: const RecipeLibSwitch(),
      locale: language.locale,
      supportedLocales: PreferredLanguage.values.map((e) => e.locale),
      localizationsDelegates: [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        LocalJsonLocalization.delegate,
      ],
    );
  }
}
