import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/pages/editor/main.dart';
import 'package:pambe_ac_ifa/providers/auth.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:reactive_forms/reactive_forms.dart';

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
        useMaterial3: true,
        fontFamily: "Roboto",
        appBarTheme: const AppBarTheme(
          backgroundColor: AcColors.secondary,
          foregroundColor: AcColors.primary,
          elevation: AcSizes.md,
          centerTitle: true,
          titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: AcColors.primary,
              fontSize: AcSizes.fontBig),
        ));
  }

  List<SingleChildWidget> buildProviders() {
    return [
      ChangeNotifierProvider(create: (context) => AuthProvider()),
    ];
  }

  ReactiveFormConfig configureReactiveForm({required Widget child}) {
    return ReactiveFormConfig(
      validationMessages: {
        ValidationMessage.required: (error) => "Field must not be empty",
        ValidationMessage.equals: (error) => "Field should be equal to $error",
        ValidationMessage.maxLength: (error) =>
            "Field has a maximum length of $error"
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: buildProviders(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: createTheme(),
        home: configureReactiveForm(child: const RecipeEditorPage()),
      ),
    );
  }
}
