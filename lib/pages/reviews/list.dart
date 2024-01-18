import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/app/confirmation.dart';
import 'package:pambe_ac_ifa/components/app/snackbar.dart';
import 'package:pambe_ac_ifa/components/display/pagination.dart';
import 'package:pambe_ac_ifa/controllers/review.dart';
import 'package:pambe_ac_ifa/database/interfaces/common.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/review.dart';
import 'package:pambe_ac_ifa/pages/reviews/components/review_item.dart';
import 'package:provider/provider.dart';

class ReviewsList extends StatefulWidget {
  final ReviewSearchState searchState;
  final String? reviewId;
  const ReviewsList({super.key, required this.searchState, this.reviewId});

  @override
  State<ReviewsList> createState() => _ReviewsListState();
}

class _ReviewsListState extends State<ReviewsList> {
  late final PagingController<QueryDocumentSnapshot?, ReviewModel> _pagination;

  @override
  void initState() {
    _pagination = PagingController(firstPageKey: null);
    _pagination.addPageRequestListener((pageKey) async {
      try {
        final (:data, :nextPage) = await fetch(widget.searchState, pageKey);
        if (nextPage == null) {
          _pagination.appendLastPage(data);
        } else {
          _pagination.appendPage(data, nextPage);
        }
      } catch (e) {
        _pagination.error = e;
      }
    });
    super.initState();
  }

  @override
  didUpdateWidget(covariant ReviewsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchState != widget.searchState) {
      _pagination.refresh();
    }
  }

  Future<PaginatedQueryResult<ReviewModel>> fetch(
      ReviewSearchState state, QueryDocumentSnapshot? pageKey) async {
    final controller = context.read<ReviewController>();
    if (state.reviewId != null) {
      final data = await controller.get(
          recipeId: state.recipeId, reviewId: state.reviewId!);
      return (data: [if (data != null) data], nextPage: null);
    }
    return controller.getAllWithPagination(searchState: state, page: pageKey);
  }

  @override
  void dispose() {
    _pagination.dispose();
    super.dispose();
  }

  Future<void> deleteReview(ReviewModel review) {
    final reviewManager = context.read<ReviewController>();
    final messenger = AcSnackbarMessenger.of(context);
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleConfirmationDialog.delete(
              onConfirm: () async {
                await reviewManager.remove(
                    review.id, widget.searchState.recipeId);
                _pagination.refresh();
                messenger
                    .sendSuccess("screen/reviews/list/review_delete".i18n());
              },
              message: Either.right(
                  "screen/reviews/list/review_delete_extra".i18n()),
              context: context);
        });
  }

  @override
  Widget build(BuildContext context) {
    return AcPageListCompute(
        controller: _pagination,
        itemBuilder: (context, item, index) => Padding(
            padding: const EdgeInsets.symmetric(
                vertical: AcSizes.sm, horizontal: AcSizes.space),
            child: ReviewItem(
              review: item,
              onDeleted: deleteReview,
            )),
        builder: (context, props) {
          return PagedSliverList(
              pagingController: props.pagingController,
              builderDelegate: props.builderDelegate);
        });
  }
}
