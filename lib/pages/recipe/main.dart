import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/models/review.dart';
import 'package:pambe_ac_ifa/models/user.dart';
import 'package:pambe_ac_ifa/pages/recipe/info.dart';

class RecipeScreen extends StatelessWidget {
  final String id;
  final RecipeSource source;
  const RecipeScreen(
      {super.key, required this.id, this.source = RecipeSource.online});

  @override
  Widget build(BuildContext context) {
    return RecipeInfoScreen(
        recipe: RecipeModel(
          id: '0',
          createdAt: DateTime.now(),
          creator: UserModel(
              id: "0",
              name: "User",
              email: "placeholder@email.com",
              imagePath: "https://www.google.com"),
          description: "Description",
          steps: [
            RecipeStep("Start Tip", type: RecipeStepVariant.tip),
            RecipeStep("Step 1"),
            RecipeStep("Step 2\nDescription\nDescription 2", imagePath: "Test"),
            RecipeStep("Tip", type: RecipeStepVariant.tip),
            RecipeStep("Step 3"),
            RecipeStep("Step 4", timer: const Duration(seconds: 5)),
            RecipeStep("Warning", type: RecipeStepVariant.warning),
            RecipeStep("Step 5",
                imagePath: "Test", timer: const Duration(seconds: 5)),
          ],
          title: "Recipe Title",
          imagePath: "",
          imageSource: ExternalImageSource.local,
        ),
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
                content: "Rating" * 50)));
  }
}
