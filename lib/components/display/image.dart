import 'dart:io';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pambe_ac_ifa/common/constants.dart';

enum ExternalImageSource {
  @JsonValue("network")
  network,
  @JsonValue("local")
  local,
}

mixin SupportsLocalAndOnlineImagesMixin {
  String? get imagePath;
  ExternalImageSource? get imageSource;

  ImageProvider? get image {
    if (imagePath == null || imageSource == null) return null;
    if (imageSource == ExternalImageSource.local) {
      return FileImage(File(imagePath!));
    } else {
      return NetworkImage(imagePath!);
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
  final ImageProvider? image;
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
    if (image == null) {
      return Image.asset(
        fallbackImagePath,
        fit: fit,
        width: width,
        height: height,
      );
    }
    return FadeInImage(
      image: image!,
      placeholder: const AssetImage(fallbackImagePath),
      imageErrorBuilder: (context, error, stackTrace) {
        return Image.asset(
          fallbackImagePath,
          fit: fit,
        );
      },
      width: width,
      height: height,
      fit: fit,
    );
  }
}
