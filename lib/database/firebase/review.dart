import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pambe_ac_ifa/common/json.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/common.dart';
import 'package:pambe_ac_ifa/database/interfaces/review.dart';
import 'package:pambe_ac_ifa/database/mixins/firebase.dart';
import 'package:pambe_ac_ifa/models/review.dart';

enum ReviewFirestoreKeys {
  content,
  createdAt,
  rating,
  userId,
}

class FirebaseReviewManager
    with FirebaseResourceManagerMixin
    implements IReviewResourceManager {
  static const String collectionPath = "recipes";
  FirebaseFirestore db;
  FirebaseReviewManager(this.db);

  CollectionReference getCollection(String recipeId) {
    return db.collection(collectionPath).doc(recipeId).collection("reviews");
  }

  String keyOfRecipeQuery({
    QueryDocumentSnapshot? page,
    int? limit,
    String? search,
  }) {
    return "limit=$limit;${page?.id ?? ''}";
  }

  ReviewModel _transform(
      Map<String, dynamic> json, DocumentSnapshot<Object?> snapshot) {
    return ReviewModel.fromJson({...json, "id": snapshot.id});
  }

  @override
  Future<ReviewModel?> get(
      {required String reviewId, required String recipeId}) async {
    final (:data, snapshot: _) = await processDocumentSnapshot(
        () => getCollection(recipeId).doc(reviewId).get(),
        transform: _transform);
    return data;
  }

  @override
  Future<PaginatedQueryResult<ReviewModel>> getAll(
      {dynamic page, required String recipeId, int? limit}) async {
    var query = db.collection(collectionPath).limit(limit ?? 15);
    if (page != null) {
      query = query.startAfter([page.id]);
    }

    final (:data, :snapshot) =
        await processQuerySnapshot(() => query.get(), transform: _transform);
    final result = (data: data, nextPage: snapshot.docs.lastOrNull);

    return result;
  }

  @override
  Future<ReviewModel> put(
      {String? reviewId,
      required String recipeId,
      required String userId,
      required int rating,
      String? content}) async {
    final json = <String, dynamic>{
      'userId': userId,
      'content': content,
      'rating': rating,
    };
    if (reviewId != null) {
      json['createdAt'] = DateTime.now().millisecondsSinceEpoch;
    }

    String id;
    try {
      if (reviewId != null) {
        await db
            .collection(collectionPath)
            .doc(recipeId)
            .collection("reviews")
            .doc(reviewId)
            .set(json);
        id = reviewId;
      } else {
        final docRef = await db
            .collection(collectionPath)
            .doc(recipeId)
            .collection("reviews")
            .add(json);
        id = docRef.id;
      }
    } catch (e) {
      throw ApiError(ApiErrorType.storeFailure, inner: e);
    }

    return (await get(reviewId: id, recipeId: recipeId))!;
  }

  @override
  Future<void> remove(
      {required String reviewId, required String recipeId}) async {
    final prev = await get(recipeId: recipeId, reviewId: reviewId);
    if (prev == null) {
      return;
    }
    try {
      await db
          .collection(collectionPath)
          .doc(recipeId)
          .collection("reviews")
          .doc(reviewId)
          .delete();
    } catch (e) {
      throw ApiError(ApiErrorType.deleteFailure, inner: e);
    }
    throw UnimplementedError();
  }
}
