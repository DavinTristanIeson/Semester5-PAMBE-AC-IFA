import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/search/body.dart';
import 'package:pambe_ac_ifa/pages/search/search_bar.dart';

class SearchScreen extends StatefulWidget {
  final SortBy<RecipeSortBy>? sortBy;
  final RecipeFilterBy? filterBy;
  final String? search;
  const SearchScreen({super.key, this.sortBy, this.filterBy, this.search});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late RecipeLibSearchState searchState;

  @override
  void initState() {
    super.initState();
    searchState = RecipeLibSearchState(
        search: widget.search,
        sortBy: widget.sortBy ?? SortBy.descending(RecipeSortBy.ratings),
        filterBy: null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const OnlyReturnAppBar(),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: AcSizes.space,
                  right: AcSizes.space,
                  bottom: AcSizes.lg),
              child: AcSearchBar(
                  value: searchState.search,
                  onSearch: (value) {
                    setState(() {
                      searchState = searchState.copyWith(search: value);
                    });
                  }),
            ),
            Expanded(child: SearchScreenBody(searchState: searchState))
          ],
        ));
  }
}
