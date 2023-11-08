import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/display/recipe_card.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/controllers/local_recipe.dart';
import 'package:pambe_ac_ifa/controllers/recipe.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/editor/main.dart';
import 'package:pambe_ac_ifa/pages/home/components/async_scroll_section.dart';
import 'package:pambe_ac_ifa/pages/search/main.dart';
import 'package:provider/provider.dart';

class LibraryBookmarkedRecipesSection extends StatelessWidget {
  const LibraryBookmarkedRecipesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecipeController>();
    final userId = context.watch<AuthProvider>().user!.uid;
    return AsyncApiSampleScrollSection(
        future: controller.getAll(RecipeSearchState(
            limit: 5,
            sortBy: SortBy.descending(RecipeSortBy.lastViewed),
            filterBy: RecipeFilterBy.bookmarkedBy(userId))),
        itemBuilder: (context, data) {
          return RecipeCard(
            recipe: data,
            secondaryAction: OutlinedButton.icon(
                style: RecipeCard.getSecondaryActionButtonStyle(context),
                onPressed: () {
                  // TODO: Unbookmark
                },
                icon: const Icon(Icons.bookmark_remove),
                label: const Text("Remove")),
          );
        },
        itemConstraints:
            BoxConstraints.tight(RecipeCard.getDefaultImageSize(context)),
        header: Either.right("Recents"),
        viewMoreButton: Either.right(() {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SearchScreen(
                    sortBy: SortBy.descending(RecipeSortBy.lastViewed),
                    filterBy: RecipeFilterBy.viewedBy(userId, viewed: true),
                  )));
        }));
  }
}

class LibraryLocalRecipesSection extends StatelessWidget {
  const LibraryLocalRecipesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LocalRecipeController>();
    final user = context.watch<AuthProvider>().user!;
    return AsyncApiSampleScrollSection(
        future: Future(() async {
          final results = await controller.getAll(
              user: user,
              searchState: RecipeSearchState(
                  limit: 5,
                  sortBy: SortBy.descending(RecipeSortBy.createdDate)));
          return ApiResult(message: 'Success', data: results);
        }),
        itemBuilder: (context, data) {
          return RecipeCard(
            recipe: data,
            recipeSource: RecipeSource.local,
            secondaryAction: OutlinedButton.icon(
              style: RecipeCard.getSecondaryActionButtonStyle(context),
              onPressed: () {
                context.navigator.push(MaterialPageRoute(
                    builder: (context) => RecipeEditorScreen(
                          recipeId: data.id,
                        )));
              },
              icon: const Icon(Icons.edit),
              label: const Text("Edit"),
            ),
          );
        },
        itemConstraints:
            BoxConstraints.tight(RecipeCard.getDefaultImageSize(context)),
        header: Either.right("Your Recipes"),
        viewMoreButton: Either.right(() {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SearchScreen(
                    sortBy: SortBy.descending(RecipeSortBy.createdDate),
                    filterBy: RecipeFilterBy.local,
                  )));
        }));
  }
}
