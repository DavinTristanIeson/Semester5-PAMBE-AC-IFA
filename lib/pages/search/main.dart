import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/controllers/recipe.dart';
import 'package:pambe_ac_ifa/database/interfaces/recipe.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/modules/admanager.dart';
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
  late RecipeSearchState searchState;
  BannerAd? bannerAd;

  @override
  void initState() {
    super.initState();
    final (cachedBannerAd, futureBannerAd) =
        AdManager.of(context).loadBannerAd();
    bannerAd = cachedBannerAd;
    futureBannerAd.then((value) {
      setState(() {
        bannerAd = value;
      });
    });

    searchState = RecipeSearchState(
        search: widget.search,
        sortBy: widget.sortBy ?? SortBy.descending(RecipeSortBy.createdDate),
        filterBy: widget.filterBy);
  }

  @override
  Widget build(BuildContext context) {
    final adManager = AdManager.of(context);
    return Scaffold(
        appBar: const OnlyReturnAppBar(),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: AcSizes.space,
                right: AcSizes.space,
              ),
              child: AcSearchBar(
                  value: searchState.search,
                  onSearch: (value) {
                    setState(() {
                      searchState =
                          searchState.copyWith(search: Optional.some(value));
                    });
                  }),
            ),
            Expanded(child: SearchScreenBody(searchState: searchState)),
            adManager.buildBanner(bannerAd),
          ],
        ));
  }
}
