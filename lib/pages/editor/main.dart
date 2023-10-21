import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/controllers/local_recipe.dart';
import 'package:pambe_ac_ifa/pages/editor/body.dart';
import 'package:provider/provider.dart';

class RecipeEditorScreen extends StatelessWidget {
  final String? recipeId;
  const RecipeEditorScreen({super.key, this.recipeId});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LocalRecipeController>();
    final user = context.watch<AuthProvider>().user!;
    return FutureBuilder(
        future: recipeId == null || int.tryParse(recipeId!) == null
            ? Future.value(null)
            : controller.get(int.parse(recipeId!), user),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final recipe = snapshot.data;
          if (recipeId == null || recipe == null) {
            return const RecipeEditorScreenBody();
          } else {
            return RecipeEditorScreenBody(
              recipe: recipe,
            );
          }
        });
  }
}
