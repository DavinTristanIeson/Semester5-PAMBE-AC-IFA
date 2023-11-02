import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';

mixin FirebaseResourceManagerMixin {
  Future<({T data, DocumentSnapshot snapshot})> processDocumentSnapshot<T>(
    Future<DocumentSnapshot> Function() query, {
    required Future<T> Function(
            Map<String, dynamic> data, DocumentSnapshot snapshot)
        transform,
  }) async {
    DocumentSnapshot snapshot;
    try {
      snapshot = await query();
    } on FirebaseException catch (e) {
      throw ApiError(ApiErrorType.fromServer, inner: e);
    }
    if (!snapshot.exists) {
      throw ApiError(ApiErrorType.resourceNotFound);
    }
    try {
      return (
        data:
            await transform(snapshot.data() as Map<String, dynamic>, snapshot),
        snapshot: snapshot
      );
    } catch (e) {
      throw ApiError(ApiErrorType.shapeMismatch, inner: e);
    }
  }

  Future<({List<T> data, QuerySnapshot snapshot})> processQuerySnapshot<T>(
    Future<QuerySnapshot> Function() query, {
    required Future<T> Function(
            Map<String, dynamic> data, QueryDocumentSnapshot snapshot)
        transform,
  }) async {
    QuerySnapshot snapshot;
    try {
      snapshot = await query();
    } on FirebaseException catch (e) {
      throw ApiError(ApiErrorType.fromServer, inner: e);
    }
    try {
      return (
        data: (await Future.wait<T>(snapshot.docs
                .map((doc) {
                  try {
                    return transform(doc.data() as Map<String, dynamic>, doc);
                  } catch (e) {
                    return null;
                  }
                })
                .where((e) => e != null)
                .cast<Future<T>>()))
            .toList(),
        snapshot: snapshot,
      );
    } catch (e) {
      throw ApiError(ApiErrorType.shapeMismatch, inner: e);
    }
  }
}