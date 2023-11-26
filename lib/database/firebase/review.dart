import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/database/cache/cache_client.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/common.dart';
import 'package:pambe_ac_ifa/database/interfaces/review.dart';
import 'package:pambe_ac_ifa/database/interfaces/user.dart';
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
  FirebaseFirestore db;
  IUserResourceManager userManager;
  CacheClient<ReviewModel> cache;
  CacheClient<PaginatedQueryResult<ReviewModel>> queryCache;
  FirebaseReviewManager({required this.userManager})
      : db = FirebaseFirestore.instance,
        cache = CacheClient(
            staleTime: const Duration(minutes: 5),
            cleanupInterval: const Duration(minutes: 3)),
        queryCache = CacheClient(
          staleTime: const Duration(minutes: 2),
          cleanupInterval: const Duration(minutes: 1, seconds: 30),
        );

  CollectionReference getCollection(String recipeId) {
    return db.collection("recipes").doc(recipeId).collection("reviews");
  }

  String getQueryKey({
    required String recipeId,
    QueryDocumentSnapshot? page,
    int? limit,
  }) {
    return "$recipeId;limit=$limit;page=${page?.id}";
  }

  String getKey({
    required String recipeId,
    required String reviewId,
  }) {
    return "$recipeId;$reviewId";
  }

  Future<ReviewModel> _transform(
      Map<String, dynamic> json, DocumentSnapshot<Object?> snapshot) async {
    return ReviewModel.fromJson({
      ...json,
      "id": snapshot.id,
      "user": await userManager.get(json[ReviewFirestoreKeys.userId.name])
    });
  }

  @override
  Future<ReviewModel?> get(
      {required String reviewId, required String recipeId}) async {
    final key = getKey(recipeId: recipeId, reviewId: reviewId);
    if (cache.has(key)) {
      return cache.get(key);
    }
    final (:data, snapshot: _) = await processDocumentSnapshot(
        () => getCollection(recipeId).doc(reviewId).get(),
        transform: _transform);
    cache.put(key, data);
    return data;
  }

  @override
  Future<PaginatedQueryResult<ReviewModel>> getAll(
      {dynamic page, required String recipeId, int? limit}) async {
    final key = getQueryKey(recipeId: recipeId);
    if (queryCache.has(key)) {
      return Future.value(queryCache.get(key));
    }

    var query = getCollection(recipeId).limit(limit ?? 15);
    if (page != null) {
      query = query.startAfter([(page as QueryDocumentSnapshot).id]);
    }

    final (:data, :snapshot) =
        await processQuerySnapshot(() => query.get(), transform: _transform);
    final result = (data: data, nextPage: snapshot.docs.lastOrNull);

    queryCache.put(key, result);

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
      ReviewFirestoreKeys.userId.name: userId,
      ReviewFirestoreKeys.content.name: content,
      ReviewFirestoreKeys.rating.name: rating,
      ReviewFirestoreKeys.createdAt.name: DateTime.now().millisecondsSinceEpoch
    };

    String id;
    try {
      if (reviewId != null) {
        await getCollection(recipeId).doc(reviewId).set(json);
        id = reviewId;
      } else {
        final docRef = await getCollection(recipeId).add(json);
        id = docRef.id;
      }
      cache.markStale(key: getKey(recipeId: recipeId, reviewId: id));
      queryCache.markStale(prefix: recipeId);
    } catch (e) {
      throw ApiError(ApiErrorType.storeFailure, inner: e);
    }

    return get(reviewId: id, recipeId: recipeId).cast<ReviewModel>();
  }

  @override
  Future<void> remove(
      {required String reviewId, required String recipeId}) async {
    final prev = await get(recipeId: recipeId, reviewId: reviewId);
    if (prev == null) {
      return;
    }
    try {
      await getCollection(reviewId).doc(reviewId).delete();
      cache.markStale(key: getKey(recipeId: recipeId, reviewId: reviewId));
      queryCache.markStale(prefix: recipeId);
    } catch (e) {
      throw ApiError(ApiErrorType.deleteFailure, inner: e);
    }
  }
}
