import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pambe_ac_ifa/database/cache/cache_client.dart';
import 'package:pambe_ac_ifa/database/interfaces/common.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/notification.dart';
import 'package:pambe_ac_ifa/database/mixins/firebase.dart';
import 'package:pambe_ac_ifa/models/notification.dart';

enum NotificationFirestoreKeys {
  type,
  title,
  content,
  createdAt,
  isRead,
  reviewId,
  recipeId,
}

class FirebaseNotificationManager
    with FirebaseResourceManagerMixin
    implements INotificationResourceManager {
  FirebaseFirestore db;
  CacheClient<NotificationModel?> cache;
  CacheClient<PaginatedQueryResult<NotificationModel>> queryCache;
  FirebaseNotificationManager()
      : cache = CacheClient(
            staleTime: const Duration(minutes: 15),
            cleanupInterval: const Duration(minutes: 10)),
        db = FirebaseFirestore.instance,
        queryCache = CacheClient(
            staleTime: const Duration(minutes: 2),
            cleanupInterval: const Duration(minutes: 1, seconds: 30));

  CollectionReference getCollection(String userId) {
    return db.collection("users").doc(userId).collection("notifications");
  }

  NotificationModel _transform(
      Map<String, dynamic> json, DocumentSnapshot<Object?> snapshot) {
    return NotificationModel.fromJson({...json, "id": snapshot.id});
  }

  Future<NotificationModel?> get(
      {required String userId, required String id}) async {
    if (cache.has(id)) {
      return Future.value(cache.get(id));
    }
    final (:data, snapshot: _) = await processDocumentSnapshot(
        () => getCollection(userId).doc(id).get(),
        transform: _transform);
    cache.put(id, data);
    return data;
  }

  @override
  Future<PaginatedQueryResult<NotificationModel>> getAll(
      {dynamic page,
      required String userId,
      int? limit,
      NotificationFilterBy? filter}) async {
    final lastCreatedAt = page as DateTime?;
    final queryKey = lastCreatedAt?.toString() ?? '';
    if (queryCache.has(queryKey)) {
      return Future.value(queryCache.get(queryKey));
    }
    var query = getCollection(userId)
        .limit(limit ?? 15)
        .orderBy(NotificationFirestoreKeys.createdAt.name, descending: true);
    if (filter != null) {
      switch (filter.type) {
        case NotificationFilterByType.type:
          query = query.where(NotificationFirestoreKeys.type.name,
              isEqualTo: filter.notificationType.name);
      }
    }
    if (lastCreatedAt != null) {
      query = query.startAfter([lastCreatedAt.millisecondsSinceEpoch]);
    }

    final (:data, snapshot: _) = await processQuerySnapshot<NotificationModel>(
        () => query.get(), transform: (json, snapshot) {
      final result = _transform(json, snapshot);
      cache.put(snapshot.id, result);
      return result;
    });
    final result = (data: data, nextPage: data.lastOrNull?.createdAt);
    if (queryKey.isNotEmpty) {
      queryCache.put(queryKey, result);
    }
    return result;
  }

  @override
  Future<bool> hasUnread({required String userId}) async {
    try {
      final countUnread = await getCollection(userId)
          .where(NotificationFirestoreKeys.isRead.name, isEqualTo: false)
          .limit(1)
          .count()
          .get();
      return countUnread.count > 0;
    } catch (e) {
      throw ApiError(ApiErrorType.fetchFailure, inner: e);
    }
  }

  @override
  Future<void> markAllRead({required String userId}) async {
    final result = await getCollection(userId)
        .where(NotificationFirestoreKeys.isRead.name, isEqualTo: false)
        .get();
    final batch = db.batch();
    for (final doc in result.docs) {
      batch.update(doc.reference, {
        NotificationFirestoreKeys.isRead.name: true,
      });
    }
    await batch.commit();
    for (final doc in result.docs) {
      cache.put(doc.id, _transform(doc.data() as Map<String, dynamic>, doc));
    }
  }

  @override
  Future<void> clear({required String userId}) async {
    final result = await getCollection(userId).get();
    final batch = db.batch();
    for (final doc in result.docs) {
      batch.delete(doc.reference);
    }
    try {
      await batch.commit();
      queryCache.clear();
      cache.clear();
    } catch (e) {
      throw ApiError(ApiErrorType.deleteFailure, inner: e);
    }
  }

  @override
  Future<void> notify(
      {required String targetUserId,
      required NotificationPayload notification}) async {
    try {
      await getCollection(targetUserId).add({
        ...notification.toJson(),
        NotificationFirestoreKeys.createdAt.name:
            DateTime.now().millisecondsSinceEpoch,
        NotificationFirestoreKeys.isRead.name: false,
      });
      queryCache.clear();
    } catch (e) {
      throw ApiError(ApiErrorType.storeFailure, inner: e);
    }
  }
}
