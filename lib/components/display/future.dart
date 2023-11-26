import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/components/function/future.dart';

class FutureButton extends StatelessWidget {
  final Widget child;
  final Widget? icon;
  final Future<void> Function()? onPressed;
  final ButtonStyle? style;
  final Widget? progressIndicator;
  final Color? progressIndicatorColor;
  const FutureButton(
      {super.key,
      required this.child,
      this.onPressed,
      this.style,
      this.icon,
      this.progressIndicator,
      this.progressIndicatorColor});

  @override
  Widget build(BuildContext context) {
    return FutureButtonCompute(
        onPressed: onPressed,
        progressIndicator: progressIndicator,
        progressIndicatorColor: progressIndicatorColor,
        builder: (context, remote) {
          return remote.icon == null
              ? ElevatedButton(
                  onPressed: remote.call,
                  style: style,
                  child: child,
                )
              : ElevatedButton.icon(
                  onPressed: remote.call,
                  icon: remote.icon!,
                  label: child,
                  style: style);
        },
        icon: icon);
  }
}

class FutureOutlinedButton extends StatelessWidget {
  final Widget child;
  final Widget? icon;
  final Future<void> Function()? onPressed;
  final ButtonStyle? style;
  final Widget? progressIndicator;
  final Color? progressIndicatorColor;
  const FutureOutlinedButton(
      {super.key,
      required this.child,
      this.onPressed,
      this.style,
      this.icon,
      this.progressIndicator,
      this.progressIndicatorColor});

  @override
  Widget build(BuildContext context) {
    return FutureButtonCompute(
        onPressed: onPressed,
        progressIndicator: progressIndicator,
        progressIndicatorColor: progressIndicatorColor,
        builder: (context, remote) {
          return remote.icon == null
              ? OutlinedButton(
                  onPressed: remote.call,
                  style: style,
                  child: child,
                )
              : OutlinedButton.icon(
                  onPressed: onPressed,
                  icon: remote.icon!,
                  label: child,
                  style: style);
        },
        icon: icon);
  }
}

class FutureIconButton extends StatelessWidget {
  final Widget icon;
  final Future<void> Function()? onPressed;
  final ButtonStyle? style;
  final Widget? progressIndicator;
  final Color? progressIndicatorColor;
  const FutureIconButton(
      {super.key,
      this.onPressed,
      this.style,
      required this.icon,
      this.progressIndicator,
      this.progressIndicatorColor});

  @override
  Widget build(BuildContext context) {
    return FutureButtonCompute(
        onPressed: onPressed,
        progressIndicator: progressIndicator,
        progressIndicatorColor: progressIndicatorColor,
        builder: (context, remote) {
          return IconButton(
            onPressed: remote.call,
            icon: remote.icon!,
            style: style,
          );
        },
        icon: icon);
  }
}

class FutureTextButton extends StatelessWidget {
  final Widget child;
  final Widget? icon;
  final Future<void> Function()? onPressed;
  final ButtonStyle? style;
  final Widget? progressIndicator;
  final Color? progressIndicatorColor;
  const FutureTextButton(
      {super.key,
      this.onPressed,
      this.style,
      this.icon,
      required this.child,
      this.progressIndicator,
      this.progressIndicatorColor});

  @override
  Widget build(BuildContext context) {
    return FutureButtonCompute(
        onPressed: onPressed,
        progressIndicator: progressIndicator,
        progressIndicatorColor: progressIndicatorColor,
        builder: (context, remote) {
          if (remote.icon == null) {
            return TextButton(
                onPressed: remote.call, style: style, child: child);
          } else {
            return TextButton.icon(
                onPressed: remote.call,
                label: child,
                icon: remote.icon!,
                style: style);
          }
        },
        icon: icon);
  }
}
