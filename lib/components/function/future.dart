import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/components/app/snackbar.dart';

class FutureButtonRemote {
  final Future<void> Function()? call;
  final Widget? icon;
  final bool isLoading;
  FutureButtonRemote(
      {required this.call, required this.icon, required this.isLoading});
}

class FutureButtonCompute extends StatefulWidget {
  final Widget Function(BuildContext context, FutureButtonRemote remote)
      builder;
  final Widget? icon;
  final Widget? progressIndicator;
  final Color? progressIndicatorColor;
  final Future<void> Function()? onPressed;
  const FutureButtonCompute(
      {super.key,
      required this.builder,
      this.icon,
      this.onPressed,
      this.progressIndicator,
      this.progressIndicatorColor});

  @override
  State<FutureButtonCompute> createState() => _FutureButtonComputeState();
}

class _FutureButtonComputeState extends State<FutureButtonCompute> {
  bool _isLoading = false;

  Future<void> run() {
    final messenger = AcSnackbarMessenger.of(context);
    setState(() => _isLoading = true);
    return widget.onPressed!().catchError((err, stackTrace) {
      messenger.sendError(err);
    }).whenComplete(() => setState(() => _isLoading = false));
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      FutureButtonRemote(
          call: _isLoading || widget.onPressed == null ? null : run,
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
