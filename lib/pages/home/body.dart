import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'package:pambe_ac_ifa/components/display/recipe_card.dart';
import 'package:pambe_ac_ifa/components/display/review_card.dart';
import 'package:pambe_ac_ifa/components/display/some_items_scroll.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/controllers/recipe.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/models/user.dart';
import 'package:pambe_ac_ifa/pages/search/main.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class HomePageBody extends StatelessWidget {
  static RecipeModel debugRecipe = RecipeModel(
    id: '0',
    createdAt: DateTime.now(),
    creator: UserModel(
        id: "0",
        name: "User",
        email: "placeholder@email.com",
        imagePath: "https://www.google.com"),
    description: "Description",
    steps: [],
    title: "Recipe Titlex",
    imagePath: "",
    imageSource: ExternalImageSource.local,
  );
  const HomePageBody({super.key});

  Widget buildRecentRecipes(BuildContext context) {
    RecipeController controller =
        Provider.of<RecipeController>(context, listen: true);

    final userId = context.watch<AuthProvider>().user!.id;
    return FutureBuilder(
        future: http.get(Uri.parse("http://101.128.75.229:3000/api/recipes")),
        // future: controller.getAll(RecipeSearchState(
        //     search: 'abc',
        //     sortBy: SortBy.ascending(RecipeSortBy.createdDate),
        //     filterBy: RecipeFilterBy.local)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return SampleScrollSection(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return RecipeCard(recipe: debugRecipe);
                },
                header: Either.right("Recents"),
                viewMoreButton: Either.right(() {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SearchScreen(
                            sortBy: SortBy.descending(
                                RecipeSortBy.lastViewed(by: userId)),
                            filterBy:
                                RecipeFilterBy.viewedBy(userId, viewed: true),
                          )));
                }));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return SampleScrollSection(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return RecipeCard(recipe: debugRecipe);
                },
                header: Either.right("Recents"),
                viewMoreButton: Either.right(() {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SearchScreen(
                            sortBy: SortBy.descending(
                                RecipeSortBy.lastViewed(by: userId)),
                            filterBy:
                                RecipeFilterBy.viewedBy(userId, viewed: true),
                          )));
                }));
          } else {
            if (snapshot.hasError) {
              print(snapshot.error);
            }
            return const Text('Error');
          }
        });
  }

  Widget buildTrendingRecipes(BuildContext context) {
    final userId = context.watch<AuthProvider>().user!.id;
    return SampleScrollSection(
        itemCount: 3,
        itemBuilder: (context, index) {
          return RecipeCard(recipe: debugRecipe);
        },
        header: Either.right("Trending"),
        viewMoreButton: Either.right(() {
          context.navigator.push(MaterialPageRoute(
              builder: (context) => SearchScreen(
                    sortBy: SortBy.descending(RecipeSortBy.ratings),
                    filterBy: RecipeFilterBy.viewedBy(userId, viewed: false),
                  )));
        }));
  }

  Widget buildLatestReviews(BuildContext context) {
    return SampleScrollSection(
        itemCount: 5,
        constraints: BoxConstraints.tight(
            Size.fromHeight(context.relativeHeight(1 / 5, 140.0, 180.0))),
        itemBuilder: (context, index) {
          return ReviewCard(
            rating: 3.5,
            reviewer: debugRecipe.creator,
            reviewedAt: DateTime.now(),
            content: Either.right("Review"),
            reviewFor:
                MinimalModel(id: debugRecipe.id, name: debugRecipe.title),
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
        Padding(
          padding: edgeInsets,
          child: buildRecentRecipes(context),
        ),
        Padding(
          padding: edgeInsets,
          child: buildTrendingRecipes(context),
        ),
        Padding(
          padding: edgeInsets,
          child: buildLatestReviews(context),
        ),
      ],
    );
  }
}
