import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pambe_ac_ifa/database/cache/cache_client.dart';
import 'package:pambe_ac_ifa/database/interfaces/common.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/recipe.dart';
import 'package:pambe_ac_ifa/database/mixins/firebase.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';

enum BookmarkFirestoreKeys {
  createdAt,
}

class FirebaseBookmarkManager extends IBookmarkResourceManager
    with FirebaseResourceManagerMixin {
  FirebaseFirestore db;
  CacheClient<RecipeBookmarkModel?> cache;
  CacheClient<PaginatedQueryResult<RecipeBookmarkModel>> queryCache;
  FirebaseBookmarkManager()
      : db = FirebaseFirestore.instance,
        cache = CacheClient(
            cleanupInterval: const Duration(minutes: 10),
            staleTime: const Duration(minutes: 15)),
        queryCache = CacheClient(
            cleanupInterval: const Duration(minutes: 5),
            staleTime: const Duration(minutes: 8));

  CollectionReference getCollection({required String userId}) {
    return db.collection("users").doc(userId).collection("bookmarks");
  }

  String getKey({required String userId, required String recipeId}) {
    return "$userId;$recipeId";
  }

  String getQueryKey({
    required String userId,
    int? limit,
    QueryDocumentSnapshot? page,
  }) {
    return "$userId;limit=$limit;page=${page?.id}'";
  }

  RecipeBookmarkModel _transform(
      Map<String, dynamic> data, DocumentSnapshot snapshot,
      {required String userId}) {
    return RecipeBookmarkModel.fromJson({
      ...data,
      "userId": userId,
      "recipeId": snapshot.id,
    });
  }

  @override
  Future<RecipeBookmarkModel?> get(
      {required String userId, required String recipeId}) async {
    final key = getKey(userId: userId, recipeId: recipeId);
    if (cache.has(key)) {
      return Future.value(cache.get(key));
    }
    final (data: bookmark, snapshot: _) = await processDocumentSnapshot(
        () => getCollection(userId: userId).doc(recipeId).get(),
        transform: (data, snapshot) =>
            _transform(data, snapshot, userId: userId));
    cache.put(key, bookmark);
    return bookmark;
  }

  @override
  Future<PaginatedQueryResult<RecipeBookmarkModel>> getAll({
    required String userId,
    int? limit,
    dynamic page,
  }) async {
    final key = getQueryKey(
      userId: userId,
      limit: limit,
      page: page,
    );
    if (queryCache.has(key)) {
      return Future.value(queryCache.get(key));
    }

    final collection = getCollection(userId: userId);
    var query = collection.limit(limit ?? 15);
    query =
        query.orderBy(BookmarkFirestoreKeys.createdAt.name, descending: true);

    final lastDoc = page as QueryDocumentSnapshot?;
    if (lastDoc != null && lastDoc.exists) {
      final json = (lastDoc.data()! as Map<String, dynamic>);
      query = query.startAfter([json[BookmarkFirestoreKeys.createdAt.name]]);
    }

    final (:data, :snapshot) = await processQuerySnapshot(() => query.get(),
        transform: (data, snapshot) =>
            _transform(data, snapshot, userId: userId));
    final returned = (data: data, nextPage: snapshot.docs.lastOrNull);
    queryCache.put(key, returned);
    return returned;
  }

  @override
  Future<void> set(
      {required String recipeId,
      required String userId,
      required bool isBookmarked}) async {
    try {
      final doc = getCollection(userId: userId).doc(recipeId);
      if (isBookmarked) {
        await doc.set({
          BookmarkFirestoreKeys.createdAt.name:
              DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        await doc.delete();
      }
      cache.markStale(key: getKey(userId: userId, recipeId: recipeId));
      queryCache.markStale(prefix: userId);
    } on FirebaseException catch (e) {
      if (isBookmarked) {
        throw ApiError(ApiErrorType.storeFailure, inner: e);
      } else {
        throw ApiError(ApiErrorType.deleteFailure, inner: e);
      }
    }
  }
}
