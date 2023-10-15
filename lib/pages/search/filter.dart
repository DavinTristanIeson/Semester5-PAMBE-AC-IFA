import 'package:pambe_ac_ifa/models/container.dart';

enum RecipeSortBy {
  trending,
  recentlyViewed,
  newlyCreated,
}

class RecipeLibSearchFilter {
  SortBy<RecipeSortBy> sortBy;
  List<String> tags;
  String? search;

  RecipeLibSearchFilter({
    required this.search,
    required this.tags,
    required this.sortBy,
  });
}
