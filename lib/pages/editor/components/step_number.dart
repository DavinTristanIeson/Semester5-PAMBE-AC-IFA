import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';

import '../../../common/constants.dart';

class StepNumber extends StatelessWidget {
  final RecipeStepVariant variant;
  final int number;
  static const double defaultDiameter = 48.0;
  const StepNumber(
      {super.key,
      required this.number,
      this.variant = RecipeStepVariant.regular});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(AcSizes.brCircle),
        color: variant.primaryColor,
      ),
      constraints: const BoxConstraints(
        maxHeight: StepNumber.defaultDiameter,
        minHeight: StepNumber.defaultDiameter,
        minWidth: StepNumber.defaultDiameter,
      ),
      padding: const EdgeInsets.all(AcSizes.md),
      child: Center(
          child: switch (variant) {
        RecipeStepVariant.regular =>
          Text(number.toString(), style: AcTypography.header),
        RecipeStepVariant.tip => const Icon(
            Icons.error_outline,
            color: Colors.black,
          ),
        RecipeStepVariant.warning =>
          const Icon(Icons.warning_amber, color: Colors.black),
      }),
    );
  }
}
