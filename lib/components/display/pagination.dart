import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/display/notice.dart';
import 'package:pambe_ac_ifa/models/container.dart';

const localePrefix = "components.display.pagination";

class AcPageListCompute<TKey, TValue> extends StatelessWidget {
  final PagingController<TKey, TValue> controller;
  final Widget Function(BuildContext context, TValue value, int index)
      itemBuilder;
  final Widget Function(
      BuildContext context,
      ({
        PagingController<TKey, TValue> pagingController,
        PagedChildBuilderDelegate builderDelegate,
      }) props) builder;
  const AcPageListCompute(
      {super.key,
      required this.controller,
      required this.itemBuilder,
      required this.builder});

  @override
  Widget build(BuildContext context) {
    return builder(context, (
      pagingController: controller,
      builderDelegate: PagedChildBuilderDelegate(
          noItemsFoundIndicatorBuilder: (context) {
            return Padding(
              padding: const EdgeInsets.all(AcSizes.space),
              child: EmptyView(
                  content: Either.right(
                      "$localePrefix.error_no_items_found".i18n())),
            );
          },
          newPageErrorIndicatorBuilder: (context) {
            return ActionableErrorMessage.refresh(
                error: Either.right(controller.error),
                onRefresh: controller.refresh);
          },
          firstPageErrorIndicatorBuilder: (context) {
            return ActionableErrorMessage.refresh(
                error: Either.right(controller.error),
                onRefresh: controller.refresh);
          },
          itemBuilder: (context, item, index) => Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: AcSizes.sm, horizontal: AcSizes.space),
              child: itemBuilder(context, item, index)))
    ));
  }
}

class AcPagedListView<TKey, TValue> extends StatelessWidget {
  final PagingController<TKey, TValue> controller;
  final Widget Function(BuildContext context, TValue value, int index)
      itemBuilder;
  const AcPagedListView(
      {super.key, required this.controller, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AcSizes.space),
      child: AcPageListCompute(
        controller: controller,
        itemBuilder: itemBuilder,
        builder: (context, props) {
          return PagedListView(
              pagingController: props.pagingController,
              builderDelegate: props.builderDelegate);
        },
      ),
    );
  }
}
