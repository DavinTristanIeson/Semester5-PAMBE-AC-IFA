import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/database/interfaces/recipe.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/pages/home/components/sections.dart';
import 'package:pambe_ac_ifa/pages/login/login.dart';
import 'package:pambe_ac_ifa/pages/login/register.dart';
import 'package:pambe_ac_ifa/pages/search/main.dart';

class GuestHomeScreen extends StatelessWidget {
  const GuestHomeScreen({super.key});

  Widget buildTickPoint(String text) {
    return Row(
      children: [
        const Icon(Icons.check, color: AcColors.black),
        const SizedBox(width: AcSizes.md),
        Text(text),
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
              child: const Text("Login")),
          TextButton(
              onPressed: () {
                context.navigator.push(MaterialPageRoute(
                    builder: (context) => const RegisterScreen()));
              },
              child: const Text("Register")),
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
          const Text("Log in or sign up to get the following benefits",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: AcSizes.space),
          buildTickPoint("Share your own recipes with the community"),
          buildTickPoint("Leave constructive feedback on other recipes"),
          buildTickPoint("Bookmark your favorite recipes"),
          buildTickPoint("View recipes you've used before"),
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
              icon: const Icon(Icons.search))
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
