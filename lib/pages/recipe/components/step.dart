import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/editor/components/step.dart';
import 'package:pambe_ac_ifa/pages/recipe/components/timer.dart';

class RecipeStepComponent extends StatelessWidget {
  final RecipeStep step;
  final int number;
  const RecipeStepComponent(
      {super.key, required this.step, required this.number});

  Widget buildImage(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(AcSizes.brInput),
        gradient: LinearGradient(colors: [
          Theme.of(context).colorScheme.tertiary,
          Color.lerp(Theme.of(context).colorScheme.tertiary,
              const Color.fromRGBO(0, 0, 0, 0.1), 0.2)!,
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 3),
      child: Image.file(step.image!, fit: BoxFit.contain),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RecipeStepWrapper(
        index: number,
        variant: step.type,
        padding: const EdgeInsets.all(0.0),
        child: Column(
          children: [
            if (step.imagePath != null) buildImage(context),
            Padding(
              padding: const EdgeInsets.only(
                left: AcSizes.xl,
                top: AcSizes.lg + AcSizes.sm,
                right: AcSizes.md,
                bottom: AcSizes.lg,
              ),
              child: buildContent(),
            ),
          ],
        ));
  }

  Column buildContent() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              step.content,
              style: const TextStyle(
                  fontSize: AcSizes.fontEmphasis, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        if (step.timer != null) RecipeStepTimer(duration: step.timer!),
      ],
    );
  }
}
