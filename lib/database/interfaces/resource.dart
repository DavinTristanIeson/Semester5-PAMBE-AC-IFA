import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/models/user.dart';

typedef LoginPayload = ({String email, String password});
typedef RegisterPayload = ({
  String email,
  String password,
  String name,
  String? bio,
  XFile? image,
});

abstract class IImageResourceManager {
  Future<File?> get(String imagePath);
  Future<List<String>> getAll();
  Future<File?> put(XFile? resource, {String? former});
  Future<void> process(Map<String, XFile?> resources);
  Future<MapEntry<String, XFile>> reserve(XFile resource);
  Future<void> remove(String imagePath);
}

abstract class IUserResourceManager {
  Future<UserModel> login(LoginPayload payload);
  Future<UserModel> register(RegisterPayload payload);
  Future<UserModel> getMe();
}

abstract class IRecipeResourceManager {
  Future<List<RecipeLiteModel>> getAll(
      {int? page, RecipeSearchState? searchState});
  Future<RecipeModel> get(String id);
  Future<RecipeModel> put(LocalRecipeModel recipe);
  Future<void> remove(String id);
}
