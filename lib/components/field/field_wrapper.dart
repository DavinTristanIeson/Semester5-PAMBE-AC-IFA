import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';

class AcFieldWrapper extends StatelessWidget {
  final String label;
  final String? error;
  final bool required;
  final Widget child;
  const AcFieldWrapper(
      {super.key,
      required this.label,
      required this.child,
      this.error,
      this.required = false});

  Widget buildLabel(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AcSizes.brInput))),
        padding: const EdgeInsets.symmetric(
            horizontal: AcSizes.md + AcSizes.sm, vertical: AcSizes.md),
        child: Text.rich(TextSpan(children: [
          TextSpan(
              text: label, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (required)
            const TextSpan(text: "  *", style: TextStyle(color: Colors.red)),
        ])));
  }

  @override
  Widget build(BuildContext context) {
    const Radius inputRadius = Radius.circular(AcSizes.brInput);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(context),
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: inputRadius,
              bottomRight: inputRadius,
              topRight: inputRadius,
            ),
            color: Theme.of(context).colorScheme.surface,
          ),
          padding: const EdgeInsets.all(AcSizes.md + AcSizes.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              child,
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(
                      left: AcSizes.md + AcSizes.sm,
                      right: AcSizes.md + AcSizes.sm,
                      top: AcSizes.sm),
                  child: Text(error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.bold)),
                )
            ],
          ),
        ),
      ],
    );
  }
}
