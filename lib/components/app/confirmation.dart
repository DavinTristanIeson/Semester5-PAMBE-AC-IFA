import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/display/future.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:permission_handler/permission_handler.dart';

/// Default confirmation dialog. Used with showDialog
class SimpleConfirmationDialog extends StatelessWidget {
  final FutureOr<void> Function() onConfirm;
  final FutureOr<void> Function()? onCancel;
  late final Widget message;
  late final Widget title;
  late final Widget positiveText;
  late final Widget negativeText;

  static Widget _buildTitle(
      BuildContext context, Either<Widget, String>? title, String defaultText) {
    return title != null && title.left != null
        ? title.left!
        : Text(
            title?.right ?? defaultText,
            style: context.texts.titleLarge,
          );
  }

  static Widget _buildPositiveText(Either<Widget, String>? positiveText,
      String defaultText, Color textColor) {
    return positiveText != null && positiveText.left != null
        ? positiveText.left!
        : Text(
            positiveText?.right ?? "Confirm",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          );
  }

  static Widget _buildNegativeText(Either<Widget, String>? negativeText,
      String defaultText, BuildContext context) {
    return negativeText != null && negativeText.left != null
        ? negativeText.left!
        : Text(negativeText?.right ?? "Cancel",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ));
  }

  static Widget _buildMessage(Either<Widget, String> message) {
    return message.leftOr((right) => Text(right));
  }

  SimpleConfirmationDialog(
      {super.key,
      required this.onConfirm,
      this.onCancel,
      required BuildContext context,
      required Either<Widget, String> message,
      Either<Widget, String>? title,
      Either<Widget, String>? positiveText,
      Either<Widget, String>? negativeText}) {
    this.title = _buildTitle(context, title, "Confirmation");
    this.message = _buildMessage(message);
    this.positiveText = _buildPositiveText(
        positiveText, "Confirm", Theme.of(context).colorScheme.primary);
    this.negativeText = _buildNegativeText(negativeText, "Cancel", context);
  }
  SimpleConfirmationDialog.delete(
      {super.key,
      required this.onConfirm,
      this.onCancel,
      required Either<Widget, String> message,
      required BuildContext context,
      Either<Widget, String>? title,
      Either<Widget, String>? positiveText,
      Either<Widget, String>? negativeText}) {
    this.title = _buildTitle(context, title, "Confirm Deletion");
    this.message = _buildMessage(message);
    this.positiveText = _buildPositiveText(
        positiveText, "Delete", Theme.of(context).colorScheme.error);
    this.negativeText = _buildNegativeText(negativeText, "Cancel", context);
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    return AlertDialog(
      title: title,
      content: message,
      backgroundColor: AcColors.white,
      actions: [
        FutureTextButton(
            onPressed: () async {
              if (onCancel != null) {
                try {
                  await onCancel!();
                  navigator.pop();
                } catch (e) {
                  navigator.pop();
                  rethrow;
                }
              } else {
                navigator.pop();
              }
            },
            child: negativeText),
        FutureTextButton(
          onPressed: () async {
            try {
              await onConfirm();
              navigator.pop();
            } catch (e) {
              navigator.pop();
              rethrow;
            }
          },
          child: positiveText,
        ),
      ],
    );
  }
}

class ImagePickMethodDialog extends StatelessWidget {
  final FutureOr<void> Function(ImageSource source) onPickSource;
  final Either<Widget, String>? message;
  final Either<Widget, String>? title;

  const ImagePickMethodDialog(
      {super.key,
      required BuildContext context,
      this.message,
      this.title,
      required this.onPickSource});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title?.leftOr((right) => Text(right)) ??
          Text("Select Picture Source", style: context.texts.titleLarge),
      content: message?.leftOr((right) => Text(right)) ??
          const Text(
            'Where do you want to take the picture from?',
          ),
      backgroundColor: AcColors.white,
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: context.colors.secondary,
          ),
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Camera'),
          onPressed: () async {
            final navigator = Navigator.of(context);
            final permissionResponse = await Permission.camera.request();
            if (permissionResponse.isPermanentlyDenied) {
              final open = await openAppSettings();
              if (!open) return;
            }
            if (permissionResponse.isGranted) {
              onPickSource(ImageSource.camera);
              navigator.pop();
            }
          },
        ),
        TextButton(
          child: const Text('Gallery'),
          onPressed: () async {
            final navigator = Navigator.of(context);
            onPickSource(ImageSource.gallery);
            navigator.pop();
          },
        ),
      ],
    );
  }
}
