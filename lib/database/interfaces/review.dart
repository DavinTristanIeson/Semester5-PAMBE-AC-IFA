import 'package:pambe_ac_ifa/database/interfaces/common.dart';
import 'package:pambe_ac_ifa/models/review.dart';

enum ReviewSortBy {
  ratings,
  createdAt,
}

abstract class IReviewResourceManager {
  Future<PaginatedQueryResult<ReviewModel>> getAll(
      {dynamic page, required String recipeId, int? limit});
  Future<ReviewModel?> get(
      {required String recipeId, required String reviewId});
  Future<ReviewModel> put({
    required String recipeId,
    required String userId,
    required int rating,
    String? reviewId,
    String? content,
  });
  Future<void> remove({required String reviewId, required String recipeId});
}
