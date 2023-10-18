import 'package:pambe_ac_ifa/models/recipe.dart';

Future<List<RecipeLiteModel>> loadDefaultRecipes() async {
  // TODO: Fikri kerjakan ini
  // Yang Future.delayed ini hapus saja. Ini cuma utk debug.
  return Future.delayed(const Duration(seconds: 3), () => <RecipeLiteModel>[]);
}
