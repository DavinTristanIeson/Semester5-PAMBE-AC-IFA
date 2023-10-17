import 'package:flutter/foundation.dart';
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
  final Widget? secondaryAction;
  const RecipeCard({super.key, required this.recipe, this.secondaryAction});

  Widget buildTitleAndDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(recipe.title, style: Theme.of(context).textTheme.titleMedium),
        Text("by ${recipe.creator.name}",
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
                  builder: (context) => RecipeScreen(id: recipe.id)));
            },
            icon: const Icon(Icons.remove_red_eye_outlined),
            label: const Text("View")),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double imageHeight = clampDouble(context.screenHeight / 3.5, 120.0, 180.0);
    double imageWidth = clampDouble(context.screenWidth / 1.4, 300.0, 450.0);
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
                    backgroundImage: recipe.creator.image)),
          )
        ],
      ),
    );
  }
}

class RecipeHorizontalCard extends StatelessWidget {
  final RecipeLiteModel recipe;
  const RecipeHorizontalCard({super.key, required this.recipe});

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
                builder: (context) => RecipeScreen(id: recipe.id)));
          },
          leading: CircleAvatar(
            backgroundColor: context.colors.tertiary,
            backgroundImage: recipe.creator.image,
          ),
          title: Text(recipe.title,
              style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text("by ${recipe.creator.name}",
              style: Theme.of(context).textTheme.titleSmall),
          trailing: MaybeImage(
              image: recipe.image,
              width: context.relativeWidth(0.2, 60.0, 150.0)),
        ),
      ),
    );
  }
}
