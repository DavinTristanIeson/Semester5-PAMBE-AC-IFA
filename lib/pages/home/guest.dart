import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/database/interfaces/recipe.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/pages/home/components/sections.dart';
import 'package:pambe_ac_ifa/pages/login/login.dart';
import 'package:pambe_ac_ifa/pages/login/register.dart';
import 'package:pambe_ac_ifa/pages/search/main.dart';
import 'package:pambe_ac_ifa/pages/settings/main.dart';

class GuestHomeScreen extends StatelessWidget {
  const GuestHomeScreen({super.key});

  Widget buildTickPoint(String text) {
    return Row(
      children: [
        const Icon(Icons.check, color: AcColors.black),
        const SizedBox(width: AcSizes.md),
        Expanded(
          child: Text(
            text,
          ),
        ),
      ],
    );
  }

  Widget buildBenefitsCardTextButtons(BuildContext context) {
    return TextButtonTheme(
      data: TextButtonThemeData(
          style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.secondary,
      )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
              onPressed: () {
                context.navigator.push(MaterialPageRoute(
                    builder: (context) => const LoginScreen()));
              },
              child: Text("screen/home/guest/login".i18n())),
          TextButton(
              onPressed: () {
                context.navigator.push(MaterialPageRoute(
                    builder: (context) => const RegisterScreen()));
              },
              child: Text("screen/home/guest/register".i18n())),
        ],
      ),
    );
  }

  Widget buildBenefitsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(AcSizes.br),
          boxShadow: const [AcDecoration.shadowRegular],
          color: Theme.of(context).colorScheme.primary),
      padding: const EdgeInsets.all(AcSizes.space),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("screen/home/guest/log_or_sign".i18n(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: AcSizes.space),
          buildTickPoint("screen/home/guest/share_your_recipe".i18n()),
          buildTickPoint("screen/home/guest/feedback_recipe".i18n()),
          buildTickPoint("screen/home/guest/bookmark_recipe".i18n()),
          buildTickPoint("screen/home/guest/view_recipe".i18n()),
          buildBenefitsCardTextButtons(context),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipe.Lib"),
        actions: [
          IconButton(
              onPressed: () {
                context.navigator.push(MaterialPageRoute(builder: (context) {
                  return SearchScreen(
                      sortBy: SortBy.descending(RecipeSortBy.ratings));
                }));
              },
              icon: const Icon(Icons.search)),
          IconButton(
            onPressed: () {
              context.navigator.push(MaterialPageRoute(
                  builder: (context) => const SettingsScreen()));
            },
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(
                vertical: AcSizes.space, horizontal: AcSizes.space),
            child: HomeTrendingRecipesSection(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AcSizes.space, vertical: AcSizes.lg),
            child: buildBenefitsCard(context),
          ),
        ],
      ),
    );
  }
}
