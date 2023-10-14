import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'package:pambe_ac_ifa/components/display/recipe_card.dart';
import 'package:pambe_ac_ifa/components/display/some_items_scroll.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/models/user.dart';

class GuestHomePage extends StatelessWidget {
  const GuestHomePage({super.key});

  Widget buildTrendingRecipes(BuildContext context) {
    return SampleScrollSection(
        itemCount: 3,
        itemBuilder: (context, index) {
          return RecipeCard(
              recipe: Recipe(
            id: '0',
            createdAt: DateTime.now(),
            creator: User(
                id: "0",
                name: "User",
                email: "placeholder@email.com",
                imagePath: "https://www.google.com"),
            description: "Description",
            steps: [],
            title: "Recipe Title",
            imagePath: "",
            imageSource: ExternalImageSource.local,
          ));
        },
        header: Either.right("Trending"),
        viewMoreButton: Either.right(() {
          // TODO: Search Page
        }));
  }

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
                // TODO: login
              },
              child: const Text("Login")),
          TextButton(
              onPressed: () {
                // TODO: register
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
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AcSizes.space),
            child: buildTrendingRecipes(context),
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
