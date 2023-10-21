import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/app/snackbar.dart';
import 'package:pambe_ac_ifa/components/display/skeleton.dart';
import 'package:pambe_ac_ifa/components/display/some_items_scroll.dart';
import 'package:pambe_ac_ifa/models/container.dart';

class AsyncApiSampleScrollSection<T> extends StatelessWidget
    with SnackbarMessenger {
  final Future<ApiResult<List<T>>> future;
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
    return FutureBuilder(future: future.catchError((error) {
      sendError(context, error.toString());
      return ApiResult(message: "Failure", data: <T>[]);
    }), builder: (context, snapshot) {
      final data = snapshot.data?.data;
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
        header: header,
        viewMoreButton: viewMoreButton,
      );
    });
  }
}
