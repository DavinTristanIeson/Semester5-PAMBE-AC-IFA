import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/app/confirmation.dart';
import 'package:pambe_ac_ifa/components/app/snackbar.dart';
import 'package:pambe_ac_ifa/components/display/future.dart';
import 'package:pambe_ac_ifa/components/display/recipe_card.dart';
import 'package:pambe_ac_ifa/components/display/some_items_scroll.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/controllers/local_recipe.dart';
import 'package:pambe_ac_ifa/controllers/recipe.dart';
import 'package:pambe_ac_ifa/controllers/sync_recipe.dart';
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
                  positiveText: Either.right(
                      "screen/library/components/sections/remove_bookmark"
                          .i18n()),
                  message: Either.right(
                      "screen/library/components/sections/remove_bookmark_extra"
                          .i18n()),
                  context: context);
            });
      },
      icon: const Icon(Icons.bookmark_remove),
      child: Text("screen/library/components/sections/remove".i18n()),
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
        header:
            Either.right("screen/library/components/sections/bookmark".i18n()),
        viewMoreButton: Either.right(() {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SearchScreen(
                    sortBy: SortBy.descending(RecipeSortBy.bookmarkedDate),
                    filterBy: RecipeFilterBy.bookmarkedBy(userId),
                  )));
        }));
  }
}

class LibraryLocalRecipesSection extends StatefulWidget {
  const LibraryLocalRecipesSection({super.key});

  @override
  State<LibraryLocalRecipesSection> createState() =>
      _LibraryLocalRecipesSectionState();
}

class _LibraryLocalRecipesSectionState
    extends State<LibraryLocalRecipesSection> {
  Future<void> syncAll(BuildContext context) async {
    bool isAccept = false;
    final messenger = AcSnackbarMessenger.of(context);
    final uid = context.read<AuthProvider>().user!.uid;
    final syncRecipeService = context.read<SyncAllRecipesService>();
    await showDialog(
        context: context,
        builder: (context) {
          return SimpleConfirmationDialog(
              onConfirm: () {
                isAccept = true;
              },
              context: context,
              title: Either.right(
                  "screen/library/components/sections/sync_confirmation"
                      .i18n()),
              message: Either.right(
                  "screen/library/components/sections/sync_confirmation_extra"
                      .i18n()),
              positiveText: Either.right(
                  "screen/library/components/sections/sync_confirmation_extra_extra"
                      .i18n()));
        });
    if (!isAccept) return;
    // ignore: use_build_context_synchronously
    await showBlockingDialog(context, () async {
      await syncRecipeService.run((uid: uid));
      messenger.sendSuccess(
          "screen/library/components/sections/sync_successfully".i18n());
    });
    setState(() {});
  }

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
              label: Text("screen/library/components/sections/edit".i18n()),
            ),
          );
        },
        itemConstraints:
            BoxConstraints.tight(RecipeCard.getDefaultImageSize(context)),
        header: Either.right(
            "screen/library/components/sections/your_recipe".i18n()),
        viewMoreButton: Either.left(Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FutureIconButton(
              icon: const Icon(Icons.sync),
              style:
                  IconButton.styleFrom(foregroundColor: context.colors.primary),
              onPressed: () => syncAll(context),
            ),
            SampleScrollSection.buildDefaultSecondaryAction(
                context: context,
                onPressed: () {
                  context.navigator.push(MaterialPageRoute(
                      builder: (context) => SearchScreen(
                            sortBy: SortBy.descending(RecipeSortBy.createdDate),
                            filterBy: RecipeFilterBy.local,
                          )));
                }),
          ],
        )));
  }
}
