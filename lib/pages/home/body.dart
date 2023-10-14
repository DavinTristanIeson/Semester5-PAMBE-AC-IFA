import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/components/display/some_items_scroll.dart';
import 'package:pambe_ac_ifa/models/container.dart';

class HomePageBody extends StatelessWidget {
  const HomePageBody({super.key});

  Widget buildRecentRecipes(BuildContext context) {
    return SampleScrollSection(
        itemCount: 0,
        itemBuilder: (context, index) {
          return const Placeholder();
        },
        header: Either.right("Recents"),
        viewMoreButton: Either.right(() {
          // TODO: Search Page
        }));
  }

  Widget buildTrendingRecipes(BuildContext context) {
    return SampleScrollSection(
        itemCount: 0,
        itemBuilder: (context, index) {
          return const Placeholder();
        },
        header: Either.right("Trending"),
        viewMoreButton: Either.right(() {
          // TODO: Search Page
        }));
  }

  Widget buildLatestReviews(BuildContext context) {
    return SampleScrollSection(
        itemCount: 0,
        itemBuilder: (context, index) {
          return const Placeholder();
        },
        header: Either.right("Latest Reviews"),
        viewMoreButton: Either.right(() {
          // TODO: Reviews page
        }));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        buildRecentRecipes(context),
        buildTrendingRecipes(context),
        buildLatestReviews(context),
      ],
    );
  }
}
