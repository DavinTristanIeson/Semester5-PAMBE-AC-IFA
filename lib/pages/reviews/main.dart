import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/components/display/notice.dart';
import 'package:pambe_ac_ifa/controllers/recipe.dart';
import 'package:pambe_ac_ifa/controllers/review.dart';
import 'package:pambe_ac_ifa/database/interfaces/review.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/reviews/add_review.dart';
import 'package:pambe_ac_ifa/pages/reviews/list.dart';
import 'package:provider/provider.dart';

enum ReviewPermission {
  permit,
  deny,
}

class ReviewsScreen extends StatelessWidget {
  final String? reviewId;
  final String recipeId;
  final ReviewPermission permission;
  const ReviewsScreen(
      {super.key,
      this.reviewId,
      required this.recipeId,
      this.permission = ReviewPermission.permit});

  @override
  Widget build(BuildContext context) {
    final recipeController = context.read<RecipeController>();
    return Scaffold(
        appBar: const OnlyReturnAppBar(),
        body: FutureBuilder(
            future: recipeController.get(recipeId),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return ErrorView(
                    error: Either.right(snapshot.error.toString()));
              }
              if (!snapshot.hasData) {
                return EmptyView(
                  content:
                      Either.right("screen/reviews/main/find_recipe".i18n([recipeId]),)
                );
              }
              return _ReviewsScreen(
                permission: permission,
                recipe: snapshot.data!,
                reviewId: reviewId,
              );
            }));
  }
}

class _ReviewsScreen extends StatefulWidget {
  final ReviewPermission permission;
  final RecipeLiteModel recipe;
  final String? reviewId;
  const _ReviewsScreen(
      {required this.permission, required this.recipe, this.reviewId});

  @override
  State<_ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<_ReviewsScreen> {
  bool _showAll = false;
  late ReviewSearchState searchState;
  @override
  void initState() {
    super.initState();
    _showAll = widget.reviewId == null;
    searchState = _initializeSearchState();
  }

  bool get onlyShowOne {
    return !_showAll && widget.reviewId != null;
  }

  ReviewSearchState _initializeSearchState() {
    return ReviewSearchState(
        recipeId: widget.recipe.id,
        reviewId: widget.reviewId,
        limit: onlyShowOne ? 1 : 15,
        sort: SortBy.descending(ReviewSortBy.ratings));
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (widget.permission == ReviewPermission.permit)
          SliverAppBar(
            backgroundColor: context.colors.background,
            automaticallyImplyLeading: false,
            expandedHeight: context.relativeHeight(0.5, 350, 450),
            flexibleSpace: AddReviewSection(
              recipe: widget.recipe,
              onReviewed: () {
                setState(() {
                  _showAll = true;
                  searchState = _initializeSearchState();
                });
              },
            ),
            toolbarHeight: 0.0,
            floating: true,
            collapsedHeight: 0.0,
          ),
        ReviewsList(
          searchState: searchState,
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
                child:  Text("screen/reviews/main/other_review".i18n())),
          )),
      ],
    );
  }
}
