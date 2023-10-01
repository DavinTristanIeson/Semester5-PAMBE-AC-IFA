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

  @override
  Widget build(BuildContext context) {
    return RecipeStepWrapper(
        index: number,
        variant: step.type,
        borderRadius: const BorderRadius.all(AcSizes.br),
        padding: const EdgeInsets.all(0.0),
        child: Column(
          children: [
            if (step.localImage != null)
              step.buildImage(
                  borderRadius: const BorderRadius.only(
                      topLeft: AcSizes.br, topRight: AcSizes.br)),
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
