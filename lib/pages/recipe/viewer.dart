import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/components/function/user_controlled_data_scroll.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/recipe/renderer.dart';

class RecipeViewerPage extends StatelessWidget {
  final Recipe recipe;
  const RecipeViewerPage({super.key, required this.recipe});

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
          data: recipe.steps.iterator,
          next: recipeStepScrollLogic,
          builder: (context, stream, next) {
            return RecipeStepRenderer(
                stream: stream,
                next: next,
                image: recipe.buildImage(fit: BoxFit.cover));
          },
        ));
  }
}
