import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/user.dart';

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
  final User reviewer;
  final DateTime reviewedAt;
  const ReviewCard(
      {super.key,
      required this.rating,
      this.content,
      required this.reviewer,
      required this.reviewedAt});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.all(AcSizes.br),
          boxShadow: const [AcDecoration.shadowSmall]),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width / 3,
      ),
      padding: const EdgeInsets.all(AcSizes.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  Widget buildUserAndRating(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AcSizes.xl + AcSizes.lg),
          child: MaybeNetworkImage(
              url: reviewer.onlineImage,
              fit: BoxFit.cover,
              constraints: BoxConstraints.tight(
                  const Size.square(AcSizes.xl + AcSizes.lg))),
        ),
        const SizedBox(width: AcSizes.md),
        Text(reviewer.name, style: AcTypography.importantDescription),
        const Spacer(),
        StarRating(rating: rating, type: StarRatingType.compact),
      ],
    );
  }
}
