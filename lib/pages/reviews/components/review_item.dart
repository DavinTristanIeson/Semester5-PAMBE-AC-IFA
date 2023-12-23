import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/display/future.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'package:pambe_ac_ifa/components/display/review_card.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/models/review.dart';
import 'package:provider/provider.dart';

class ReviewItem extends StatefulWidget {
  final ReviewModel review;
  final Future<void> Function(ReviewModel review) onDeleted;
  const ReviewItem({super.key, required this.review, required this.onDeleted});
  static const int maximumShownReviewLength = 300;

  @override
  State<ReviewItem> createState() => _ReviewItemState();
}

class _ReviewItemState extends State<ReviewItem> {
  bool isShown = false;

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
              backgroundImage: widget.review.user == null
                  ? MaybeImage.fallbackUserImage
                  : widget.review.user!.image,
            ),
            const SizedBox(
              width: AcSizes.space,
            ),
            Column(
              children: [
                Text(
                  widget.review.user?.name ?? "common/deleted_user".i18n(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AcSizes.fontEmphasis,
                      fontStyle:
                          widget.review.user == null ? FontStyle.italic : null),
                ),
                Text(widget.review.createdAt.toLocaleString(),
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
          rating: widget.review.rating,
          type: StarRatingType.wide,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().user!.uid;
    return Container(
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(AcSizes.br),
            color: context.colors.surface,
            boxShadow: const [AcDecoration.shadowSmall]),
        padding: const EdgeInsets.all(AcSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildUserAndRating(context),
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
                  style: TextButton.styleFrom(
                      foregroundColor: context.colors.secondary),
                  onPressed: () {
                    setState(() {
                      isShown = !isShown;
                    });
                  },
                  child: Text(isShown ? "screen/reviews/components/hide".i18n() : "screen/reviews/components/show_more".i18n())),
            if (widget.review.user?.id == uid)
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Tooltip(
                  message: "screen/reviews/components/delete_review".i18n(),
                  child: FutureIconButton(
                    onPressed: () => widget.onDeleted(widget.review),
                    icon: Icon(Icons.delete, color: context.colors.error),
                  ),
                )
              ]),
          ],
        ));
  }
}
