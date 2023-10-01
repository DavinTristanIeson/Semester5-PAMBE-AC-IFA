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
          Text(number.toString(), style: AcTypography.displayMedium),
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

class RecipeStepWrapper extends StatelessWidget {
  final int index;
  final RecipeStepVariant variant;
  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  const RecipeStepWrapper(
      {super.key,
      required this.index,
      required this.variant,
      required this.child,
      this.padding,
      this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: AcSizes.lg,
          right: AcSizes.lg,
          bottom: AcSizes.lg,
          left: AcSizes.lg - StepNumber.defaultDiameter / 4),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(
                top: StepNumber.defaultDiameter / 2,
                left: StepNumber.defaultDiameter / 4),
            child: Container(
                decoration: BoxDecoration(
                  boxShadow: const [AcDecoration.shadowRegular],
                  borderRadius:
                      borderRadius ?? const BorderRadius.all(AcSizes.brInput),
                  color: variant.backgroundColor,
                ),
                padding: padding ??
                    const EdgeInsets.only(
                      left: AcSizes.lg,
                      top: AcSizes.md,
                      right: AcSizes.lg,
                      bottom: AcSizes.md,
                    ),
                child: child),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: StepNumber(
              number: index,
              variant: variant,
            ),
          )
        ],
      ),
    );
  }
}
