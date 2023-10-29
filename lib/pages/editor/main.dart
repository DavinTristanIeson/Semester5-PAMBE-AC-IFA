import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/controllers/local_recipe.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/editor/form.dart';
import 'package:provider/provider.dart';

class RecipeEditorScreen extends StatefulWidget {
  final int? recipeId;
  const RecipeEditorScreen({super.key, this.recipeId});

  @override
  State<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends State<RecipeEditorScreen> {
  LocalRecipeModel? recipe;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    final controller = context.read<LocalRecipeController>();
    if (widget.recipeId != null) {
      controller.get(widget.recipeId!).then((value) {
        setState(() {
          recipe = value;
          loaded = true;
        });
      });
    } else {
      loaded = true;
    }
  }

  void onRecipeChanged(LocalRecipeModel recipe) {
    setState(() {
      this.recipe = recipe;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (recipe == null) {
      return RecipeEditorScreenForm(
        onChanged: onRecipeChanged,
      );
    } else {
      return RecipeEditorScreenForm(
        recipe: recipe,
        onChanged: onRecipeChanged,
      );
    }
  }
}
