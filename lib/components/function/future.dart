import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/components/app/snackbar.dart';

class FutureButtonRemote<T> {
  final Future<void> Function()? call;
  final Future<void> Function(T args)? callArgs;
  final Widget? icon;
  final bool isLoading;
  FutureButtonRemote(
      {required this.call,
      required this.callArgs,
      required this.icon,
      required this.isLoading});
}

class FutureButtonCompute<T> extends StatefulWidget {
  final Widget Function(BuildContext context, FutureButtonRemote<T> remote)
      builder;
  final Widget? icon;
  final Widget? progressIndicator;
  final Color? progressIndicatorColor;
  final Future<void> Function()? onPressed;
  final Future<void> Function(T args)? onPressedWithArgs;
  const FutureButtonCompute(
      {super.key,
      required this.builder,
      this.icon,
      this.onPressed,
      this.progressIndicator,
      this.progressIndicatorColor,
      this.onPressedWithArgs});

  @override
  State<FutureButtonCompute<T>> createState() => _FutureButtonComputeState<T>();
}

class _FutureButtonComputeState<T> extends State<FutureButtonCompute<T>> {
  bool _isLoading = false;

  Future<void> wrapError(Future<void> future) {
    final messenger = AcSnackbarMessenger.of(context);
    return future.catchError((err, stackTrace) {
      messenger.sendError(err);
    }).whenComplete(() => setState(() => _isLoading = false));
  }

  Future<void> run() {
    setState(() => _isLoading = true);
    return wrapError(widget.onPressed!());
  }

  Future<void> runWithArgs(T args) {
    setState(() => _isLoading = true);
    return wrapError(widget.onPressedWithArgs!(args));
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      FutureButtonRemote<T>(
          call: _isLoading || widget.onPressed == null ? null : run,
          callArgs: _isLoading || widget.onPressedWithArgs == null
              ? null
              : runWithArgs,
          icon: _isLoading
              ? widget.progressIndicator ??
                  Transform.scale(
                      scale: 0.5,
                      child: CircularProgressIndicator(
                          color: widget.progressIndicatorColor))
              : widget.icon,
          isLoading: _isLoading),
    );
  }
}
