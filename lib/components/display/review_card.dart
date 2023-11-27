import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/models/review.dart';
import 'package:pambe_ac_ifa/pages/reviews/main.dart';

enum StarRatingType {
  compact,
  wide,
}

class StarRating extends StatelessWidget {
  final int rating;
  final StarRatingType type;
  const StarRating(
      {super.key, required this.rating, this.type = StarRatingType.wide});

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      StarRatingType.compact => buildCompactVersion(context),
      StarRatingType.wide => buildWideVersion(context),
    };
  }

  Widget buildCompactVersion(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(rating.toString(), style: AcTypography.importantDescription),
        Icon(Icons.star, color: Theme.of(context).colorScheme.primary)
      ],
    );
  }

  Row buildWideVersion(BuildContext context) {
    int starsCount = rating;
    return Row(
      children: [
        for (int i = 0; i < starsCount; i++)
          Icon(
            Icons.star,
            color: Theme.of(context).colorScheme.primary,
          ),
        for (int i = starsCount; i < 5; i++)
          Icon(Icons.star, color: Theme.of(context).colorScheme.tertiary)
      ],
    );
  }
}

class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final String? recipeId;
  final String? recipeName;
  const ReviewCard({
    super.key,
    required this.review,
    this.recipeId,
    this.recipeName,
  });

  static double getWidth(BuildContext context) {
    return context.relativeWidth(0.333, 300.0, 500.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: recipeId == null
          ? null
          : () {
              context.navigator.push(MaterialPageRoute(
                  builder: (context) => ReviewsScreen(
                        recipeId: recipeId!,
                        reviewId: review.id,
                      )));
            },
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.all(AcSizes.br),
            boxShadow: const [AcDecoration.shadowSmall]),
        constraints: BoxConstraints.tight(Size.fromWidth(getWidth(context))),
        padding: const EdgeInsets.all(AcSizes.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            buildUserAndRating(context),
            const SizedBox(height: AcSizes.md),
            if (review.content != null)
              Text(review.content!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget buildUserAndRating(BuildContext context) {
    Widget reviewerNameWidget = Text(review.user?.name ?? "Deleted User",
        style: review.user == null
            ? context.texts.titleMedium!.copyWith(fontStyle: FontStyle.italic)
            : null,
        overflow: TextOverflow.ellipsis);
    Widget starRatingWidget =
        StarRating(rating: review.rating, type: StarRatingType.compact);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: AcSizes.lg + AcSizes.md,
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          backgroundImage: null,
        ),
        const SizedBox(width: AcSizes.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            recipeName != null
                ? Row(
                    children: [
                      reviewerNameWidget,
                      const SizedBox(width: AcSizes.space),
                      starRatingWidget
                    ],
                  )
                : reviewerNameWidget,
            recipeName != null
                ? Text("on $recipeName", style: context.texts.titleSmall)
                : starRatingWidget
          ],
        ),
      ],
    );
  }
}
