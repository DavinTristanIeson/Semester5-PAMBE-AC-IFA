import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/display/recipe_card.dart';
import 'package:pambe_ac_ifa/components/display/review_card.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/controllers/notification.dart';
import 'package:pambe_ac_ifa/controllers/recipe.dart';
import 'package:pambe_ac_ifa/controllers/review.dart';
import 'package:pambe_ac_ifa/database/interfaces/notification.dart';
import 'package:pambe_ac_ifa/database/interfaces/recipe.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/notification.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/models/review.dart';
import 'package:pambe_ac_ifa/pages/home/components/async_scroll_section.dart';
import 'package:pambe_ac_ifa/pages/search/main.dart';
import 'package:provider/provider.dart';

const String _localePrefix = "screen/home/sections";

class HomeRecentRecipesSection extends StatelessWidget {
  const HomeRecentRecipesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecipeController>();
    return AsyncApiSampleScrollSection(
        future: controller.getRecentRecipes(),
        itemBuilder: (context, data) => RecipeCard(
              recipe: data,
              recipeSource: RecipeSource.remote(data.id),
            ),
        header: Either.right("$_localePrefix/recents".i18n()),
        viewMoreButton: null,
        itemConstraints:
            BoxConstraints.tight(RecipeCard.getDefaultImageSize(context)));
  }
}

class HomeTrendingRecipesSection extends StatelessWidget {
  const HomeTrendingRecipesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecipeController>();
    final userId = context.watch<AuthProvider>().user?.uid;
    return AsyncApiSampleScrollSection(
        future: controller.getTrendingRecipes(),
        itemBuilder: (context, data) => RecipeCard(
              recipe: data,
              recipeSource: RecipeSource.remote(data.id),
            ),
        header: Either.right("$_localePrefix/trending"),
        viewMoreButton: Either.right(() {
          context.navigator.push(MaterialPageRoute(
              builder: (context) => SearchScreen(
                    sortBy: SortBy.descending(RecipeSortBy.ratings),
                    filterBy:
                        userId == null ? null : RecipeFilterBy.viewedBy(userId),
                  )));
        }),
        itemConstraints:
            BoxConstraints.tight(RecipeCard.getDefaultImageSize(context)));
  }
}

class LatestReviewsSection extends StatelessWidget {
  const LatestReviewsSection({super.key});

  @override
  Widget build(BuildContext context) {
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
    final constraints = BoxConstraints.tight(
        Size.fromHeight(context.relativeHeight(1 / 5, 130.0, 170.0)));
    return AsyncApiSampleScrollSection(
      future: future,
      itemConstraints: constraints,
      constraints: constraints.copyWith(
          minWidth: context.screenWidth, maxWidth: context.screenWidth),
      header: Either.right("screen/home/components/sections/latest_review".i18n()),
      viewMoreButton: null,
      itemBuilder: (context, item) {
        final width = ReviewCard.getWidth(context);
        return ConstrainedBox(
          constraints: constraints.copyWith(minWidth: width, maxWidth: width),
          child: ReviewCard(
            review: item.review,
            recipeId: item.recipeId,
          ),
        );
      },
    );
  }
}
