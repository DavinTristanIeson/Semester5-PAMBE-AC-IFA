import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/display/recipe_card.dart';
import 'package:pambe_ac_ifa/controllers/local_recipe.dart';
import 'package:pambe_ac_ifa/controllers/recipe.dart';
import 'package:pambe_ac_ifa/controllers/user.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/home/components/async_scroll_section.dart';
import 'package:pambe_ac_ifa/pages/search/main.dart';
import 'package:provider/provider.dart';

class LocalUserRecipesSection extends StatelessWidget {
  const LocalUserRecipesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<LocalRecipeController>();
    return AsyncApiSampleScrollSection(
        future: controller.getAll(
            searchState: RecipeSearchState(
                limit: 5, sortBy: SortBy.descending(RecipeSortBy.createdDate))),
        itemBuilder: (context, data) => RecipeCard(
              recipe: data,
              recipeSource: RecipeSource.local(data.id),
              secondaryAction: null,
            ),
        header: Either.right("Your Recipes"),
        viewMoreButton: Either.right(() {
          context.navigator.push(MaterialPageRoute(
              builder: (context) => SearchScreen(
                    filterBy: RecipeFilterBy.local,
                  )));
        }),
        itemConstraints:
            BoxConstraints.tight(RecipeCard.getDefaultImageSize(context)));
  }
}

class UserRecipesSection extends StatelessWidget {
  final String userId;
  const UserRecipesSection({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<RecipeController>();
    final userController = context.read<UserController>();
    return AsyncApiSampleScrollSection(
        future: controller.getRecipesByUser(userId),
        itemBuilder: (context, data) => RecipeCard(
              recipe: data,
              recipeSource: RecipeSource.remote(data.id),
            ),
        header: Either.left(FutureBuilder(
            future: userController.get(userId),
            builder: (context, snapshot) {
              String text;
              if (snapshot.connectionState == ConnectionState.waiting) {
                text = "Recipes by ...";
              } else if (!snapshot.hasData) {
                text = "Recipes by an unknown user";
              } else {
                text = "Recipes by ${snapshot.data!.name}";
              }
              return Text(text,
                  style: TextStyle(
                      fontSize: AcSizes.fontLarge,
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary));
            })),
        viewMoreButton: Either.right(() {
          context.navigator.push(MaterialPageRoute(
              builder: (context) => SearchScreen(
                    filterBy: RecipeFilterBy.createdByUser(userId),
                  )));
        }),
        itemConstraints:
            BoxConstraints.tight(RecipeCard.getDefaultImageSize(context)));
  }
}
