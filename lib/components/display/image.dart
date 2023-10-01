import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';

mixin SupportsLocalAndOnlineImages {
  String? get localImage;
  String? get onlineImage;
  Widget buildImage({
    BorderRadius? borderRadius,
    BoxConstraints? constraints,
    BoxFit fit = BoxFit.contain,
  }) {
    if (localImage != null) {
      return MaybeFileImage(
        image: File(localImage!),
        fit: fit,
        constraints: constraints,
        borderRadius: borderRadius,
      );
    } else {
      return MaybeNetworkImage(
          url: onlineImage!,
          fit: fit,
          constraints: constraints,
          borderRadius: borderRadius);
    }
  }
}

class AcImageContainer extends StatelessWidget {
  final Widget? child;
  final BorderRadius? borderRadius;
  final BoxConstraints? constraints;
  const AcImageContainer(
      {super.key, this.child, this.borderRadius, this.constraints});

  static const BorderRadius defaultBorderRadius =
      BorderRadius.all(AcSizes.brInput);

  static Widget clipImage(Widget image, {BorderRadius? borderRadius}) {
    return ClipRRect(
      borderRadius: borderRadius ?? defaultBorderRadius,
      child: image,
    );
  }

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
      child: child,
    );
  }
}

const String fallbackImagePath = "assets/images/image-not-available.jpg";

class MaybeFileImage extends StatelessWidget {
  final File? image;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final BoxConstraints? constraints;
  const MaybeFileImage(
      {super.key,
      this.image,
      this.fit = BoxFit.contain,
      this.borderRadius,
      this.constraints});

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return AcImageContainer(
          child: AcImageContainer.clipImage(
              Image.asset(fallbackImagePath, fit: fit),
              borderRadius: borderRadius));
    }
    return AcImageContainer(
        borderRadius: borderRadius,
        constraints: constraints,
        child: FutureBuilder(
            future: image!.exists(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
                  return const Center(child: CircularProgressIndicator());
                case ConnectionState.none:
                  return AcImageContainer.clipImage(
                      Image.asset(fallbackImagePath, fit: fit),
                      borderRadius: borderRadius);
                case ConnectionState.done:
                  if (snapshot.data!) {
                    return AcImageContainer.clipImage(
                        Image.file(image!, fit: fit),
                        borderRadius: borderRadius);
                  } else {
                    return AcImageContainer.clipImage(
                        Image.asset(fallbackImagePath),
                        borderRadius: borderRadius);
                  }
              }
            }));
  }
}

class MaybeNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final BoxConstraints? constraints;
  const MaybeNetworkImage(
      {super.key,
      required this.url,
      this.fit = BoxFit.contain,
      this.borderRadius,
      this.constraints});

  @override
  Widget build(BuildContext context) {
    return AcImageContainer(
      borderRadius: borderRadius,
      constraints: constraints,
      child: ClipRRect(
        borderRadius: AcImageContainer.defaultBorderRadius,
        child: FadeInImage(
          image: NetworkImage(url),
          placeholder: const AssetImage(fallbackImagePath),
          imageErrorBuilder: (context, error, stackTrace) {
            return AcImageContainer.clipImage(
                Image.asset(
                  fallbackImagePath,
                  fit: fit,
                ),
                borderRadius: borderRadius);
          },
          fit: fit,
        ),
      ),
    );
  }
}
