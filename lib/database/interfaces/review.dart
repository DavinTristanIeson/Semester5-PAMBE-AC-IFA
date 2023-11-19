import 'package:pambe_ac_ifa/database/interfaces/common.dart';
import 'package:pambe_ac_ifa/models/review.dart';

enum ReviewSortBy {
  ratings,
  createdAt,
}

abstract class IReviewResourceManager {
  Future<PaginatedQueryResult<ReviewModel>> getAll(
      {dynamic page, String? recipeId, String? userId, int? limit});
  Future<ReviewModel?> get(String reviewId);
  Future<ReviewModel> put({
    String? reviewId,
    required String userId,
    required int rating,
    String? content,
  });
  Future<void> remove(String reviewId);
}
