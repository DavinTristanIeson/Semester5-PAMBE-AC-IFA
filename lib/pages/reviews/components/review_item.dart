import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'package:pambe_ac_ifa/components/display/review_card.dart';
import 'package:pambe_ac_ifa/models/review.dart';

class ReviewItem extends StatefulWidget {
  final ReviewModel review;
  const ReviewItem({super.key, required this.review});
  static const int maximumShownReviewLength = 300;

  @override
  State<ReviewItem> createState() => _ReviewItemState();
}

class _ReviewItemState extends State<ReviewItem> {
  bool isShown = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(AcSizes.br),
            color: context.colors.surface,
            boxShadow: const [AcDecoration.shadowSmall]),
        padding: const EdgeInsets.all(AcSizes.md),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: AcSizes.avatarRadius,
                  backgroundImage: widget.review.user == null
                      ? MaybeImage.fallbackUserImage
                      : widget.review.user!.image,
                ),
                StarRating(
                  rating: widget.review.rating,
                  type: StarRatingType.wide,
                )
              ],
            ),
            if (widget.review.content != null)
              Padding(
                padding: const EdgeInsets.only(
                    top: AcSizes.space, bottom: AcSizes.md),
                child: Text(isShown
                    ? widget.review.content!
                    : widget.review.content!
                        .ellipsisIfExceed(ReviewItem.maximumShownReviewLength)),
              ),
            if (widget.review.content != null &&
                widget.review.content!.length >
                    ReviewItem.maximumShownReviewLength)
              TextButton(
                  onPressed: () {
                    setState(() {
                      isShown = !isShown;
                    });
                  },
                  child: Text(isShown ? "Hide" : "Show More"))
          ],
        ));
  }
}
