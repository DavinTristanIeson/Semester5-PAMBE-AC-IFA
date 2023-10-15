import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/user.dart';
import 'package:pambe_ac_ifa/pages/reviews/main.dart';

enum StarRatingType {
  compact,
  wide,
}

class StarRating extends StatelessWidget {
  final double rating;
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
    int starsCount = clampDouble(rating, 0, 5).round();
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
  final double rating;
  final Either<Widget, String>? content;
  final UserModel reviewer;
  final DateTime reviewedAt;
  final MinimalModel? reviewFor;
  const ReviewCard(
      {super.key,
      required this.rating,
      this.content,
      required this.reviewer,
      required this.reviewedAt,
      this.reviewFor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: reviewFor == null
          ? null
          : () {
              context.navigator.push(MaterialPageRoute(
                  builder: (context) => ReviewScreen(
                        recipeId: reviewFor!.id,
                      )));
            },
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.all(AcSizes.br),
            boxShadow: const [AcDecoration.shadowSmall]),
        constraints: BoxConstraints.tight(Size.fromWidth(
            clampDouble(MediaQuery.of(context).size.width / 3, 200.0, 300.0))),
        padding: const EdgeInsets.all(AcSizes.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            buildUserAndRating(context),
            const SizedBox(height: AcSizes.md),
            if (content != null)
              content!.leftOr(
                (right) => Text(right,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildUserAndRating(BuildContext context) {
    Widget reviewerNameWidget = Text(reviewer.name,
        style: context.texts.titleMedium, overflow: TextOverflow.ellipsis);
    Widget starRatingWidget =
        StarRating(rating: rating, type: StarRatingType.compact);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: AcSizes.lg + AcSizes.md,
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          backgroundImage: reviewer.image,
        ),
        const SizedBox(width: AcSizes.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            reviewFor != null
                ? Row(
                    children: [
                      reviewerNameWidget,
                      const SizedBox(width: AcSizes.space),
                      starRatingWidget
                    ],
                  )
                : reviewerNameWidget,
            reviewFor != null
                ? Text("on ${reviewFor!.name}", style: context.texts.titleSmall)
                : starRatingWidget
          ],
        ),
      ],
    );
  }
}