import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/controllers/review.dart';
import 'package:pambe_ac_ifa/database/interfaces/review.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/pages/reviews/add_review.dart';
import 'package:pambe_ac_ifa/pages/reviews/list.dart';

enum ReviewPermission {
  permit,
  deny,
}

class ReviewsScreen extends StatefulWidget {
  final String? reviewId;
  final String recipeId;
  final ReviewPermission permission;
  const ReviewsScreen(
      {super.key,
      this.reviewId,
      required this.recipeId,
      this.permission = ReviewPermission.permit});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  bool _showAll = false;
  @override
  void initState() {
    super.initState();
    _showAll = widget.reviewId == null;
  }

  bool get onlyShowOne {
    return !_showAll && widget.reviewId != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const OnlyReturnAppBar(),
        body: CustomScrollView(
          slivers: [
            if (widget.permission == ReviewPermission.permit)
              SliverAppBar.large(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                expandedHeight: context.relativeHeight(0.5, 350, 450),
                flexibleSpace: AddReviewSection(
                  recipeId: widget.recipeId,
                ),
              ),
            ReviewsList(
              searchState: ReviewSearchState(
                  filter: onlyShowOne
                      ? ReviewFilterBy.review(widget.reviewId)
                      : ReviewFilterBy.recipe(widget.recipeId),
                  limit: onlyShowOne ? 1 : 15,
                  sort: SortBy.descending(ReviewSortBy.ratings)),
            ),
            if (onlyShowOne)
              SliverToBoxAdapter(
                  child: Padding(
                padding: const EdgeInsets.only(bottom: AcSizes.space),
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        _showAll = true;
                      });
                    },
                    child: const Text("Show Other Reviews")),
              )),
          ],
        ));
  }
}
