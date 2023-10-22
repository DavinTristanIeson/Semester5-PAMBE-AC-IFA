import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/editor/components/step.dart';
import 'package:pambe_ac_ifa/pages/recipe/components/timer.dart';

class RecipeStepComponent extends StatelessWidget {
  final RecipeStepModel step;
  final int number;
  const RecipeStepComponent(
      {super.key, required this.step, required this.number});

  @override
  Widget build(BuildContext context) {
    return RecipeStepWrapper(
        index: number,
        variant: step.type,
        padding: const EdgeInsets.all(AcSizes.md),
        borderRadius: const BorderRadius.all(AcSizes.br),
        child: Padding(
          padding: const EdgeInsets.only(
            left: AcSizes.lg + AcSizes.md,
            top: AcSizes.space,
            right: AcSizes.md,
            bottom: AcSizes.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (step.image != null)
                AcImageContainer(
                  borderRadius: const BorderRadius.all(AcSizes.br),
                  constraints: BoxConstraints.loose(
                      Size.fromHeight(MediaQuery.of(context).size.height / 4)),
                  child: MaybeImage(image: step.image!),
                ),
              buildContent(),
            ],
          ),
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
