import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/app/confirmation.dart';
import 'package:pambe_ac_ifa/components/display/future.dart';
import 'package:pambe_ac_ifa/components/display/recipe_card.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/controllers/local_recipe.dart';
import 'package:pambe_ac_ifa/controllers/recipe.dart';
import 'package:pambe_ac_ifa/database/interfaces/recipe.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/editor/main.dart';
import 'package:pambe_ac_ifa/pages/home/components/async_scroll_section.dart';
import 'package:pambe_ac_ifa/pages/search/main.dart';
import 'package:provider/provider.dart';

class LibraryBookmarkedRecipesSection extends StatelessWidget {
  const LibraryBookmarkedRecipesSection({super.key});

  Widget buildSecondaryAction(BuildContext context, RecipeLiteModel data) {
    final controller = context.read<RecipeController>();
    return FutureOutlinedButton(
      onPressed: () {
        return showDialog(
            context: context,
            builder: (context) {
              return SimpleConfirmationDialog.delete(
                  onConfirm: () {
                    controller.bookmark(data.id, false);
                  },
                  positiveText: Either.right("Remove Bookmark"),
                  message: Either.right(
                      "Are you sure you want to remove this bookmark?"),
                  context: context);
            });
      },
      icon: const Icon(Icons.bookmark_remove),
      child: const Text("Remove"),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecipeController>();
    final userId = context.watch<AuthProvider>().user!.uid;
    return AsyncApiSampleScrollSection(
        future: controller.getBookmarkedRecipes(),
        itemBuilder: (context, data) {
          return RecipeCard(
              recipe: data,
              recipeSource: RecipeSource.remote(data.id),
              secondaryAction: buildSecondaryAction(context, data));
        },
        itemConstraints:
            BoxConstraints.tight(RecipeCard.getDefaultImageSize(context)),
        header: Either.right("Bookmarks"),
        viewMoreButton: Either.right(() {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SearchScreen(
                    sortBy: SortBy.descending(RecipeSortBy.bookmarkedDate),
                    filterBy: RecipeFilterBy.bookmarkedBy(userId),
                  )));
        }));
  }
}

class LibraryLocalRecipesSection extends StatelessWidget {
  const LibraryLocalRecipesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LocalRecipeController>();
    return AsyncApiSampleScrollSection(
        future: controller.getAll(
            searchState: RecipeSearchState(
                limit: 5, sortBy: SortBy.descending(RecipeSortBy.createdDate))),
        itemBuilder: (context, data) {
          return RecipeCard(
            recipe: data,
            recipeSource: RecipeSource.local(data.id),
            secondaryAction: OutlinedButton.icon(
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
