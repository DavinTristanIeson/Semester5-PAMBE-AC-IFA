import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/models/container.dart';

class SampleScrollSection extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Either<Widget, String> header;
  final Either<Widget, void Function()>? viewMoreButton;
  final BoxConstraints? constraints;
  final double space;
  const SampleScrollSection({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.constraints,
    this.space = AcSizes.space,
    required this.header,
    required this.viewMoreButton,
  });

  @override
  Widget build(BuildContext context) {
    double itemHeight = clampDouble(context.screenHeight / 2.5, 360.0, 480.0);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            header.leftOr((right) => Text(right,
                style: TextStyle(
                    fontSize: AcSizes.fontLarge,
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary))),
            if (viewMoreButton != null)
              viewMoreButton!.leftOr((right) => IconButton(
                    onPressed: right,
                    icon: const Icon(Icons.arrow_right_alt),
                    color: Theme.of(context).colorScheme.primary,
                  ))
          ],
        ),
        ConstrainedBox(
          constraints:
              constraints ?? BoxConstraints.tight(Size.fromHeight(itemHeight)),
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return Padding(
                  padding: EdgeInsets.only(right: space, bottom: AcSizes.md),
                  child: itemBuilder(context, index));
            },
            scrollDirection: Axis.horizontal,
          ),
        )
      ],
    );
  }
}
