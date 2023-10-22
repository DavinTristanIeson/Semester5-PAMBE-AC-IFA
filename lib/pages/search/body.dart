import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/display/notice.dart';
import 'package:pambe_ac_ifa/components/display/recipe_card.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/controllers/local_recipe.dart';
import 'package:pambe_ac_ifa/controllers/recipe.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:provider/provider.dart';

class SearchScreenBody extends StatefulWidget {
  final RecipeSearchState searchState;
  const SearchScreenBody({super.key, required this.searchState});

  @override
  State<SearchScreenBody> createState() => _SearchScreenBodyState();
}

class _SearchScreenBodyState extends State<SearchScreenBody> {
  final PagingController<int, RecipeLiteModel> _pagination =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    _pagination.addPageRequestListener((pageKey) async {
      List<RecipeLiteModel> recipes = await fetch(widget.searchState, pageKey);
      if (recipes.length != widget.searchState.limit) {
        _pagination.appendLastPage(recipes);
      } else {
        _pagination.appendPage(recipes, pageKey + 1);
      }
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

  bool get isLocal {
    return widget.searchState.filterBy?.type == RecipeFilterByType.local;
  }

  Future<List<RecipeLiteModel>> fetch(
      RecipeSearchState state, int pageKey) async {
    if (state.filterBy?.type == RecipeFilterByType.local) {
      final user = context.read<AuthProvider>().user!;
      final res = await context
          .read<LocalRecipeController>()
          .getAll(user: user, searchState: state, page: pageKey);
      return res;
    }

    final res =
        await context.read<RecipeController>().getAll(state, page: pageKey);
    return res.data;
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
            noItemsFoundIndicatorBuilder: (context) {
              return Padding(
                padding: const EdgeInsets.all(AcSizes.space),
                child: EmptyView(content: Either.right("No recipes found")),
              );
            },
            itemBuilder: (context, item, index) => Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: AcSizes.sm, horizontal: AcSizes.space),
                child: RecipeHorizontalCard(
                  recipe: item,
                  recipeSource:
                      isLocal ? RecipeSource.local : RecipeSource.online,
                ))));
  }
}
