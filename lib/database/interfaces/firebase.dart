import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';

mixin FirebaseResourceManagerMixin {
  Future<T> processDocumentSnapshot<T>(
    Future<DocumentSnapshot<Map<String, dynamic>>> Function() query, {
    required T Function(Map<String, dynamic> data) transform,
  }) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await query();
    } on FirebaseException catch (e) {
      throw ApiError(ApiErrorType.fromServer, inner: e);
    }
    if (!snapshot.exists) {
      throw ApiError(ApiErrorType.resourceNotFound);
    }
    try {
      return transform(snapshot.data()!);
    } catch (e) {
      throw ApiError(ApiErrorType.shapeMismatch, inner: e);
    }
  }

  Future<PaginatedQueryResult<T>> processQuerySnapshot<T>(
    Future<QuerySnapshot<Map<String, dynamic>>> Function() query, {
    required T Function(Map<String, dynamic> data) transform,
  }) async {
    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await query();
    } on FirebaseException catch (e) {
      throw ApiError(ApiErrorType.fromServer, inner: e);
    }
    try {
      return (
        data: snapshot.docs
            .map((e) {
              try {
                return transform(e.data());
              } catch (e) {
                return null;
              }
            })
            .where((e) => e != null)
            .cast<T>()
            .toList(),
        nextPage: snapshot.docs.lastOrNull
      );
    } catch (e) {
      throw ApiError(ApiErrorType.shapeMismatch, inner: e);
    }
  }
}
