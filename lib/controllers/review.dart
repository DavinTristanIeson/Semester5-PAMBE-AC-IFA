import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/database/interfaces/common.dart';
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
  String? userId;
  String? recipeId;
  String? reviewId;
  ReviewFilterBy.user(this.userId) : type = ReviewFilterByType.user;
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

class ReviewController extends ChangeNotifier {
  IReviewResourceManager reviewManager;
  ReviewController({required this.reviewManager});

  Future<PaginatedQueryResult<ReviewModel>> getAll(
      {required ReviewSearchState searchState,
      Either<QueryDocumentSnapshot, String>? page}) {
    return reviewManager.getAll(
        page: page?.whichever,
        recipeId: searchState.filter.recipeId,
        userId: searchState.filter.userId,
        limit: searchState.limit);
  }

  Future<ReviewModel?> get(String reviewId) {
    return reviewManager.get(reviewId);
  }

  Future<ReviewModel> put({
    required String userId,
    String? content,
    required int rating,
  }) {
    // Satu user satu review
    return reviewManager.put(
        userId: userId, rating: rating, content: content, reviewId: userId);
  }

  Future<void> remove(String reviewId) {
    return reviewManager.remove(reviewId);
  }
}
