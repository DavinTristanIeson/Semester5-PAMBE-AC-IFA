import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/recipe/main.dart';
import 'package:provider/provider.dart';

class RecipeCard extends StatelessWidget {
  final RecipeLiteModel recipe;
  final RecipeSource recipeSource;
  final Widget? secondaryAction;
  const RecipeCard(
      {super.key,
      required this.recipe,
      this.secondaryAction,
      this.recipeSource = RecipeSource.online});

  Widget buildTitleAndDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(recipe.title, style: Theme.of(context).textTheme.titleMedium),
        Text("by ${recipe.user.name}",
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AcSizes.lg),
        Text(recipe.description),
      ],
    );
  }

  static ButtonStyle getSecondaryActionButtonStyle(BuildContext context) =>
      OutlinedButton.styleFrom(
          foregroundColor: context.colors.secondary,
          side: BorderSide(color: context.colors.secondary));

  Widget buildButtons(BuildContext context) {
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (secondaryAction == null && isLoggedIn)
          OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.secondary,
                  side: BorderSide(color: context.colors.secondary)),
              onPressed: () {
                // TODO: Bookmark
              },
              icon: const Icon(Icons.bookmark),
              label: const Text("Bookmark")),
        if (secondaryAction != null) secondaryAction!,
        const SizedBox(
          width: AcSizes.sm,
        ),
        ElevatedButton.icon(
            onPressed: () {
              context.navigator.push(MaterialPageRoute(
                  builder: (context) => RecipeScreen(
                        id: recipe.id,
                        source: recipeSource,
                      )));
            },
            icon: const Icon(Icons.remove_red_eye_outlined),
            label: const Text("View")),
      ],
    );
  }

  static Size getDefaultImageSize(BuildContext context) {
    return Size(context.relativeWidth(1 / 1.4, 300.0, 450.0),
        context.relativeHeight(1 / 3.5, 120.0, 180.0));
  }

  @override
  Widget build(BuildContext context) {
    Size defaultSize = getDefaultImageSize(context);
    double imageHeight = defaultSize.height;
    double imageWidth = defaultSize.width;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.all(AcSizes.br),
        boxShadow: const [AcDecoration.shadowRegular],
      ),
      constraints: BoxConstraints.tight(Size(imageWidth, imageHeight)),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.maxFinite,
                height: imageHeight,
                child: AcImageContainer(
                  borderRadius: const BorderRadius.only(
                      topLeft: AcSizes.br, topRight: AcSizes.br),
                  child: MaybeImage(
                    image: recipe.image,
                    height: imageHeight,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildTitleAndDescription(context),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(
                    right: AcSizes.md, bottom: AcSizes.md),
                child: buildButtons(context),
              ),
            ],
          ),
          Positioned(
            top: imageHeight - AcSizes.avatarRadius,
            right: AcSizes.xs,
            child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: AcSizes.md),
                ),
                child: CircleAvatar(
                    radius: AcSizes.avatarRadius,
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    backgroundImage: recipe.user.image)),
          )
        ],
      ),
    );
  }
}

class RecipeHorizontalCard extends StatelessWidget {
  final RecipeLiteModel recipe;
  final RecipeSource recipeSource;
  const RecipeHorizontalCard(
      {super.key,
      required this.recipe,
      this.recipeSource = RecipeSource.online});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(AcSizes.brInput),
      child: Material(
        color: context.colors.surface,
        child: ListTile(
          splashColor: context.colors.primary.withOpacity(0.3),
          onTap: () {
            context.navigator.push(MaterialPageRoute(
                builder: (context) =>
                    RecipeScreen(id: recipe.id, source: recipeSource)));
          },
          leading: CircleAvatar(
            backgroundColor: context.colors.tertiary,
            backgroundImage: recipe.user.image,
          ),
          title: Text(recipe.title,
              style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text("by ${recipe.user.name}",
              style: Theme.of(context).textTheme.titleSmall),
          trailing: MaybeImage(
              image: recipe.image,
              width: context.relativeWidth(0.2, 60.0, 150.0)),
        ),
      ),
    );
  }
}
