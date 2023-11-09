import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/components/app/snackbar.dart';

class FutureButtonCompute extends StatefulWidget {
  final Widget Function(BuildContext context,
      Future<void> Function()? onPressed, Widget? icon) builder;
  final Widget? icon;
  final Widget? progressIndicator;
  final Color? progressIndicatorColor;
  final Future<void> Function()? onPressed;
  const FutureButtonCompute(
      {super.key,
      required this.builder,
      required this.icon,
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
        _isLoading || widget.onPressed == null ? null : run,
        _isLoading
            ? widget.progressIndicator ??
                Transform.scale(
                    scale: 0.5,
                    child: CircularProgressIndicator(
                        color: widget.progressIndicatorColor))
            : widget.icon);
  }
}

class FutureButton extends StatelessWidget {
  final Widget child;
  final Widget? icon;
  final Future<void> Function()? onPressed;
  final ButtonStyle? style;
  const FutureButton(
      {super.key, required this.child, this.onPressed, this.style, this.icon});

  @override
  Widget build(BuildContext context) {
    return FutureButtonCompute(
        onPressed: onPressed,
        builder: (context, onPressed, icon) {
          return icon == null
              ? ElevatedButton(
                  onPressed: onPressed,
                  style: style,
                  child: child,
                )
              : ElevatedButton.icon(
                  onPressed: onPressed, icon: icon, label: child, style: style);
        },
        icon: icon);
  }
}
