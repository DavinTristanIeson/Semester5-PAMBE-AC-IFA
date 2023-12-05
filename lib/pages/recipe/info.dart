import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'package:pambe_ac_ifa/components/display/notice.dart';
import 'package:pambe_ac_ifa/components/display/recipe_card.dart';
import 'package:pambe_ac_ifa/components/display/review_card.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/models/review.dart';
import 'package:pambe_ac_ifa/pages/profile/main.dart';
import 'package:pambe_ac_ifa/pages/recipe/viewer.dart';
import 'package:pambe_ac_ifa/pages/reviews/main.dart';
import 'package:provider/provider.dart';

class RecipeInfoScreen extends StatelessWidget {
  final AbstractRecipeLiteModel recipe;
  final List<AbstractRecipeStepModel> steps;
  final List<ReviewModel>? reviews;
  const RecipeInfoScreen(
      {super.key,
      required this.recipe,
      required this.reviews,
      required this.steps});

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
                child: AcImageContainer(
                    borderRadius: const BorderRadius.only(
                        topLeft: AcSizes.br, topRight: AcSizes.br),
                    child: MaybeImage(image: recipe.image))),
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
                        if (recipe is RecipeLiteModel)
                          ByUserText(
                            user: (recipe as RecipeLiteModel).user,
                            style: AcTypography.importantDescription,
                          ),
                      ],
                    ),
                  ],
                )),
          ],
        ),
        if (recipe is RecipeLiteModel &&
            (recipe as RecipeLiteModel).user != null)
          Positioned(
            right: AcSizes.space,
            top: imageHeight - AcSizes.avatarRadius,
            child: GestureDetector(
              onTap: () {
                final user = (recipe as RecipeLiteModel).user;
                context.navigator.push(MaterialPageRoute(builder: (context) {
                  return OtherUserProfileScreen(userId: user!.id);
                }));
              },
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
                    backgroundImage: (recipe as RecipeLiteModel).user?.image,
                  )),
            ),
          ),
      ],
    );
  }

  Widget buildReviewList() {
    if (reviews!.isEmpty) {
      return EmptyView(
        content: Either.right(
            "This recipe hadn't had any reviews.\nBe the first to comment!"),
      );
    }
    return ListView(
      scrollDirection: Axis.horizontal,
      children: reviews!
          .take(5)
          .map<Widget>((e) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AcSizes.md),
                child: ReviewCard(review: e),
              ))
          .toList(),
    );
  }

  Widget buildSeeReviewsButton(BuildContext context, String recipeId) {
    final auth = context.watch<AuthProvider>();
    final recipe = this.recipe as RecipeLiteModel;
    return Column(
      children: [
        if (recipe.rating > 0.0)
          Padding(
            padding: const EdgeInsets.only(top: AcSizes.lg),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  recipe.rating.toString(),
                  style: TextStyle(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: AcSizes.fontLarge,
                  ),
                ),
                const SizedBox(width: AcSizes.sm),
                Icon(
                  Icons.star,
                  color: context.colors.primary,
                ),
              ],
              // To make sure the text is centered
            ),
          ),
        TextButton(
          onPressed: () {
            context.navigator.push(MaterialPageRoute(
                builder: (context) => ReviewsScreen(
                      recipeId: recipeId,
                      permission: auth.isGuest ||
                              (recipe.user != null &&
                                  recipe.user!.id == auth.user!.uid)
                          ? ReviewPermission.deny
                          : ReviewPermission.permit,
                    )));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: AcSizes.lg + AcSizes.sm),
              Text(
                "SEE WHAT OTHERS THINK",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.arrow_right_alt,
                  color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
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
              builder: (context) =>
                  RecipeViewerScreen(recipe: recipe, steps: steps)));
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
    String? recipeId = recipe is RecipeLiteModel
        ? (recipe as RecipeLiteModel).id
        : recipe is LocalRecipeLiteModel
            ? (recipe as LocalRecipeLiteModel).remoteId
            : null;
    return ListView(
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
                      "This tutorial has ${AbstractRecipeStepModel.countSteps(steps)} steps"),
                  type: NoticeType.tip)
            ],
          ),
          const SizedBox(height: AcSizes.lg),
          if (reviews != null)
            ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 160.0),
                child: buildReviewList()),
          if (recipeId != null && recipe is RecipeLiteModel)
            buildSeeReviewsButton(context, recipeId),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AcSizes.lg),
            child: buildStartButton(context),
          )
        ]);
  }
}
