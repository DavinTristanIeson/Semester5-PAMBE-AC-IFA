import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/display/notice.dart';
import 'package:pambe_ac_ifa/components/display/recipe_card.dart';
import 'package:pambe_ac_ifa/controllers/local_recipe.dart';
import 'package:pambe_ac_ifa/controllers/recipe.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:provider/provider.dart';

class _SearchScreenBody extends StatelessWidget {
  final bool isLocal;
  final PagingController<dynamic, AbstractRecipeLiteModel> controller;
  const _SearchScreenBody({required this.controller, required this.isLocal});

  @override
  Widget build(BuildContext context) {
    return PagedListView<dynamic, AbstractRecipeLiteModel>(
        pagingController: controller,
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
                  recipeSource: isLocal
                      ? RecipeSource.local((item as LocalRecipeLiteModel).id)
                      : RecipeSource.remote((item as RecipeLiteModel).id),
                ))));
  }
}

class SearchScreenBody extends StatefulWidget {
  final RecipeSearchState searchState;
  const SearchScreenBody({super.key, required this.searchState});

  @override
  State<SearchScreenBody> createState() => _SearchScreenBodyState();
}

class _SearchScreenBodyState extends State<SearchScreenBody> {
  late final PagingController<dynamic, AbstractRecipeLiteModel> _pagination;

  @override
  void initState() {
    _pagination = PagingController(
        firstPageKey:
            widget.searchState.filterBy?.type == RecipeFilterByType.local
                ? 1
                : null);
    _pagination.addPageRequestListener((pageKey) async {
      final (:data, :nextPage) = await fetch(widget.searchState, pageKey);
      if (nextPage == null) {
        _pagination.appendLastPage(data);
      } else {
        _pagination.appendPage(data, nextPage);
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

  Future<PaginatedQueryResult<AbstractRecipeLiteModel>> fetch(
      RecipeSearchState state, dynamic pageKey) async {
    if (state.filterBy?.type == RecipeFilterByType.local) {
      final page = pageKey as int;
      final res = await context
          .read<LocalRecipeController>()
          .getAll(searchState: state, page: pageKey);
      return Future.value(
          (data: res, nextPage: res.length == state.limit ? page + 1 : null));
    } else {
      return Future.value(context
          .read<RecipeController>()
          .getAllWithPagination(state, page: pageKey));
    }
  }

  @override
  void dispose() {
    _pagination.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SearchScreenBody(controller: _pagination, isLocal: isLocal);
  }
}
