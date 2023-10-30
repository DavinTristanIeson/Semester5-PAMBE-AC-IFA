import 'dart:convert';

import 'package:pambe_ac_ifa/database/interfaces/http.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:http/http.dart' as http;

class HttpRecipeManager
    with HttpResourceManagerMixin
    implements IRecipeResourceManager {
  @override
  final Uri baseUrl = globalBaseUrl.replace(path: "api");

  @override
  Future<RecipeModel> get(String id) async {
    final response =
        await makeNetworkCall(() => http.get(urlOf("recipes/$id")));
    final ApiResult<RecipeModel> res = processHttpResponse(response,
        transform: (json) =>
            RecipeModel.fromJson(json as Map<String, dynamic>));
    return res.data;
  }

  @override
  Future<PaginatedQueryResult<RecipeLiteModel>> getAll(
      {Object? page, RecipeSearchState? searchState}) async {
    final response = await makeNetworkCall(() => http.get(urlOf("recipes",
        params: searchState?.getApiParams(page: page as int?))));
    final ApiResult<List<RecipeLiteModel>> res = processHttpResponse(response,
        transform: (json) => (json as List)
                .cast<Map<String, Object?>>()
                .map<RecipeLiteModel>((map) {
              return RecipeLiteModel.fromJson(map);
            }).toList());
    return (data: res.data, nextPage: (page as int? ?? 0) + 1);
  }

  @override
  Future<RecipeModel> put(LocalRecipeModel recipe,
      {required String? userId}) async {
    final response = await makeNetworkCall(() {
      final url = urlOf("recipes");
      final Map<String, String> headers = {
        "Content-Type": "application/json",
      };
      final body = jsonEncode(recipe.toJson());
      if (recipe.remoteId == null) {
        return http.post(url, headers: headers, body: body);
      } else {
        return http.put(url, headers: headers, body: body);
      }
    });
    final ApiResult<RecipeModel> res = processHttpResponse(response,
        transform: (json) =>
            RecipeModel.fromJson(json as Map<String, dynamic>));
    return res.data;
  }

  @override
  Future<void> remove(String id) async {
    final response =
        await makeNetworkCall(() => http.delete(urlOf("recipes/$id")));
    processHttpResponse(response, transform: (json) => null);
  }
}
