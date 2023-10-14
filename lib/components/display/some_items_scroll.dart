import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/models/container.dart';

class SampleScrollSection extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Either<Widget, String> header;
  final Either<Widget, void Function()> viewMoreButton;
  final BoxConstraints constraints;
  final double space;
  const SampleScrollSection({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.constraints = const BoxConstraints(minHeight: 240.0, maxHeight: 360.0),
    this.space = AcSizes.space,
    required this.header,
    required this.viewMoreButton,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            header.leftOr((right) => Text(right,
                style: TextStyle(
                    fontSize: AcSizes.fontLarge,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary))),
            viewMoreButton.leftOr((right) => IconButton(
                  onPressed: right,
                  icon: const Icon(Icons.arrow_right_alt),
                  color: Theme.of(context).colorScheme.primary,
                ))
          ],
        ),
        ConstrainedBox(
          constraints: constraints,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return Padding(
                  padding: EdgeInsets.only(right: space),
                  child: itemBuilder(context, index));
            },
            scrollDirection: Axis.horizontal,
          ),
        )
      ],
    );
  }
}
