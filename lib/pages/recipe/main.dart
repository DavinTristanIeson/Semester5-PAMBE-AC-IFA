import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/components/function/user_controlled_data_scroll.dart';
import 'package:pambe_ac_ifa/pages/recipe/renderer.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return UserControlledDataScroll<int>(
        data: Iterable.generate(10, (x) => x).iterator,
        next: (sink, iterator) async {
          int idx = 0;
          bool hasNext = true;
          while (idx < 3 && (hasNext = iterator.moveNext())) {
            sink.add(iterator.current);
            idx++;
            await Future.delayed(const Duration(seconds: 1));
          }
          return hasNext;
        },
        builder: (context, stream, next) {
          return RecipeStepRenderer(stream: stream, next: next);
        });
  }
}
