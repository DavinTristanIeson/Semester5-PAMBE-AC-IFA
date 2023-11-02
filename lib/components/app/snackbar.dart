import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pambe_ac_ifa/common/constants.dart';

mixin SnackbarMessenger {
  void sendMessage(BuildContext context, String message) {
    ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      messenger?.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ));
    });
  }

  void sendError(BuildContext context, String message, {bool? override}) {
    ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (override == true) {
        messenger?.clearSnackBars();
      }
      debugPrint("Sent error message: $message");
      messenger?.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      ));
    });
  }

  void sendSuccess(BuildContext context, String message) {
    ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      messenger?.showSnackBar(SnackBar(
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
