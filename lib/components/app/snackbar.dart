import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pambe_ac_ifa/common/constants.dart';

class AcSnackbarMessenger {
  ScaffoldMessengerState messenger;
  AcSnackbarMessenger._({required this.messenger});

  static AcSnackbarMessenger of(BuildContext context) {
    return AcSnackbarMessenger._(
      messenger: ScaffoldMessenger.of(context),
    );
  }

  void sendMessage(BuildContext context, String message) {
    ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      messenger.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ));
    });
  }

  void sendError(Object message, {bool? override}) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (override == true) {
        messenger.clearSnackBars();
      }
      debugPrint("Sent error message: $message");
      if (message is Error) {
        debugPrint(message.stackTrace.toString());
      }
      messenger.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message.toString(),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: AcColors.danger,
      ));
    });
  }

  void sendSuccess(String message) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      messenger.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message,
            style: const TextStyle(
              color: AcColors.success,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: AcColors.successLight,
      ));
    });
  }
}
