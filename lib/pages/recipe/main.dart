import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/components/function/user_controlled_data_scroll.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/recipe/renderer.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  Future<bool> recipeStepScrollLogic(
      StreamSink<RecipeStep> sink, Iterator<RecipeStep> iterator) async {
    bool hasNext = true;
    while (hasNext) {
      try {
        sink.add(iterator.current);
      } on TypeError catch (_) {
        hasNext = iterator.moveNext();
        continue;
      }

      hasNext = iterator.moveNext();
      if (!hasNext || iterator.current.type == RecipeStepVariant.regular) {
        await Future.delayed(const Duration(milliseconds: 300));
        break;
      }
      await Future.delayed(const Duration(milliseconds: 800));
    }
    return hasNext;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const OnlyReturnAppBar(),
        body: UserControlledDataScroll(
          data: [
            RecipeStep("Start Tip", type: RecipeStepVariant.tip),
            RecipeStep("Step 1"),
            RecipeStep("Step 2\nDescription\nDescription 2", imagePath: "Test"),
            RecipeStep("Tip", type: RecipeStepVariant.tip),
            RecipeStep("Step 3"),
            RecipeStep("Step 4", timer: const Duration(seconds: 5)),
            RecipeStep("Warning", type: RecipeStepVariant.warning),
            RecipeStep("Step 5",
                imagePath: "Test", timer: const Duration(seconds: 5)),
          ].iterator,
          next: recipeStepScrollLogic,
          builder: (context, stream, next) {
            return RecipeStepRenderer(stream: stream, next: next);
          },
        ));
  }
}
