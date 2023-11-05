import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';

class TextItem extends StatelessWidget {
  final String firstText;
  final String secondText;

  const TextItem(
      {super.key, required this.firstText, required this.secondText});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          firstText,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: context.colors.primary,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(secondText),
      ],
    );
  }
}
