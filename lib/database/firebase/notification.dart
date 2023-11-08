import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pambe_ac_ifa/database/cache/cache_client.dart';
import 'package:pambe_ac_ifa/database/interfaces/firebase.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:pambe_ac_ifa/models/notification.dart';

enum NotificationFirestoreKeys {
  type,
  title,
  content,
  createdAt,
  isRead,
  reviewTargetId,
}

class FirebaseNotificationManager
    with FirebaseResourceManagerMixin
    implements INotificationResourceManager {
  FirebaseFirestore db;
  CacheClient<NotificationModel> cache;
  CacheClient<PaginatedQueryResult<NotificationModel>> queryCache;
  FirebaseNotificationManager(this.db)
      : cache = CacheClient(
            staleTime: const Duration(minutes: 15),
            cleanupInterval: const Duration(minutes: 10)),
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

  Future<NotificationModel> get(
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
      {dynamic page, required String userId}) async {
    final lastCreatedAt = page as DateTime?;
    final queryKey = lastCreatedAt?.toString() ?? '';
    if (queryCache.has(queryKey)) {
      return Future.value(queryCache.get(queryKey));
    }
    var query = getCollection(userId)
        .limit(15)
        .orderBy(NotificationFirestoreKeys.createdAt.name, descending: true);
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
    final countUnread = await getCollection(userId)
        .where(NotificationFirestoreKeys.isRead.name, isEqualTo: false)
        .limit(1)
        .count()
        .get();
    return countUnread.count > 0;
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
  }
}