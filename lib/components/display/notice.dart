import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
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
