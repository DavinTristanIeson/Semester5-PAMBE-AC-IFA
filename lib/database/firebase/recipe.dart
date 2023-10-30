import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pambe_ac_ifa/database/firebase/user.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/firebase.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';

enum RecipeFirestoreKeys {
  title,
  userId,
  createdAt,
  ratings,
  description;

  @override
  toString() => name;
}

class FirebaseRecipeManager
    with FirebaseResourceManagerMixin
    implements IRecipeResourceManager {
  static const String collectionPath = "recipes";
  FirebaseFirestore db;
  FirebaseUserManager userManager;
  FirebaseRecipeManager(this.db, {required this.userManager});

  @override
  Future<RecipeModel?> get(String id) async {
    return processDocumentSnapshot(
        () => db.collection(collectionPath).doc(id).get(),
        transform: (data) => RecipeModel.fromJson(data));
  }

  Future<PaginatedQueryResult<RecipeLiteModel>> getRegularRecipes(
      {QueryDocumentSnapshot? page, RecipeSearchState? searchState}) async {
    var query = db.collection(collectionPath).limit(searchState?.limit ?? 15);
    if (page != null) {
      query = query.startAfter([page]);
    }
    if (searchState?.search != null) {
      query = query.where(RecipeFirestoreKeys.title,
          isLessThan: '${searchState!.search!}\uf8ff',
          isGreaterThan: searchState.search!);
    }
    if (searchState?.sortBy != null) {
      var sortBy = switch (searchState!.sortBy.factor) {
        RecipeSortBy.createdDate => RecipeFirestoreKeys.createdAt,
        RecipeSortBy.ratings => RecipeFirestoreKeys.ratings,
        _ => null
      };
      if (sortBy != null) {
        query = query.orderBy(sortBy.name);
      }
    }
    if (searchState?.filterBy != null) {
      switch (searchState!.filterBy!.type) {
        case RecipeFilterByType.createdByUser:
          query = query.where(RecipeFirestoreKeys.userId,
              isEqualTo: searchState.filterBy!.userId);
        default:
      }
    }

    return processQuerySnapshot(() => query.get(), transform: (json) {
      return RecipeLiteModel.fromJson({
        ...json,
        "user": userManager.get(json[RecipeFirestoreKeys.userId.name]),
      });
    });
  }

  @override
  Future<PaginatedQueryResult<RecipeLiteModel>> getAll(
      {Object? page, RecipeSearchState? searchState}) async {
    return getRegularRecipes(
        page: page as QueryDocumentSnapshot, searchState: searchState);
  }

  @override
  Future<RecipeModel> put(LocalRecipeModel recipe,
      {required String userId}) async {
    final json = recipe.toJson();
    json[RecipeFirestoreKeys.userId.name] = userId;
    String id;
    try {
      if (recipe.remoteId != null) {
        await db.collection(collectionPath).doc(recipe.remoteId).set(json);
        id = recipe.remoteId!;
      } else {
        final docRef = await db.collection(collectionPath).add(json);
        id = docRef.id;
      }
    } catch (e) {
      throw ApiError(ApiErrorType.storeFailure, inner: e);
    }
    return (await get(id))!;
  }

  @override
  Future<void> remove(String id) async {
    try {
      await db.collection(collectionPath).doc(id).delete();
    } catch (e) {
      throw ApiError(ApiErrorType.deleteFailure, inner: e);
    }
  }
}
