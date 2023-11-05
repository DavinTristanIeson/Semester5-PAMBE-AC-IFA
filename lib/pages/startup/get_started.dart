import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/pages/startup/components.dart';

class StartupGetStartedScreen extends StatelessWidget {
  final void Function() next;
  const StartupGetStartedScreen({super.key, required this.next});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration:
            const BoxDecoration(gradient: AcDecoration.recipeLibRadialGradient),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const RecipeLibLogoTitle(),
                const SizedBox(height: AcSizes.space),
                const StartupMessageBoard(
                    text:
                        "Share your recipes with people from all over the world with Recipe.Lib"),
                const StartupMessageBoard(
                    text:
                        "View and try out recipes other cooks have uploaded to our database"),
                const StartupMessageBoard(
                    text:
                        "Give feedback to the cooks whose recipes you tried out"),
                const SizedBox(height: AcSizes.lg),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.primary,
                      side: BorderSide(color: context.colors.primary)),
                  onPressed: next,
                  icon: const Icon(Icons.arrow_right_alt),
                  label: const Text(
                    'Get Started',
                  ),
                ),
                const SizedBox(height: AcSizes.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
