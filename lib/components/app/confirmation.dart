import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/app/snackbar.dart';
import 'package:pambe_ac_ifa/components/display/future.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:permission_handler/permission_handler.dart';

const _localePrefix = "components/app/confirmation";

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
    return title != null && title.hasLeft
        ? title.left
        : Text(
            title?.right ?? defaultText,
            style: context.texts.titleLarge,
          );
  }

  static Widget _buildPositiveText(Either<Widget, String>? positiveText,
      String defaultText, Color textColor) {
    return positiveText != null && positiveText.hasLeft
        ? positiveText.left
        : Text(
            positiveText?.right ?? "$_localePrefix/confirm".i18n(),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          );
  }

  static Widget _buildNegativeText(Either<Widget, String>? negativeText,
      String defaultText, BuildContext context) {
    return negativeText != null && negativeText.hasLeft
        ? negativeText.left
        : Text(negativeText?.right ?? "$_localePrefix/cancel".i18n(),
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
    this.title =
        _buildTitle(context, title, "$_localePrefix/confirmation".i18n());
    this.message = _buildMessage(message);
    this.positiveText = _buildPositiveText(positiveText,
        "$_localePrefix/confirm".i18n(), Theme.of(context).colorScheme.primary);
    this.negativeText = _buildNegativeText(
        negativeText, "$_localePrefix/cancel".i18n(), context);
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
    this.title =
        _buildTitle(context, title, "$_localePrefix/confirm_deletion".i18n());
    this.message = _buildMessage(message);
    this.positiveText = _buildPositiveText(positiveText,
        "$_localePrefix/delete".i18n(), Theme.of(context).colorScheme.error);
    this.negativeText = _buildNegativeText(
        negativeText, "$_localePrefix/cancel".i18n(), context);
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
          Text("$_localePrefix/select_picture_source".i18n(),
              style: context.texts.titleLarge),
      content: message?.leftOr((right) => Text(right)) ??
          Text(
            "$_localePrefix/confirmation_body".i18n(),
          ),
      backgroundColor: AcColors.white,
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: context.colors.secondary,
          ),
          child: Text("$_localePrefix/cancel".i18n()),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("$_localePrefix/camera".i18n()),
          onPressed: () async {
            final navigator = Navigator.of(context);
            final permissionResponse = await Permission.camera.request();
            if (permissionResponse.isPermanentlyDenied) {
              await openAppSettings();
            }
            if (permissionResponse.isGranted) {
              await onPickSource(ImageSource.camera);
              navigator.pop();
            }
          },
        ),
        TextButton(
          child: Text("$_localePrefix/gallery".i18n()),
          onPressed: () async {
            final navigator = Navigator.of(context);
            PermissionStatus permissionResponse;
            if (Platform.isAndroid &&
                (await DeviceInfoPlugin().androidInfo).version.sdkInt <= 32) {
              permissionResponse = await Permission.storage.request();
            } else {
              permissionResponse = await Permission.photos.request();
            }

            if (permissionResponse.isPermanentlyDenied) {
              await openAppSettings();
            }
            if (permissionResponse.isGranted) {
              await onPickSource(ImageSource.gallery);
              navigator.pop();
            }
          },
        ),
      ],
    );
  }
}

Future<Optional<T>> showBlockingDialog<T>(
    BuildContext context, Future<T> Function() fn) async {
  T? value;
  dynamic error;
  final messenger = AcSnackbarMessenger.of(context);
  await showDialog(
    builder: (context) {
      final navigator = Navigator.of(context);
      Future(() async {
        try {
          value = await fn();
        } catch (e) {
          messenger.sendError(e);
          error = e;
        } finally {
          navigator.pop();
        }
      });
      return const PopScope(
          canPop: false, child: Center(child: CircularProgressIndicator()));
    },
    barrierDismissible: false,
    context: context,
  );
  if (error != null) {
    return Optional.none();
  }
  return Optional.some(value as T);
}
