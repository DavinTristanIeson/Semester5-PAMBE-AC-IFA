import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/components/app/snackbar.dart';
import 'package:pambe_ac_ifa/components/display/future.dart';
import 'package:pambe_ac_ifa/components/display/notice.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/controllers/local_recipe.dart';
import 'package:pambe_ac_ifa/controllers/recipe.dart';
import 'package:pambe_ac_ifa/controllers/review.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/models/review.dart';
import 'package:pambe_ac_ifa/pages/recipe/info.dart';
import 'package:provider/provider.dart';

class RecipeScreen extends StatelessWidget {
  final RecipeSource source;
  const RecipeScreen({super.key, required this.source});

  Future<AbstractRecipeLiteModel?> _getRecipe(BuildContext context) async {
    final messenger = AcSnackbarMessenger.of(context);
    try {
      if (source.type == RecipeSourceType.local) {
        final controller = context.read<LocalRecipeController>();
        return controller.get(source.localId!);
      } else {
        final controller = context.read<RecipeController>();
        final result = await controller.get(source.remoteId!);
        await controller.view(source.remoteId!);
        return result;
      }
    } catch (e) {
      messenger.sendError(e);
      rethrow;
    }
  }

  Future<List<ReviewModel>>? _getReviews(BuildContext context) {
    final reviewController = context.read<ReviewController>();
    if (source.type == RecipeSourceType.local) {
      return null;
    }
    return reviewController.getAll(
        searchState: ReviewSearchState(recipeId: source.remoteId!, limit: 5));
  }

  @override
  Widget build(BuildContext context) {
    final future = Future(() async {
      final recipeFuture = _getRecipe(context);
      final reviewsFuture = _getReviews(context);
      return (
        recipe: await recipeFuture,
        reviews: await reviewsFuture,
      );
    });
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      appBar: OnlyReturnAppBar(
        actions: [
          if (source.remoteId != null && authProvider.isLoggedIn)
            _RecipeBookmarkButton(recipeId: source.remoteId!),
        ],
      ),
      body: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(AcSizes.space),
                child:
                    ErrorView(error: Either.right(snapshot.error.toString())),
              );
            }
            if (!snapshot.hasData || snapshot.data!.recipe == null) {
              return Padding(
                padding: const EdgeInsets.all(AcSizes.space),
                child: EmptyView(
                    content: Either.right(
                        "screen/recipe/main/unable_find_recipe".i18n(
                            [(source.localId ?? source.remoteId).toString()]))),
              );
            }
            List<AbstractRecipeStepModel> steps =
                snapshot.data!.recipe is RecipeModel
                    ? (snapshot.data!.recipe as RecipeModel).steps
                    : (snapshot.data!.recipe is LocalRecipeModel)
                        ? (snapshot.data!.recipe as LocalRecipeModel).steps
                        : [];
            return RecipeInfoScreen(
                recipe: snapshot.data!.recipe!,
                steps: steps,
                reviews: snapshot.data!.reviews);
          }),
    );
  }
}

class _RecipeBookmarkButton extends StatelessWidget {
  final String recipeId;
  const _RecipeBookmarkButton({required this.recipeId});

  @override
  Widget build(BuildContext context) {
    final recipeController = context.watch<RecipeController>();
    return FutureBuilder(
        future: recipeController.isBookmarked(recipeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done ||
              !snapshot.hasData ||
              snapshot.hasError) {
            return const SizedBox();
          }
          bool isBookmarked = snapshot.data!;
          if (isBookmarked) {
            return Tooltip(
                message:
                    "screen/library/components/sections/remove_bookmark".i18n(),
                child: FutureIconButton(
                  icon:
                      Icon(Icons.bookmark_remove, color: context.colors.error),
                  onPressed: () {
                    return recipeController.bookmark(recipeId, false);
                  },
                ));
          } else {
            return Tooltip(
                message: "screen/recipe/main/add_bookmark".i18n(),
                child: FutureIconButton(
                  icon: Icon(Icons.bookmark_add, color: context.colors.primary),
                  onPressed: () {
                    return recipeController.bookmark(recipeId, true);
                  },
                ));
          }
        });
  }
}
