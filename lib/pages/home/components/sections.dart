import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/display/recipe_card.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/controllers/recipe.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/home/components/async_scroll_section.dart';
import 'package:pambe_ac_ifa/pages/search/main.dart';
import 'package:provider/provider.dart';

class HomeRecentRecipesSection extends StatelessWidget {
  const HomeRecentRecipesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecipeController>();
    final userId = context.watch<AuthProvider>().user!.uid;
    return AsyncApiSampleScrollSection(
        future: controller.getAll(RecipeSearchState(
            limit: 5,
            sortBy: SortBy.descending(RecipeSortBy.lastViewed),
            filterBy: RecipeFilterBy.viewedBy(userId))),
        itemBuilder: (context, data) => RecipeCard(recipe: data),
        header: Either.right("Recents"),
        viewMoreButton: Either.right(() {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SearchScreen(
                    sortBy: SortBy.descending(RecipeSortBy.lastViewed),
                    filterBy: RecipeFilterBy.viewedBy(userId, viewed: true),
                  )));
        }),
        itemConstraints:
            BoxConstraints.tight(RecipeCard.getDefaultImageSize(context)));
  }
}

class HomeTrendingRecipesSection extends StatelessWidget {
  const HomeTrendingRecipesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecipeController>();
    final userId = context.watch<AuthProvider>().user?.uid;
    return AsyncApiSampleScrollSection(
        future: controller.getAll(RecipeSearchState(
          sortBy: SortBy.descending(RecipeSortBy.ratings),
          filterBy: RecipeFilterBy.viewedBy(userId),
        )),
        itemBuilder: (context, data) => RecipeCard(recipe: data),
        header: Either.right("Trending"),
        viewMoreButton: Either.right(() {
          context.navigator.push(MaterialPageRoute(
              builder: (context) => SearchScreen(
                    sortBy: SortBy.descending(RecipeSortBy.ratings),
                    filterBy: userId == null
                        ? null
                        : RecipeFilterBy.viewedBy(userId, viewed: false),
                  )));
        }),
        itemConstraints:
            BoxConstraints.tight(RecipeCard.getDefaultImageSize(context)));
  }
}
