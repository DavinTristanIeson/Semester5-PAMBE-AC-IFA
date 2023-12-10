import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/models/user.dart';
import 'package:pambe_ac_ifa/pages/recipe/main.dart';

const localePrefix = "components.display.recipe_card";

class ByUserText extends StatelessWidget {
  final UserModel? user;
  final TextStyle? style;
  const ByUserText({super.key, this.user, this.style});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
        TextSpan(children: [
          TextSpan(text: "$localePrefix.by".i18n()),
          TextSpan(
              text: user?.name ?? '<Deleted User>',
              style: TextStyle(
                fontStyle: user == null ? FontStyle.italic : FontStyle.normal,
              ))
        ]),
        style: context.texts.titleSmall);
  }
}

class RecipeCard extends StatelessWidget {
  final AbstractRecipeLiteModel recipe;
  final RecipeSource recipeSource;
  final Widget? secondaryAction;
  const RecipeCard(
      {super.key,
      required this.recipe,
      this.secondaryAction,
      required this.recipeSource});

  Widget buildTitleAndDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(recipe.title, style: Theme.of(context).textTheme.titleMedium),
        if (recipe is RecipeLiteModel)
          ByUserText(user: (recipe as RecipeLiteModel).user),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (secondaryAction != null) secondaryAction!,
        const SizedBox(
          width: AcSizes.sm,
        ),
        ElevatedButton.icon(
            onPressed: () {
              context.navigator.push(MaterialPageRoute(
                  builder: (context) => RecipeScreen(
                        source: recipeSource,
                      )));
            },
            icon: const Icon(Icons.remove_red_eye_outlined),
            label: Text("$localePrefix.view".i18n())),
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
          if (recipe is RecipeLiteModel)
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
                      backgroundImage:
                          (recipe as RecipeLiteModel).user?.image)),
            )
        ],
      ),
    );
  }
}

class RecipeHorizontalCard extends StatelessWidget {
  final AbstractRecipeLiteModel recipe;
  final RecipeSource recipeSource;
  const RecipeHorizontalCard(
      {super.key, required this.recipe, required this.recipeSource});

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
                builder: (context) => RecipeScreen(source: recipeSource)));
          },
          leading: recipe is RecipeLiteModel
              ? CircleAvatar(
                  backgroundColor: context.colors.tertiary,
                  backgroundImage: (recipe as RecipeLiteModel).user?.image,
                )
              : null,
          title: Text(recipe.title,
              style: Theme.of(context).textTheme.titleMedium),
          subtitle: recipe is RecipeLiteModel
              ? ByUserText(user: (recipe as RecipeLiteModel).user)
              : null,
          trailing: MaybeImage(
              image: recipe.image,
              width: context.relativeWidth(0.2, 60.0, 150.0)),
        ),
      ),
    );
  }
}
