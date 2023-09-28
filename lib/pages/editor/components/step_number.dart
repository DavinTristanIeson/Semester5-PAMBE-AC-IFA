import 'package:flutter/material.dart';

import '../../../common/constants.dart';

class StepNumber extends StatelessWidget {
  final int number;
  static const double defaultDiameter = 48.0;
  const StepNumber({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(AcSizes.brCircle),
        color: Theme.of(context).colorScheme.primary,
      ),
      constraints: const BoxConstraints(
        maxHeight: StepNumber.defaultDiameter,
        minHeight: StepNumber.defaultDiameter,
        minWidth: StepNumber.defaultDiameter,
      ),
      padding: const EdgeInsets.all(AcSizes.md),
      child: Center(
          child: Text(number.toString(),
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AcSizes.fontBig,
                  color: Colors.black))),
    );
  }
}
