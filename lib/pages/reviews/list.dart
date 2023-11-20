import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
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
    return controller.getAllWithPagination(
        searchState: state,
        page: pageKey == null
            ? Either.left(pageKey)
            : Either.right(widget.reviewId));
  }

  @override
  void dispose() {
    _pagination.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AcPageListCompute(
        controller: _pagination,
        itemBuilder: (context, item, index) => Padding(
            padding: const EdgeInsets.symmetric(
                vertical: AcSizes.sm, horizontal: AcSizes.space),
            child: ReviewItem(review: item)),
        builder: (context, props) {
          return PagedSliverList(
              pagingController: props.pagingController,
              builderDelegate: props.builderDelegate);
        });
  }
}
