import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/display/review_card.dart';
import 'package:pambe_ac_ifa/controllers/notification.dart';
import 'package:pambe_ac_ifa/controllers/review.dart';
import 'package:pambe_ac_ifa/database/interfaces/notification.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/notification.dart';
import 'package:pambe_ac_ifa/models/review.dart';
import 'package:pambe_ac_ifa/pages/home/components/async_scroll_section.dart';
import 'package:pambe_ac_ifa/pages/home/components/sections.dart';
import 'package:provider/provider.dart';

class HomePageBody extends StatelessWidget {
  const HomePageBody({super.key});

  Widget buildLatestReviews(BuildContext context) {
    final notificationController = context.watch<NotificationController>();
    final reviewController = context.watch<ReviewController>();
    final future = Future(() async {
      final reviewNotifications = await notificationController.getAll(
          filterBy: NotificationFilterBy.type(NotificationType.review),
          limit: 5);
      final reviews = await Future.wait(reviewNotifications
          .where(
              (element) => element.reviewId != null && element.recipeId != null)
          .map((notif) async {
        final review = await reviewController.get(
            reviewId: notif.reviewId!, recipeId: notif.recipeId!);
        return (recipeId: notif.recipeId, review: review);
      }));
      return reviews
          .where((e) => e.review != null)
          .cast<({String recipeId, ReviewModel review})>()
          .toList();
    });
    return AsyncApiSampleScrollSection(
      future: future,
      itemConstraints: BoxConstraints.tight(
          Size.fromHeight(context.relativeHeight(1 / 5, 140.0, 180.0))),
      header: Either.right("Latest Reviews"),
      viewMoreButton: null,
      itemBuilder: (context, item) {
        return ReviewCard(
          review: item.review,
          recipeId: item.recipeId,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const EdgeInsets edgeInsets = EdgeInsets.only(
        left: AcSizes.space, right: AcSizes.space, bottom: AcSizes.lg);
    return ListView(
      children: [
        const Padding(
          padding: edgeInsets,
          child: HomeRecentRecipesSection(),
        ),
        const Padding(
          padding: edgeInsets,
          child: HomeTrendingRecipesSection(),
        ),
        Padding(
          padding: edgeInsets,
          child: buildLatestReviews(context),
        ),
      ],
    );
  }
}
