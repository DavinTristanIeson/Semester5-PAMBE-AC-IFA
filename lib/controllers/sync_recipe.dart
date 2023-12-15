import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pambe_ac_ifa/database/firebase/recipe.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/recipe.dart';
import 'package:pambe_ac_ifa/database/sqflite/tables/recipe.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';

typedef SyncAllRecipesPayload = ({String uid});
typedef _SyncAllRecipesIsolatePayload = ({
  String uid,
  SyncAllRecipesService service,
  RootIsolateToken isolateToken,
});
typedef SyncRecipePayload = ({String uid, String remoteId, int localId});
typedef _SyncRecipeIsolatePayload = ({
  String uid,
  String remoteId,
  int localId,
  SyncRecipeService service,
  RootIsolateToken isolateToken,
});

class SyncRecipeService {
  final FirebaseRecipeManager recipeManager;
  final RecipeTable localRecipeManager;
  SyncRecipeService(
      {required this.recipeManager, required this.localRecipeManager});

  static Future<LocalRecipeModel> _run(
      _SyncRecipeIsolatePayload payload) async {
    final (:service, :uid, :remoteId, :localId, :isolateToken) = payload;
    BackgroundIsolateBinaryMessenger.ensureInitialized(isolateToken);

    final recipe = await service.recipeManager.get(remoteId);
    if (recipe == null) {
      throw ApiError(ApiErrorType.resourceNotFound,
          message:
              "Failed to find any published recipe with that ID. Your local recipe may have been terribly out of sync with the published version.");
    }
    final result = await service.localRecipeManager.sync(
      recipe: recipe,
      localId: localId,
      userId: uid,
    );
    return result;
  }

  Future<LocalRecipeModel> run(SyncRecipePayload payload) async {
    return await recipeManager.noTimerContext.run((initials) async {
      final result = await compute(_run, (
        uid: payload.uid,
        service: this,
        localId: payload.localId,
        remoteId: payload.remoteId,
        isolateToken: ServicesBinding.rootIsolateToken!,
      ));
      return result;
    });
  }
}

class SyncAllRecipesService {
  final FirebaseRecipeManager recipeManager;
  final RecipeTable localRecipeManager;

  SyncAllRecipesService(
      {required this.recipeManager, required this.localRecipeManager});

  static void _run(_SyncAllRecipesIsolatePayload payload) async {
    final (:service, :uid, :isolateToken) = payload;
    BackgroundIsolateBinaryMessenger.ensureInitialized(isolateToken);
    final (data: remoteRecipes, nextPage: _) = await service.recipeManager
        .getRegularRecipes(
            lite: false,
            limit: 1000,
            filter: RecipeFilterBy.createdByUser(uid));
    await service.localRecipeManager
        .syncAll(remoteRecipes.cast<RecipeModel>(), userId: uid);
  }

  Future<void> run(SyncAllRecipesPayload payload) async {
    return recipeManager.noTimerContext.run((initials) {
      return compute(_run, (
        uid: payload.uid,
        service: this,
        isolateToken: ServicesBinding.rootIsolateToken!
      ));
    });
  }
}
