import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/models/review.dart';
import 'package:pambe_ac_ifa/models/user.dart';
import 'package:pambe_ac_ifa/pages/recipe/info.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return RecipeInfoPage(
        recipe: Recipe(
          creator: User(
              id: "0",
              name: "User",
              email: "placeholder@email.com",
              onlineImage: "https://www.google.com"),
          description: "Description",
          steps: [
            RecipeStep("Start Tip", type: RecipeStepVariant.tip),
            RecipeStep("Step 1"),
            RecipeStep("Step 2\nDescription\nDescription 2",
                localImage: "Test"),
            RecipeStep("Tip", type: RecipeStepVariant.tip),
            RecipeStep("Step 3"),
            RecipeStep("Step 4", timer: const Duration(seconds: 5)),
            RecipeStep("Warning", type: RecipeStepVariant.warning),
            RecipeStep("Step 5",
                localImage: "Test", timer: const Duration(seconds: 5)),
          ],
          title: "Recipe Title",
          localImage: "",
        ),
        reviews: List.generate(
            5,
            (i) => Review(
                rating: 3.5,
                reviewedAt: DateTime.now(),
                reviewer: User(
                    id: "0",
                    name: "User",
                    email: "placeholder@email.com",
                    onlineImage: "https://www.google.com"),
                content: "Rating" * 50)));
  }
}
