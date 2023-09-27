import 'package:flutter/material.dart';

class OverInkwell extends StatelessWidget {
  final Widget child;
  final Color? splashColor;
  final void Function()? onTap;
  const OverInkwell(
      {super.key, required this.child, this.splashColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: child,
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: splashColor,
              onTap: onTap,
            ),
          ),
        )
      ],
    );
  }
}
