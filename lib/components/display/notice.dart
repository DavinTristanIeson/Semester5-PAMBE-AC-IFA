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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
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
          ),
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final Either<Widget, String> error;
  late final Either<Widget, String> message;
  ErrorView({super.key, required this.error, Either<Widget, String>? message}) {
    this.message =
        message ?? Either.right("Sorry, an unexpected error has occurred");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(AcSizes.br),
        color: Color.fromRGBO(0, 0, 0, 0.5),
      ),
      padding: const EdgeInsets.all(AcSizes.space),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning,
            color: context.colors.error,
            size: AcSizes.iconBig * 2,
          ),
          const SizedBox(
            height: AcSizes.lg,
          ),
          message.leftOr((left) => Text(
                left,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: AcSizes.fontLarge,
                  color: context.colors.error,
                ),
              )),
          error.leftOr((left) => Text(
                left,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: context.colors.error,
                ),
              )),
        ],
      ),
    );
  }
}

class ActionableErrorMessage extends StatelessWidget {
  final Either<Widget, Object> error;
  final Widget? action;
  final Either<Widget, String> message;
  ActionableErrorMessage(
      {super.key,
      required this.error,
      this.action,
      Either<Widget, String>? message})
      : message = message ?? Either.right("An unexpected error has occurred");

  ActionableErrorMessage.refresh({
    super.key,
    required this.error,
    required void Function() onRefresh,
    Either<Widget, String>? message,
  })  : action = IconButton(
            onPressed: onRefresh,
            color: AcColors.primary,
            icon: const Icon(Icons.refresh)),
        message = message ?? Either.right("An unexpected error has occurred");

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AcSizes.space),
      child: Column(
        children: [
          error.leftOr((right) => Text(right.toString(),
              textAlign: TextAlign.center,
              style: context.texts.bodyMedium!
                  .copyWith(color: context.colors.error))),
          message.leftOr((right) => Text(
                right,
                textAlign: TextAlign.center,
                style: context.texts.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold, color: context.colors.primary),
              )),
          if (action != null) action!,
        ],
      ),
    );
  }
}
