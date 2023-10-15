import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'package:pambe_ac_ifa/components/display/notice.dart';
import 'package:pambe_ac_ifa/components/display/review_card.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/models/review.dart';
import 'package:pambe_ac_ifa/pages/recipe/viewer.dart';
import 'package:pambe_ac_ifa/pages/reviews/main.dart';

class RecipeInfoScreen extends StatelessWidget {
  final RecipeModel recipe;
  final List<ReviewModel> reviews;
  const RecipeInfoScreen(
      {super.key, required this.recipe, required this.reviews});

  Widget buildTitle(BuildContext context) {
    // info required to position user avatar
    double imageHeight = MediaQuery.of(context).size.height / 4;
    return Stack(
      children: [
        Column(
          children: [
            ConstrainedBox(
                constraints: BoxConstraints.tightFor(
                    width: double.maxFinite, height: imageHeight),
                child: recipe.image == null
                    ? null
                    : AcImageContainer(
                        borderRadius: const BorderRadius.only(
                            topLeft: AcSizes.br, topRight: AcSizes.br),
                        child: MaybeImage(image: recipe.image!))),
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
              child: CircleAvatar(
                radius: AcSizes.avatarRadius,
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                backgroundImage: recipe.creator.image,
              )),
        ),
      ],
    );
  }

  Widget buildReviewList() {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: reviews
          .take(5)
          .map<Widget>((e) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AcSizes.md),
                child: ReviewCard(
                    rating: e.rating,
                    reviewer: e.reviewer,
                    reviewedAt: e.reviewedAt,
                    content: Either.right(e.content)),
              ))
          .toList(),
    );
  }

  Row buildSeeReviewsButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // To make sure the text is centered
        const SizedBox(width: AcSizes.lg + AcSizes.sm),
        Text(
          "SEE WHAT OTHERS THINK",
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        IconButton(
            onPressed: () {
              context.navigator.push(MaterialPageRoute(
                  builder: (context) => ReviewScreen(
                        recipeId: recipe.id,
                      )));
            },
            iconSize: AcSizes.lg,
            icon: Icon(Icons.arrow_right_alt,
                color: Theme.of(context).colorScheme.primary))
      ],
    );
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

  Widget buildStartButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => RecipeViewerScreen(recipe: recipe)));
        },
        style: ElevatedButton.styleFrom(
            fixedSize: Size(MediaQuery.of(context).size.width / 2, AcSizes.lg),
            textStyle: const TextStyle(
                fontSize: AcSizes.fontEmphasis, fontWeight: FontWeight.w600)),
        child: const Text("Start"),
      ),
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
            ),
            const SizedBox(height: AcSizes.lg),
            ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 160.0),
                child: buildReviewList()),
            const SizedBox(height: AcSizes.md),
            buildSeeReviewsButton(context),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AcSizes.lg),
              child: buildStartButton(context),
            )
          ],
        ));
  }
}
