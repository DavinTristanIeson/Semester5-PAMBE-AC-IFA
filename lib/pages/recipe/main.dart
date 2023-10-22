import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/components/app/snackbar.dart';
import 'package:pambe_ac_ifa/components/display/notice.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/controllers/local_recipe.dart';
import 'package:pambe_ac_ifa/controllers/recipe.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/models/review.dart';
import 'package:pambe_ac_ifa/models/user.dart';
import 'package:pambe_ac_ifa/pages/recipe/info.dart';
import 'package:provider/provider.dart';

class RecipeScreen extends StatelessWidget with SnackbarMessenger {
  final String id;
  final RecipeSource source;
  const RecipeScreen(
      {super.key, required this.id, this.source = RecipeSource.online});

  Future<RecipeModel?> getRecipe(BuildContext context) async {
    try {
      if (source == RecipeSource.local) {
        final controller = context.watch<LocalRecipeController>();
        final user = context.watch<AuthProvider>().user!;
        return controller.get(int.parse(id), user: user);
      } else {
        final controller = context.watch<RecipeController>();
        final result = await controller.get(id);
        return result.data;
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
                        "We were unable to find any recipe associated with ID: $id")),
              );
            }
            return RecipeInfoScreen(
                recipe: snapshot.data!,
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
