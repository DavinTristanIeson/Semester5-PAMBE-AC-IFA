import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/database/cache/cache_client.dart';
import 'package:pambe_ac_ifa/database/firebase/recipe_images.dart';
import 'package:pambe_ac_ifa/database/firebase/user.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/recipe.dart';
import 'package:pambe_ac_ifa/database/interfaces/common.dart';
import 'package:pambe_ac_ifa/database/mixins/firebase.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/modules/future.dart';

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
  totalRating,
  reviewCount,
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
  INetworkImageResourceManager imageManager;
  RemoteRecipeImageManager recipeImageHelper;
  IBookmarkResourceManager bookmarkManager;
  CacheClient<RecipeModel?> cache;
  CacheClient<PaginatedQueryResult<RecipeLiteModel>> queryCache;
  FirebaseRecipeManager(
      {required this.userManager,
      required this.imageManager,
      required this.bookmarkManager})
      : db = FirebaseFirestore.instance,
        cache = CacheClient(),
        recipeImageHelper =
            RemoteRecipeImageManager(imageManager: imageManager),
        queryCache = CacheClient(
          cleanupInterval: const Duration(minutes: 1, seconds: 30),
          staleTime: const Duration(minutes: 1),
        );

  String getQuerykey({
    QueryDocumentSnapshot? page,
    int? limit,
    SortBy<RecipeSortBy>? sort,
    RecipeFilterBy? filter,
    String? search,
  }) {
    final filterParams = filter?.apiParams;
    return "limit=$limit&sort=${sort?.apiParams}&search=$search&filter[${filterParams?.key}]=${filterParams?.value};${page?.id ?? ''}";
  }

  Future<RecipeModel> _transform(
      Map<String, Object?> json, DocumentSnapshot<Object?> snapshot) async {
    final imagePath = json[RecipeFirestoreKeys.imagePath.name] as String?;
    final steps = (json[RecipeFirestoreKeys.steps.name] as List)
        .cast<Map<String, Object?>>();
    return RecipeModel.fromJson({
      ...json,
      "id": snapshot.id,
      "user": await userManager
          .get(json[RecipeFirestoreKeys.userId.name] as String),
      "imagePath":
          imagePath == null ? null : await imageManager.urlof(imagePath),
      "imageStoragePath": imagePath,
      "steps": await Future.wait(steps.map((step) async {
        final imagePath =
            step[RecipeStepFirestoreKeys.imagePath.name] as String?;
        return {
          ...step,
          "imageStoragePath": imagePath,
          "imagePath":
              imagePath == null ? null : await imageManager.urlof(imagePath)
        };
      }))
    });
  }

  Future<RecipeLiteModel> _transformLite(
      Map<String, Object?> json, DocumentSnapshot<Object?> snapshot) async {
    final imagePath = json[RecipeFirestoreKeys.imagePath.name] as String?;
    return RecipeLiteModel.fromJson({
      ...json,
      "id": snapshot.id,
      "user": await userManager
          .get(json[RecipeFirestoreKeys.userId.name] as String),
      "imagePath":
          imagePath == null ? null : await imageManager.urlof(imagePath),
      "imageStoragePath": imagePath,
    });
  }

  @override
  Future<RecipeModel?> get(String id) async {
    if (cache.has(id)) {
      return Future.value(cache.get(id));
    }

    final (:data, snapshot: _) = await processDocumentSnapshot(
        () => db.collection(collectionPath).doc(id).get(),
        transform: _transform);
    cache.put(id, data);
    return data;
  }

  Query<Map<String, dynamic>> _setQueryParams(
    Query<Map<String, dynamic>> query, {
    required QueryDocumentSnapshot? page,
    required SortBy<RecipeSortBy>? sort,
    required String? search,
  }) {
    RecipeFirestoreKeys? key;
    if (search != null) {
      query = query.where(RecipeFirestoreKeys.title.name, isEqualTo: search);
    }
    if (sort != null) {
      key = switch (sort.factor) {
        RecipeSortBy.ratings => RecipeFirestoreKeys.totalRating,
        _ => RecipeFirestoreKeys.createdAt,
      };
      query = query.orderBy(key.name);
    }
    if (page != null) {
      final lastDoc = page.data() as Map<String, dynamic>?;
      if (key == null) {
        query.startAfter([page.id]);
      } else if (lastDoc != null) {
        query.startAfter([lastDoc[key.name]]);
      }
    }
    return query;
  }

  Future<PaginatedQueryResult<RecipeLiteModel>> getBookmarkedRecipes({
    QueryDocumentSnapshot? page,
    int? limit,
    SortBy<RecipeSortBy>? sort,
    String? search,
    required String userId,
  }) async {
    final queryKey = getQuerykey(
        page: page,
        limit: limit,
        sort: sort,
        filter: RecipeFilterBy.bookmarkedBy(userId),
        search: search);
    if (queryCache.has(queryKey)) {
      return Future.value(queryCache.get(queryKey));
    }
    final (data: bookmarks, :nextPage) =
        await bookmarkManager.getAll(userId: userId);
    final recipeFuture = FutureChunkDistributor(
            bookmarks.map((e) => get(e.recipeId)),
            chunkSize: 4)
        .wait();
    final recipes = (await recipeFuture).notNull<RecipeModel>().toList();
    return (data: recipes, nextPage: nextPage);
  }

  Future<PaginatedQueryResult<RecipeLiteModel>> getRegularRecipes({
    QueryDocumentSnapshot? page,
    int? limit,
    SortBy<RecipeSortBy>? sort,
    RecipeFilterBy? filter,
    String? search,
  }) async {
    final queryKey = getQuerykey(
        page: page, limit: limit, sort: sort, filter: filter, search: search);
    if (queryCache.has(queryKey)) {
      return Future.value(queryCache.get(queryKey));
    }

    var query = db.collection(collectionPath).limit(limit ?? 15);
    query = _setQueryParams(query, page: page, sort: sort, search: search);

    if (filter != null) {
      switch (filter.type) {
        case RecipeFilterByType.createdByUser:
          query = query.where(RecipeFirestoreKeys.userId.name,
              isEqualTo: filter.userId);
        default:
      }
    }

    final (:data, :snapshot) = await processQuerySnapshot(() => query.get(),
        transform: _transformLite);
    final result = (data: data, nextPage: snapshot.docs.lastOrNull);

    queryCache.put(queryKey, result);

    return result;
  }

  @override
  Future<PaginatedQueryResult<RecipeLiteModel>> getAll({
    dynamic page,
    int? limit,
    SortBy<RecipeSortBy>? sort,
    RecipeFilterBy? filter,
    String? search,
  }) async {
    if (filter != null) {
      switch (filter.type) {
        case RecipeFilterByType.createdByUser:
          return getRegularRecipes(
              page: page,
              limit: limit,
              sort: sort,
              filter: filter,
              search: search);
        case RecipeFilterByType.hasBeenBookmarkedBy:
          return getBookmarkedRecipes(
              page: page,
              limit: limit,
              sort: sort,
              search: search,
              userId: filter.userId!);
        case RecipeFilterByType.hasBeenViewedBy:
          // TODO: Views
          return getRegularRecipes(
              page: page,
              limit: limit,
              sort: sort,
              filter: filter,
              search: search);
        case RecipeFilterByType.local:
          throw InvalidStateError(
              "Local recipes cannot be accessed via FirebaseRecipeManager");
      }
    } else {
      return getRegularRecipes(
          page: page, limit: limit, sort: sort, filter: filter, search: search);
    }
  }

  @override
  Future<RecipeModel> put(LocalRecipeModel recipe,
      {required String userId}) async {
    final (
      :reserved,
      recipe: recipeCopy
    ) = recipeImageHelper.markRecipeImagesForStorage(
        current: recipe,
        userId: userId,
        former: recipe.remoteId == null ? null : await get(recipe.remoteId!));

    final json = recipeCopy.toJson();
    json.remove("user");
    json.remove("id");
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
    try {
      await imageManager.process(reserved, userId: userId);
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
    final reserved = recipeImageHelper.markRecipeImagesForDeletion(
        userId: prev.user!.id, recipe: prev);
    try {
      await db.collection(collectionPath).doc(id).delete();
      queryCache.clear();
      cache.markStale(key: id);
    } catch (e) {
      throw ApiError(ApiErrorType.deleteFailure, inner: e);
    }
    try {
      await imageManager.process(reserved, userId: prev.user!.id);
    } catch (e) {
      throw ApiError(ApiErrorType.imageManagementFailure, inner: e);
    }
  }

  @override
  void dispose() {
    cache.dispose();
    queryCache.dispose();
  }
}
