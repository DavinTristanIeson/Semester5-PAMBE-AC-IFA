import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'package:pambe_ac_ifa/components/display/recipe_card.dart';
import 'package:pambe_ac_ifa/components/display/some_items_scroll.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/models/user.dart';
import 'package:pambe_ac_ifa/pages/editor/main.dart';
import 'package:pambe_ac_ifa/pages/library/your_recipes.dart';
import 'package:pambe_ac_ifa/pages/search/main.dart';
import 'package:provider/provider.dart';

class LibraryScreen extends StatelessWidget {
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
    title: "Recipe Title",
    imagePath: "",
    imageSource: ExternalImageSource.local,
  );
  const LibraryScreen({super.key});

  Widget buildBookmarkedSection(BuildContext context) {
    final userId = context.watch<AuthProvider>().user!.id;
    return SampleScrollSection(
        itemCount: 3,
        itemBuilder: (context, index) {
          return RecipeCard(
            recipe: debugRecipe,
            secondaryAction: OutlinedButton.icon(
                style: RecipeCard.getSecondaryActionButtonStyle(context),
                onPressed: () {
                  // TODO: Unbookmark
                },
                icon: const Icon(Icons.bookmark_remove),
                label: const Text("Remove")),
          );
        },
        header: Either.right("Bookmarks"),
        viewMoreButton: Either.right(() {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SearchScreen(
                    sortBy:
                        SortBy.descending(RecipeSortBy.lastViewed(by: userId)),
                    filterBy: RecipeFilterBy.bookmarkedBy(userId),
                  )));
        }));
  }

  @override
  Widget build(BuildContext context) {
    const EdgeInsets edgeInsets = EdgeInsets.only(
        left: AcSizes.space, right: AcSizes.space, bottom: AcSizes.lg);
    return Stack(
      children: [
        ListView(
          children: [
            Padding(
              padding: edgeInsets,
              child: buildBookmarkedSection(context),
            ),
            const YourRecipesSection(),
            const SizedBox(
              height: AcSizes.xxl,
            ),
          ],
        ),
        Positioned(
          right: AcSizes.space,
          bottom: AcSizes.space,
          child: FloatingActionButton.extended(
            onPressed: () {
              context.navigator.push(MaterialPageRoute(
                  builder: (context) => const RecipeEditorScreen()));
            },
            icon: const Icon(Icons.add),
            label: const Text("Create Recipe"),
          ),
        )
      ],
    );
  }
}
