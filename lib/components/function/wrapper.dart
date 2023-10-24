import 'package:flutter/material.dart';

class Wrapper extends StatelessWidget {
  final Widget child;
  final Widget Function(BuildContext context, Widget child) wrapper;
  final bool shouldWrap;
  const Wrapper(
      {super.key,
      required this.child,
      required this.wrapper,
      this.shouldWrap = true});

  @override
  Widget build(BuildContext context) {
    return shouldWrap ? wrapper(context, child) : child;
  }
}
