import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/database/cache/cache_client.dart';
import 'package:pambe_ac_ifa/database/firebase/recipe_images.dart';
import 'package:pambe_ac_ifa/database/firebase/user.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/firebase.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';

enum RecipeStepFirestoreKeys {
  content,
  type,
  timer,
  imagePath;

  @override
  toString() => name;
}

enum RecipeFirestoreKeys {
  title,
  userId,
  createdAt,
  imagePath,
  ratings,
  steps,
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
  RemoteRecipeImageManager imageManager;
  CacheClient<RecipeModel> cache;
  CacheClient<PaginatedQueryResult<RecipeLiteModel>> queryCache;
  FirebaseRecipeManager(this.db,
      {required this.userManager, required this.imageManager})
      : cache = CacheClient(),
        queryCache = CacheClient(
            cleanupInterval: const Duration(minutes: 1, seconds: 30),
            staleTime: const Duration(minutes: 1),
            cacheTime: const Duration(minutes: 2));

  String keyOfRecipeQuery(
      {QueryDocumentSnapshot? page, RecipeSearchState? searchState}) {
    return "${searchState?.getApiParams() ?? ''};${page?.id ?? ''}";
  }

  @override
  Future<RecipeModel?> get(String id) async {
    if (cache.has(id)) {
      return Future.value(cache.get(id));
    }
    try {
      final (:data, snapshot: _) = await processDocumentSnapshot(
          () => db.collection(collectionPath).doc(id).get(),
          transform: (data, snapshot) async => RecipeModel.fromJson({
                ...data,
                "id": snapshot.id,
                "user":
                    await userManager.get(data[RecipeFirestoreKeys.userId.name])
              }));
      cache.put(id, data);
      return data;
    } on ApiError catch (e) {
      if (e.type == ApiErrorType.resourceNotFound) {
        return null;
      } else {
        rethrow;
      }
    }
  }

  Future<PaginatedQueryResult<RecipeLiteModel>> getRegularRecipes(
      {QueryDocumentSnapshot? page, RecipeSearchState? searchState}) async {
    final queryKey = keyOfRecipeQuery(page: page, searchState: searchState);
    if (queryCache.has(queryKey)) {
      return Future.value(queryCache.get(queryKey));
    }

    var query = db.collection(collectionPath).limit(searchState?.limit ?? 15);
    if (searchState?.search != null) {
      query = query.where(RecipeFirestoreKeys.title.name,
          isEqualTo: searchState!.search);
    }
    if (searchState?.sortBy != null) {
      var sortBy = switch (searchState!.sortBy.factor) {
        RecipeSortBy.createdDate => RecipeFirestoreKeys.createdAt,
        RecipeSortBy.ratings => RecipeFirestoreKeys.ratings,
        _ => null
      };
      if (sortBy != null) {
        query = query.orderBy(sortBy.name);
      } else {
        query = query.orderBy(FieldPath.documentId);
      }
    }
    if (page != null) {
      query = query.startAfter([page.id]);
    }
    if (searchState?.filterBy != null) {
      switch (searchState!.filterBy!.type) {
        case RecipeFilterByType.createdByUser:
          query = query.where(RecipeFirestoreKeys.userId,
              isEqualTo: searchState.filterBy!.userId);
        default:
      }
    }

    final (:data, :snapshot) = await processQuerySnapshot(() => query.get(),
        transform: (json, snapshot) async {
      return RecipeLiteModel.fromJson({
        ...json,
        "id": snapshot.id,
        "user": await userManager.get(json[RecipeFirestoreKeys.userId.name]),
      });
    });
    final result = (data: data, nextPage: snapshot.docs.lastOrNull);

    queryCache.put(queryKey, result);

    return result;
  }

  @override
  Future<PaginatedQueryResult<RecipeLiteModel>> getAll(
      {Object? page, RecipeSearchState? searchState}) async {
    return getRegularRecipes(
        page: page as QueryDocumentSnapshot?, searchState: searchState);
  }

  @override
  Future<RecipeModel> put(LocalRecipeModel recipe,
      {required String userId}) async {
    final json = recipe.toJson();
    json.remove("user");
    json.remove("id");
    json[RecipeFirestoreKeys.userId.name] = userId;

    final reserved = imageManager.markRecipeImagesForStorage(
        current: recipe,
        userId: userId,
        former: recipe.remoteId == null ? null : await get(recipe.remoteId!));

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
    try {
      await imageManager.imageManager.process(reserved, userId: userId);
    } catch (e) {
      throw ApiError(ApiErrorType.imageManagementFailure, inner: e);
    }

    queryCache.clear();
    cache.markStale(key: id);
    return (await get(id))!;
  }

  @override
  Future<void> remove(String id) async {
    final prev = await get(id);
    if (prev == null) {
      return;
    }
    try {
      await db.collection(collectionPath).doc(id).delete();
      queryCache.clear();
      cache.markStale(key: id);
    } catch (e) {
      throw ApiError(ApiErrorType.deleteFailure, inner: e);
    }
  }

  @override
  void dispose() {
    cache.dispose();
    queryCache.dispose();
  }
}
