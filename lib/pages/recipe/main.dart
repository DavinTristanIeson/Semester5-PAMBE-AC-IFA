import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/components/app/snackbar.dart';
import 'package:pambe_ac_ifa/components/display/notice.dart';
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
        searchState:
            ReviewSearchState(filter: ReviewFilterBy.recipe(source.remoteId)));
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
    return Scaffold(
      appBar: const OnlyReturnAppBar(),
      body: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.recipe == null) {
              return Padding(
                padding: const EdgeInsets.all(AcSizes.space),
                child: EmptyView(
                    content: Either.right(
                        "We were unable to find any recipe associated with ID: ${source.localId ?? source.remoteId}")),
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
