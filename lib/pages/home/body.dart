import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/display/review_card.dart';
import 'package:pambe_ac_ifa/components/display/some_items_scroll.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/pages/home/components/sections.dart';

class HomePageBody extends StatelessWidget {
  const HomePageBody({super.key});

  Widget buildLatestReviews(BuildContext context) {
    return SampleScrollSection(
        itemCount: 5,
        constraints: BoxConstraints.tight(
            Size.fromHeight(context.relativeHeight(1 / 5, 140.0, 180.0))),
        itemBuilder: (context, index) {
          return ReviewCard(
            rating: 3,
            reviewer: null,
            reviewedAt: DateTime.now(),
            content: Either.right("Review"),
            reviewFor: MinimalModel(id: '0', name: "Recipe Review"),
          );
        },
        header: Either.right("Latest Reviews"),
        viewMoreButton: null);
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
