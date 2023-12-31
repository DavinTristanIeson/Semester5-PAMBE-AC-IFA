import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pambe_ac_ifa/database/firebase/auth.dart';
import 'package:pambe_ac_ifa/database/firebase/recipe.dart';
import 'package:pambe_ac_ifa/database/firebase/user.dart';
import 'package:pambe_ac_ifa/database/interfaces/user.dart';
import 'package:pambe_ac_ifa/database/sqflite/tables/recipe.dart';
import 'package:pambe_ac_ifa/firebase_options.dart';

typedef DeleteAccountPayload = ({String uid, LoginPayload credentials});
typedef _DeleteAccountIsolatePayload = ({
  String uid,
  DeleteAccountService service,
  RootIsolateToken isolateToken,
});

class DeleteAccountService {
  final FirebaseRecipeManager recipeManager;
  final RecipeTable localRecipeManager;
  final FirebaseUserManager userManager;
  final FirebaseAuthManager authManager;

  DeleteAccountService({
    required this.recipeManager,
    required this.localRecipeManager,
    required this.userManager,
    required this.authManager,
  });

  static void _run(_DeleteAccountIsolatePayload payload) async {
    final (:service, :uid, :isolateToken) = payload;
    BackgroundIsolateBinaryMessenger.ensureInitialized(isolateToken);
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await service.localRecipeManager.removeAllByUser(uid);
    await service.recipeManager.removeAllByUser(uid);
    await service.userManager.remove(uid);
  }

  Future<void> cleanup(DeleteAccountPayload payload) async {
    recipeManager.cache
        .markStale(where: (key, item) => item.value?.user?.id == payload.uid);
    recipeManager.queryCache.clear();
    userManager.cache.markStale(key: payload.uid);
    await authManager.logout();
  }

  Future<void> run(DeleteAccountPayload payload) async {
    await recipeManager.noTimerContext.run((_) async {
      await compute(_run, (
        uid: payload.uid,
        service: this,
        isolateToken: ServicesBinding.rootIsolateToken!
      ));
      await authManager.deleteAccount(payload.uid,
          credentials: payload.credentials);
      await cleanup(payload);
    });
  }
}
