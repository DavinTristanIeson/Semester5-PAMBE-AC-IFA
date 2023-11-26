import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/database/interfaces/common.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/review.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/review.dart';

class ReviewSearchState {
  int limit;
  String recipeId;
  String? reviewId;
  SortBy<ReviewSortBy> sort;
  ReviewSearchState({
    this.limit = 15,
    required this.recipeId,
    SortBy<ReviewSortBy>? sort,
    this.reviewId,
  }) : sort = sort ?? SortBy.descending(ReviewSortBy.createdAt);
}

class ReviewController extends ChangeNotifier implements AuthDependent {
  IReviewResourceManager reviewManager;
  @override
  String? userId;
  ReviewController({required this.reviewManager});

  Future<PaginatedQueryResult<ReviewModel>> getAllWithPagination(
      {required ReviewSearchState searchState,
      QueryDocumentSnapshot? page}) async {
    final limit = searchState.reviewId != null ? 1 : searchState.limit;
    final (:data, :nextPage) = await reviewManager.getAll(
        page: page, recipeId: searchState.recipeId, limit: limit);
    return (data: data, nextPage: data.length < limit ? null : nextPage);
  }

  Future<List<ReviewModel>> getAll(
      {required ReviewSearchState searchState,
      QueryDocumentSnapshot? page}) async {
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
  }) async {
    if (userId == null) {
      throw InvalidStateError(
          "ReviewController.userId should not be null when put is invoked");
    }
    // Satu user satu review
    final result = await reviewManager.put(
        userId: userId!,
        rating: rating,
        content: content,
        reviewId: userId!,
        recipeId: recipeId);
    notifyListeners();
    return result;
  }

  Future<void> remove(String reviewId, String recipeId) async {
    await reviewManager.remove(reviewId: reviewId, recipeId: recipeId);
    notifyListeners();
  }
}
