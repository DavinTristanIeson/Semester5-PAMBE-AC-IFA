import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'package:pambe_ac_ifa/components/display/notice.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';

class RecipeInfoPage extends StatelessWidget {
  final Recipe recipe;
  const RecipeInfoPage({super.key, required this.recipe});

  Widget buildTitle(BuildContext context) {
    // info required to position user avatar
    double imageHeight = MediaQuery.of(context).size.height / 4;
    return Stack(
      children: [
        Column(
          children: [
            recipe.buildImage(
              constraints: BoxConstraints.tightFor(
                  width: double.maxFinite, height: imageHeight),
              borderRadius: const BorderRadius.only(
                  topLeft: AcSizes.br, topRight: AcSizes.br),
            ),
            Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    boxShadow: const [AcDecoration.shadowRegular],
                    borderRadius: const BorderRadius.only(
                        bottomLeft: AcSizes.br, bottomRight: AcSizes.br)),
                padding: const EdgeInsets.symmetric(
                    horizontal: AcSizes.space, vertical: AcSizes.md),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text("by ${recipe.creator.name}",
                            style: AcTypography.importantDescription)
                      ],
                    ),
                  ],
                )),
          ],
        ),
        Positioned(
          right: AcSizes.space,
          top: imageHeight - AcSizes.avatarRadius,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: AcSizes.md),
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(AcSizes.avatarRadius * 2),
                child: Container(
                  decoration: BoxDecoration(border: Border.all()),
                  child: MaybeNetworkImage(
                    url: recipe.creator.onlineImage,
                    fit: BoxFit.cover,
                    constraints: BoxConstraints.tight(
                        const Size.square(AcSizes.avatarRadius * 2)),
                  ),
                )),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const OnlyReturnAppBar(),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AcSizes.space),
          children: [
            buildTitle(context),
            const SizedBox(height: AcSizes.space),
            buildDescription(context),
            const SizedBox(height: AcSizes.space),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                NoticeComponent(
                    child: Either.right(
                        "This tutorial has ${recipe.steps.length} steps"),
                    type: NoticeType.tip)
              ],
            )
          ],
        ));
  }

  Container buildDescription(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(AcSizes.br),
          color: AcColors.card,
          boxShadow: [AcDecoration.shadowRegular]),
      constraints: const BoxConstraints(minHeight: AcSizes.xl * 2),
      padding: const EdgeInsets.all(AcSizes.lg),
      child: Text(recipe.description,
          style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
