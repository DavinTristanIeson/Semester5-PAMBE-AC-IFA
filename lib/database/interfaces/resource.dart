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
  Future<File?> put(XFile? resource, {String? former});
  Future<void> remove(String imagePath);
}

abstract class IUserController {
  Future<UserModel> login(LoginPayload payload);
  Future<UserModel> register(RegisterPayload payload);
  Future<UserModel> getMe();
}

abstract class IRecipeController {
  Future<List<RecipeLiteModel>> getAll(RecipeSearchState searchState,
      {int? page});
  Future<RecipeModel> get(String id);
  Future<int> put(RecipeModel recipe);
  Future<void> remove();
}
