import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/app/confirmation.dart';
import 'package:pambe_ac_ifa/components/display/recipe_card.dart';
import 'package:pambe_ac_ifa/components/display/skeleton.dart';
import 'package:pambe_ac_ifa/components/display/some_items_scroll.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/editor/main.dart';
import 'package:pambe_ac_ifa/pages/library/load_default.dart';
import 'package:pambe_ac_ifa/pages/search/main.dart';

class _YourRecipesSectionList extends StatelessWidget {
  final List<RecipeLiteModel>? data;
  const _YourRecipesSectionList({required this.data});

  @override
  Widget build(BuildContext context) {
    return SampleScrollSection(
        itemCount: data == null ? 3 : data!.length,
        itemBuilder: (context, index) {
          if (data == null) {
            final defaultSize = RecipeCard.getDefaultImageSize(context);
            return Skeleton(
              width: defaultSize.width,
            );
          }
          return RecipeCard(
            recipe: data![index],
            secondaryAction: OutlinedButton.icon(
              style: RecipeCard.getSecondaryActionButtonStyle(context),
              onPressed: () {
                context.navigator.push(MaterialPageRoute(
                    builder: (context) => RecipeEditorScreen(
                          recipeId: data![index].id,
                        )));
              },
              icon: const Icon(Icons.edit),
              label: const Text("Edit"),
            ),
          );
        },
        header: Either.right("Your Recipes"),
        viewMoreButton: Either.right(() {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SearchScreen(
                    sortBy: SortBy.descending(RecipeSortBy.createdDate),
                    filterBy: RecipeFilterBy.local,
                  )));
        }));
  }
}

class YourRecipesSection extends StatefulWidget {
  const YourRecipesSection({super.key});

  @override
  State<YourRecipesSection> createState() => _YourRecipesSectionState();
}

class _YourRecipesSectionState extends State<YourRecipesSection> {
  Future<List<RecipeLiteModel>> _futureRecipes = Future.value([]);

  Widget buildButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AcSizes.space),
      child: TextButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => SimpleConfirmationDialog(
                    onConfirm: () async {
                      setState(() {
                        _futureRecipes = loadDefaultRecipes();
                      });
                    },
                    context: context,
                    message: Either.right(
                        "Are you sure you want to load the default recipes?")));
          },
          child: const Text("Load default recipes")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: AcSizes.space, right: AcSizes.space, bottom: AcSizes.lg),
          child: FutureBuilder(
              future: _futureRecipes,
              builder: (context, snapshot) {
                return _YourRecipesSectionList(
                    data: snapshot.connectionState == ConnectionState.done
                        ? snapshot.data
                        : null);
              }),
        ),
        const SizedBox(
          height: AcSizes.space,
        ),
        buildButton(context),
      ],
    );
  }
}
