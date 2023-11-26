import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/pages/home/components/sections.dart';

class HomePageBody extends StatelessWidget {
  const HomePageBody({super.key});

  @override
  Widget build(BuildContext context) {
    const EdgeInsets edgeInsets = EdgeInsets.only(
        left: AcSizes.space, right: AcSizes.space, bottom: AcSizes.lg);
    return ListView(
      children: const [
        Padding(
          padding: edgeInsets,
          child: HomeRecentRecipesSection(),
        ),
        Padding(
          padding: edgeInsets,
          child: HomeTrendingRecipesSection(),
        ),
        Padding(
          padding: edgeInsets,
          child: LatestReviewsSection(),
        ),
      ],
    );
  }
}
