import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/display/recipe_card.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/controllers/local_recipe.dart';
import 'package:pambe_ac_ifa/controllers/recipe.dart';
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
    final user = context.watch<AuthProvider>().user!;
    return AsyncApiSampleScrollSection(
        future: controller.getAll(
            searchState: RecipeSearchState(
                limit: 5, sortBy: SortBy.descending(RecipeSortBy.createdDate))),
        itemBuilder: (context, data) => RecipeCard(
              recipe: data,
              recipeSource: RecipeSource.local(data.id),
              secondaryAction: null,
            ),
        header: Either.right("Recipes by ${user.name}"),
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
  const UserRecipesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<RecipeController>();
    final user = context.watch<AuthProvider>().user!;
    return AsyncApiSampleScrollSection(
        future: controller.getRecipesByUser(user.id),
        itemBuilder: (context, data) => RecipeCard(
              recipe: data,
              recipeSource: RecipeSource.remote(data.id),
            ),
        header: Either.right("Recipes by ${user.name}"),
        viewMoreButton: Either.right(() {
          context.navigator.push(MaterialPageRoute(
              builder: (context) => SearchScreen(
                    filterBy: RecipeFilterBy.createdByUser(user.id),
                  )));
        }),
        itemConstraints:
            BoxConstraints.tight(RecipeCard.getDefaultImageSize(context)));
  }
}
