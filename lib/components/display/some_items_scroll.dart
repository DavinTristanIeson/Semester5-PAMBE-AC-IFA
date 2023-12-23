import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/models/container.dart';

class SampleScrollSection extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Either<Widget, String> header;
  final Either<Widget, void Function()>? viewMoreButton;
  final Either<Widget, String>? emptyView;
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
    this.emptyView,
  });

  Widget buildEmptyView(BuildContext context) {
    if (emptyView != null && emptyView!.hasLeft) {
      return emptyView!.left!;
    }
    return Container(
      decoration: const BoxDecoration(
          color: Color.fromRGBO(0, 0, 0, 0.3),
          borderRadius: BorderRadius.all(AcSizes.br)),
      child: Center(
        child: Text(
          emptyView?.right ?? "common/no_data".i18n(),
          style: context.texts.titleMedium!
              .copyWith(color: context.colors.tertiary),
        ),
      ),
    );
  }

  static Widget buildDefaultSecondaryAction(
      {required BuildContext context, required void Function() onPressed}) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_right_alt),
      color: Theme.of(context).colorScheme.primary,
    );
  }

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
            viewMoreButton != null
                ? viewMoreButton!.leftOr((right) => buildDefaultSecondaryAction(
                    context: context, onPressed: right))
                : const SizedBox(
                    height: AcSizes.xl + AcSizes.lg,
                  )
          ],
        ),
        ConstrainedBox(
          constraints:
              constraints ?? BoxConstraints.tight(Size.fromHeight(itemHeight)),
          child: itemCount == 0
              ? buildEmptyView(context)
              : ListView.builder(
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    return Padding(
                        padding:
                            EdgeInsets.only(right: space, bottom: AcSizes.md),
                        child: itemBuilder(context, index));
                  },
                  scrollDirection: Axis.horizontal,
                ),
        )
      ],
    );
  }
}
