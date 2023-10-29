import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/components/app/snackbar.dart';
import 'package:pambe_ac_ifa/components/display/notice.dart';
import 'package:pambe_ac_ifa/controllers/local_recipe.dart';
import 'package:pambe_ac_ifa/controllers/recipe.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/models/review.dart';
import 'package:pambe_ac_ifa/models/user.dart';
import 'package:pambe_ac_ifa/pages/recipe/info.dart';
import 'package:provider/provider.dart';

class RecipeScreen extends StatelessWidget with SnackbarMessenger {
  final RecipeSource source;
  const RecipeScreen({super.key, required this.source});

  Future<AbstractRecipeLiteModel?> getRecipe(BuildContext context) async {
    try {
      if (source.type == RecipeSourceType.local) {
        final controller = context.watch<LocalRecipeController>();
        return controller.get(source.localId!);
      } else {
        final controller = context.watch<RecipeController>();
        final result = await controller.get(source.remoteId!);
        return result;
      }
    } catch (e) {
      sendError(context, e.toString());
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const OnlyReturnAppBar(),
      body: FutureBuilder(
          future: getRecipe(context),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(AcSizes.space),
                child: EmptyView(
                    content: Either.right(
                        "We were unable to find any recipe associated with ID: ${source.localId ?? source.remoteId}")),
              );
            }
            List<AbstractRecipeStepModel> steps = snapshot.data is RecipeModel
                ? (snapshot.data as RecipeModel).steps
                : (snapshot.data is LocalRecipeModel)
                    ? (snapshot.data as LocalRecipeModel).steps
                    : [];
            return RecipeInfoScreen(
                recipe: snapshot.data!,
                steps: steps,
                reviews: List.generate(
                    5,
                    (i) => ReviewModel(
                        rating: 3.5,
                        reviewedAt: DateTime.now(),
                        reviewer: UserModel(
                            id: "0",
                            name: "User",
                            email: "placeholder@email.com",
                            imagePath: "https://www.google.com"),
                        content: "Rating" * 10)));
          }),
    );
  }
}
