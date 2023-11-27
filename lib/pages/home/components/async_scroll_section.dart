import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/display/notice.dart';
import 'package:pambe_ac_ifa/components/display/skeleton.dart';
import 'package:pambe_ac_ifa/components/display/some_items_scroll.dart';
import 'package:pambe_ac_ifa/models/container.dart';

class AsyncApiSampleScrollSection<T> extends StatelessWidget {
  final Future<List<T>> future;
  final Widget Function(BuildContext context, T data) itemBuilder;
  final Either<Widget, String> header;
  final Either<Widget, void Function()>? viewMoreButton;
  final BoxConstraints itemConstraints;
  final BoxConstraints? constraints;
  final double space;
  const AsyncApiSampleScrollSection(
      {super.key,
      required this.future,
      required this.itemBuilder,
      required this.header,
      this.viewMoreButton,
      this.constraints,
      this.space = AcSizes.space,
      required this.itemConstraints});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (snapshot.hasError) {
            return SampleScrollSection(
                itemCount: 1,
                itemBuilder: (context, index) {
                  return ConstrainedBox(
                    constraints: itemConstraints.copyWith(
                      maxWidth: context.screenWidth - AcSizes.xl,
                      minWidth: context.screenWidth - AcSizes.xl,
                    ),
                    child: ErrorView(
                        error: Either.right(snapshot.error!.toString())),
                  );
                },
                constraints: constraints,
                header: header,
                viewMoreButton: viewMoreButton);
          }
          return SampleScrollSection(
            itemCount: snapshot.connectionState != ConnectionState.done
                ? 5
                : min(5, data?.length ?? 0),
            itemBuilder: (context, index) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Skeleton(
                  constraints: itemConstraints,
                );
              }
              return itemBuilder(context, data![index]);
            },
            constraints: constraints,
            header: header,
            viewMoreButton: viewMoreButton,
          );
        });
  }
}
