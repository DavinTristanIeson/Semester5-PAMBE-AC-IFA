import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/components/function/user_controlled_data_scroll.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/recipe/renderer.dart';

class RecipeViewerScreen extends StatelessWidget {
  final RecipeModel recipe;
  const RecipeViewerScreen({super.key, required this.recipe});

  Future<int?> recipeStepScrollLogic(
      StreamSink<RecipeStep> sink, int index) async {
    while (index < recipe.steps.length) {
      RecipeStep current = recipe.steps[index];
      sink.add(current);
      index++;
      RecipeStep? upcoming = recipe.steps.elementAtOrNull(index);
      if (index >= recipe.steps.length ||
          upcoming!.type == RecipeStepVariant.regular) {
        await Future.delayed(const Duration(milliseconds: 300));
        break;
      } else {
        await Future.delayed(const Duration(milliseconds: 600));
      }
    }
    return index == recipe.steps.length ? null : index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const OnlyReturnAppBar(),
        body: UserControlledDataScroll<RecipeStep>(
          next: recipeStepScrollLogic,
          builder: (context, stream, next) {
            return RecipeStepRenderer(
                stream: stream, next: next, image: recipe.image!);
          },
        ));
  }
}
