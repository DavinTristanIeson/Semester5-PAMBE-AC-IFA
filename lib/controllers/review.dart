import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/database/interfaces/common.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/review.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/review.dart';

enum ReviewFilterByType {
  user,
  recipe,
  review,
}

class ReviewFilterBy {
  ReviewFilterByType type;
  String? recipeId;
  String? reviewId;
  ReviewFilterBy.recipe(this.recipeId) : type = ReviewFilterByType.recipe;
  ReviewFilterBy.review(this.reviewId) : type = ReviewFilterByType.review;
}

class ReviewSearchState {
  int limit;
  ReviewFilterBy filter;
  SortBy<ReviewSortBy> sort;
  ReviewSearchState({
    this.limit = 15,
    required this.filter,
    SortBy<ReviewSortBy>? sort,
    // ignore: unnecessary_this
  }) : this.sort = sort ?? SortBy.descending(ReviewSortBy.createdAt);
}

class ReviewController extends ChangeNotifier implements AuthDependent {
  IReviewResourceManager reviewManager;
  @override
  String? userId;
  ReviewController({required this.reviewManager});

  Future<PaginatedQueryResult<ReviewModel>> getAllWithPagination(
      {required ReviewSearchState searchState,
      Either<QueryDocumentSnapshot, String>? page}) {
    return Future.value((
      data: <ReviewModel>[],
      nextPage: null,
    ));
    // return reviewManager.getAll(
    //     page: page?.whichever,
    //     recipeId: searchState.filter.recipeId,
    //     limit: searchState.limit);
  }

  Future<List<ReviewModel>> getAll(
      {required ReviewSearchState searchState,
      Either<QueryDocumentSnapshot, String>? page}) async {
    return (await getAllWithPagination(page: page, searchState: searchState))
        .data;
  }

  Future<ReviewModel?> get(
      {required String recipeId, required String reviewId}) {
    return reviewManager.get(reviewId: reviewId, recipeId: recipeId);
  }

  Future<ReviewModel> put({
    required String recipeId,
    String? content,
    required int rating,
  }) {
    if (userId == null) {
      throw InvalidStateError(
          "ReviewController.userId should not be null when put is invoked");
    }
    // Satu user satu review
    return reviewManager.put(
        userId: userId!,
        rating: rating,
        content: content,
        reviewId: userId!,
        recipeId: recipeId);
  }

  Future<void> remove(String reviewId, String recipeId) {
    return reviewManager.remove(reviewId: reviewId, recipeId: recipeId);
  }
}
