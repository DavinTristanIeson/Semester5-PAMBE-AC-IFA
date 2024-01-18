import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
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
                        permission: ReviewPermission.deny,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: AcSizes.avatarRadius,
              backgroundColor: context.colors.tertiary,
              backgroundImage: review.user == null
                  ? MaybeImage.fallbackUserImage
                  : review.user!.image,
            ),
            const SizedBox(
              width: AcSizes.space,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.user?.name ?? "common/deleted_user".i18n(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AcSizes.fontEmphasis,
                      fontStyle: review.user == null ? FontStyle.italic : null),
                ),
                Text(review.createdAt.toLocaleString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: AcSizes.fontSmall,
                      fontStyle: FontStyle.italic,
                    )),
              ],
            )
          ],
        ),
        StarRating(
          rating: review.rating,
          type: StarRatingType.compact,
        ),
      ],
    );
  }
}
