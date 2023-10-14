import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  const RecipeCard({super.key, required this.recipe});

  Widget buildTitleAndDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(recipe.title, style: Theme.of(context).textTheme.titleMedium),
        Text("by ${recipe.creator?.name}",
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AcSizes.lg),
        Text(recipe.description),
      ],
    );
  }

  Widget buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.remove_red_eye_outlined),
            label: const Text("View")),
        const SizedBox(
          width: AcSizes.sm,
        ),
        ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.bookmark),
            label: const Text("Bookmark")),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double imageHeight = MediaQuery.of(context).size.height / 3.5;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(AcSizes.br),
        boxShadow: const [AcDecoration.shadowRegular],
      ),
      constraints: BoxConstraints.tight(Size.fromWidth(
          clampDouble(MediaQuery.of(context).size.width / 1.4, 300.0, 450.0))),
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
                child: buildButtons(),
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
                  backgroundImage: recipe.creator == null
                      ? const AssetImage(MaybeImage.fallbackImagePath)
                      : recipe.creator!.image,
                )),
          )
        ],
      ),
    );
  }
}
