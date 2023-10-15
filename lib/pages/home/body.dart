import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'package:pambe_ac_ifa/components/display/recipe_card.dart';
import 'package:pambe_ac_ifa/components/display/some_items_scroll.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/models/user.dart';
import 'package:pambe_ac_ifa/pages/recipe/components/review.dart';
import 'package:pambe_ac_ifa/pages/search/main.dart';

class HomePageBody extends StatelessWidget {
  static RecipeModel debugRecipe = RecipeModel(
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
  );
  const HomePageBody({super.key});

  Widget buildRecentRecipes(BuildContext context) {
    return SampleScrollSection(
        itemCount: 3,
        itemBuilder: (context, index) {
          return RecipeCard(recipe: debugRecipe);
        },
        header: Either.right("Recents"),
        viewMoreButton: Either.right(() {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SearchScreen()));
        }));
  }

  Widget buildTrendingRecipes(BuildContext context) {
    return SampleScrollSection(
        itemCount: 3,
        itemBuilder: (context, index) {
          return RecipeCard(recipe: debugRecipe);
        },
        header: Either.right("Trending"),
        viewMoreButton: Either.right(() {
          context.navigator.push(
              MaterialPageRoute(builder: (context) => const SearchScreen()));
        }));
  }

  Widget buildLatestReviews(BuildContext context) {
    return SampleScrollSection(
        itemCount: 5,
        constraints: BoxConstraints.tight(
            Size.fromHeight(context.relativeHeight(1 / 5, 140.0, 180.0))),
        itemBuilder: (context, index) {
          return ReviewCard(
            rating: 3.5,
            reviewer: debugRecipe.creator!,
            reviewedAt: DateTime.now(),
            content: Either.right("Review"),
          );
        },
        header: Either.right("Latest Reviews"),
        viewMoreButton: null);
  }

  @override
  Widget build(BuildContext context) {
    const EdgeInsets edgeInsets = EdgeInsets.only(
        left: AcSizes.space, right: AcSizes.space, bottom: AcSizes.lg);
    return ListView(
      children: [
        Padding(
          padding: edgeInsets,
          child: buildRecentRecipes(context),
        ),
        Padding(
          padding: edgeInsets,
          child: buildTrendingRecipes(context),
        ),
        Padding(
          padding: edgeInsets,
          child: buildLatestReviews(context),
        ),
      ],
    );
  }
}
