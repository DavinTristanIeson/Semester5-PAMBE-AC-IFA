import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';

mixin SupportsLocalAndOnlineImagesMixin {
  String? get localImage;
  String? get onlineImage;
  ImageProvider? get image {
    if (localImage != null) {
      return FileImage(File(localImage!));
    } else if (onlineImage != null) {
      return NetworkImage(onlineImage!);
    } else {
      return null;
    }
  }
}

class AcImageContainer extends StatelessWidget {
  final Widget? child;
  final BorderRadius? borderRadius;
  final BoxConstraints? constraints;
  const AcImageContainer(
      {super.key,
      this.child,
      this.borderRadius = defaultBorderRadius,
      this.constraints});

  static const BorderRadius defaultBorderRadius = BorderRadius.all(AcSizes.br);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? defaultBorderRadius,
        gradient: LinearGradient(colors: [
          Theme.of(context).colorScheme.tertiary,
          Color.lerp(Theme.of(context).colorScheme.tertiary,
              const Color.fromRGBO(0, 0, 0, 0.1), 0.2)!,
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      constraints: constraints ??
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 3),
      child: borderRadius != null
          ? ClipRRect(borderRadius: borderRadius!, child: child)
          : child,
    );
  }
}

class MaybeImage extends StatelessWidget {
  final ImageProvider image;
  final BoxFit fit;
  final double? width;
  final double? height;
  const MaybeImage(
      {super.key,
      required this.image,
      this.width,
      this.height,
      this.fit = BoxFit.cover});
  static const String fallbackImagePath =
      "assets/images/image-not-available.jpg";

  @override
  Widget build(BuildContext context) {
    return FadeInImage(
      image: image,
      placeholder: const AssetImage(fallbackImagePath),
      imageErrorBuilder: (context, error, stackTrace) {
        return Image.asset(
          fallbackImagePath,
          fit: fit,
        );
      },
      fit: fit,
    );
  }
}
