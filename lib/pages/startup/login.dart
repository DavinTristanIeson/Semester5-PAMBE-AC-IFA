import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/pages/home/main.dart';
import 'package:pambe_ac_ifa/pages/login/login.dart';
import 'package:pambe_ac_ifa/pages/login/register.dart';
import 'package:pambe_ac_ifa/pages/startup/components.dart';

class StartupLoginScreen extends StatelessWidget {
  const StartupLoginScreen({super.key});

  Widget buildButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                context.navigator.push(MaterialPageRoute(
                    builder: (context) => const LoginScreen()));
              },
              child: const Text(
                'Login',
              ),
            ),
            const SizedBox(width: AcSizes.space),
            ElevatedButton(
              onPressed: () {
                context.navigator.push(MaterialPageRoute(
                    builder: (context) => const RegisterScreen()));
              },
              child: const Text(
                'Register',
              ),
            ),
          ],
        ),
        const SizedBox(height: AcSizes.space),
        TextButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const HomeScreen()));
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.tertiary,
            ),
            child:  Text("screen/startup/login/skip_sign".i18n()))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(114, 94, 84, 100),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const RecipeLibLogoTitle(),
              const SizedBox(height: 10),
               StartupMessageBoard(
                  text:
                      "screen/startup/login/share_recipes".i18n()),
              const SizedBox(height: AcSizes.lg),
              buildButtons(context),
              const SizedBox(height: AcSizes.lg),
            ],
          ),
        ),
      ),
    );
  }
}
