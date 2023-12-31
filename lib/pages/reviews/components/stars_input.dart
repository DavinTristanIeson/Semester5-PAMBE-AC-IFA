import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';

class ReviewStarsInput extends StatelessWidget {
  final int value;
  final double iconSize;
  final void Function(int value) onChanged;
  ReviewStarsInput(
      {super.key,
      required int value,
      required this.onChanged,
      this.iconSize = 24})
      // ignore: unnecessary_this
      : this.value = min(5, max(0, value));

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
          5,
          (index) => IconButton(
              onPressed: () => onChanged(index + 1),
              icon: index < value
                  ? Icon(
                      Icons.star,
                      color: context.colors.primary,
                      size: iconSize,
                    )
                  : Icon(Icons.star_outline,
                      color: context.colors.tertiary, size: iconSize))),
    );
  }
}
