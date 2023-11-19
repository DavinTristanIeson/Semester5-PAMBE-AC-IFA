import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/common.dart';
import 'package:pambe_ac_ifa/database/interfaces/review.dart';
import 'package:pambe_ac_ifa/database/mixins/firebase.dart';
import 'package:pambe_ac_ifa/models/review.dart';

enum ReviewFirestoreKeys {
  content,
  reviewedAt,
  rating,
  userId,
}

class FirebaseReviewManager
    with FirebaseResourceManagerMixin
    implements IReviewResourceManager {
  @override
  Future<ReviewModel?> get(String reviewId) {
    // TODO: implement get
    throw UnimplementedError();
  }

  Future<PaginatedQueryResult<ReviewModel>> getAllReviewsByRecipe(
      String recipeId,
      {int? limit,
      dynamic page}) {
    throw UnimplementedError();
  }

  Future<PaginatedQueryResult<ReviewModel>> getAllReviewsByUser(String userId,
      {int? limit, dynamic page}) {
    throw UnimplementedError();
  }

  @override
  Future<PaginatedQueryResult<ReviewModel>> getAll(
      {dynamic page, String? recipeId, String? userId, int? limit}) {
    if (recipeId != null) {
      return getAllReviewsByRecipe(recipeId, limit: limit, page: page);
    }
    if (userId != null) {
      return getAllReviewsByUser(userId, limit: limit, page: page);
    }
    throw InvalidStateError(
        "Either recipeId or userId must be provided to FirebaseReviewManager.getAll");
  }

  @override
  Future<ReviewModel> put(
      {String? reviewId,
      required String userId,
      required int rating,
      String? content}) {
    // TODO: implement put
    throw UnimplementedError();
  }

  @override
  Future<void> remove(String reviewId) {
    // TODO: implement remove
    throw UnimplementedError();
  }
}
