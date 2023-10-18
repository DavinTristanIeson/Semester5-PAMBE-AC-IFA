import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';

class Skeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final Widget? child;
  const Skeleton(
      {super.key, this.width, this.height, this.constraints, this.child});

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const darkShade = Color.fromRGBO(231, 229, 219, 1);
    const lightShade = Color.fromRGBO(170, 170, 170, 1);
    return AnimatedBuilder(
      animation: _anim,
      child: widget.child,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(AcSizes.br),
              gradient: LinearGradient(
                  colors: const [
                    darkShade,
                    lightShade,
                    darkShade,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomCenter,
                  stops: [_anim.value - 0.5, _anim.value, _anim.value + 0.5])),
          constraints: widget.constraints,
          width: widget.width,
          height: widget.height,
          child: child,
        );
      },
    );
  }
}
