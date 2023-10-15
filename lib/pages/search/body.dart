import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'package:pambe_ac_ifa/components/display/recipe_card.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/models/user.dart';

class SearchScreenBody extends StatefulWidget {
  final RecipeLibSearchState searchState;
  const SearchScreenBody({super.key, required this.searchState});

  @override
  State<SearchScreenBody> createState() => _SearchScreenBodyState();
}

class _SearchScreenBodyState extends State<SearchScreenBody> {
  final PagingController<int, RecipeLiteModel> _pagination =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagination.addPageRequestListener((pageKey) async {
      List<RecipeLiteModel> recipes =
          await fetchRecipes(widget.searchState, pageKey);
      // if (recipes.length != widget.searchState.limit) {
      //   _pagination.appendLastPage(recipes);
      // } else {
      _pagination.appendPage(recipes, pageKey + 1);
      // }
    });
    super.initState();
  }

  @override
  didUpdateWidget(covariant SearchScreenBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchState != widget.searchState) {
      _pagination.refresh();
    }
  }

  Future<List<RecipeLiteModel>> fetchRecipes(
      RecipeLibSearchState state, int pageKey) async {
    return [
      RecipeModel(
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
      )
    ];
  }

  @override
  void dispose() {
    _pagination.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, RecipeLiteModel>(
        pagingController: _pagination,
        builderDelegate: PagedChildBuilderDelegate(
            itemBuilder: (context, item, index) => Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: AcSizes.sm, horizontal: AcSizes.space),
                child: RecipeHorizontalCard(recipe: item))));
  }
}
