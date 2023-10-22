import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/models/container.dart';

enum NoticeType {
  tip,
  warning,
}

class NoticeComponent extends StatelessWidget {
  final NoticeType type;
  final Either<Widget, String> child;
  const NoticeComponent({super.key, required this.child, required this.type});

  get icon {
    return switch (type) {
      NoticeType.tip => const Icon(Icons.error_outline, color: AcColors.black),
      NoticeType.warning =>
        const Icon(Icons.warning_amber, color: AcColors.black),
    };
  }

  get color {
    return switch (type) {
      NoticeType.tip => AcColors.info,
      NoticeType.warning => AcColors.danger,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(AcSizes.br),
        color: color,
      ),
      padding: const EdgeInsets.all(AcSizes.md),
      child: Row(
        children: [
          icon,
          const SizedBox(width: AcSizes.space),
          child.leftOr((right) => Text(
                right,
                style: AcTypography.importantDescription,
              )),
        ],
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  late final Either<Widget, String> content;
  EmptyView({super.key, Either<Widget, String>? content}) {
    this.content = content ?? Either.right("Sorry, no data was found");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(AcSizes.br),
        color: Color.fromRGBO(0, 0, 0, 0.2),
      ),
      padding: const EdgeInsets.all(AcSizes.space),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning,
            color: context.colors.tertiary,
            size: AcSizes.iconBig * 2,
          ),
          const SizedBox(
            height: AcSizes.lg,
          ),
          content.leftOr((left) => Text(
                left,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: context.colors.tertiary,
                ),
              )),
        ],
      ),
    );
  }
}
