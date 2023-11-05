import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/models/notification.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/models/user.dart';

typedef LoginPayload = ({String email, String password});
typedef UpdateAuthPayload = ({String? email, String? password});
typedef RegisterPayload = ({
  String email,
  String password,
  String name,
  String? bio,
  XFile? image,
});
typedef UserEditPayload = ({
  String name,
  String? bio,
  XFile? image,
  DateTime? birthdate,
  String? country,
});

abstract class ILocalImageResourceManager {
  Future<File?> get(String imagePath);
  Future<List<String>> getAll();
  Future<File?> put(XFile? resource, {String? former});
  Future<void> process(Map<String, XFile?> resources);
  FutureOr<MapEntry<String, XFile>> reserve(XFile resource);
  Future<void> remove(String imagePath);
}

abstract class INetworkImageResourceManager {
  String getPath({required String userId, required String name});
  Future<String?> urlof(String path);
  Future<String?> put(XFile? image, {String? former, required String userId});
  Future<void> process(Map<String, XFile?> resources, {required String userId});
  FutureOr<MapEntry<String, XFile>> reserve(XFile resource,
      {required String userId});
  Future<void> remove(String imagePath);
}

abstract class IUserResourceManager {
  Future<UserModel> login(LoginPayload payload);
  Future<UserModel> register(RegisterPayload payload);
  Future<UserModel?> get(String id);
  Future<UserModel?> put(String id, UserEditPayload payload);
  Future<UserModel?> remove(String id, {required LoginPayload credentials});
  Future<UserModel?> updateAuth(String id,
      {required UpdateAuthPayload payload, required LoginPayload credentials});

  void dispose();
}

typedef PaginatedQueryResult<T> = ({List<T> data, dynamic nextPage});

abstract class IRecipeResourceManager {
  Future<PaginatedQueryResult<RecipeLiteModel>> getAll(
      {Object? page, RecipeSearchState? searchState});
  Future<RecipeModel?> get(String id);
  Future<RecipeModel> put(
    LocalRecipeModel recipe, {
    required String userId,
  });
  Future<void> remove(String id);

  void dispose();
}

abstract class INotificationResourceManager {
  Future<PaginatedQueryResult<NotificationModel>> getAll(
      {dynamic page, required String userId});
  Future<void> markAllRead({required String userId});
  Future<bool> hasUnread({required String userId});
}
