import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/database/interfaces/http.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:http/http.dart' as http;

/// Ini untuk resep yang disimpan online
class RecipeController extends ChangeNotifier with HttpController {
  @override
  final Uri baseUrl = globalBaseUrl.replace(path: "api");

  Future<ApiResult<List<RecipeLiteModel>>> getAll(
    RecipeSearchState search, {
    int page = 0,
  }) async {
    final response = await makeNetworkCall(() =>
        http.get(urlOf("recipes", params: search.getApiParams(page: page))));
    final ApiResult<List<RecipeLiteModel>> res = processHttpResponse(response,
        transform: (json) => ApiResult.fromJson(
            json,
            (json) => (json as List)
                    .cast<Map<String, Object?>>()
                    .map<RecipeLiteModel>((map) {
                  return RecipeLiteModel.fromJson(map);
                }).toList()));
    return res;
  }

  Future<ApiResult<RecipeModel>> get(String id) async {
    final response =
        await makeNetworkCall(() => http.get(urlOf("recipes/$id")));
    final ApiResult<RecipeModel> res = processHttpResponse(response,
        transform: (json) => ApiResult.fromJson(json,
            (json) => RecipeModel.fromJson(json as Map<String, dynamic>)));
    return res;
  }

  Future<ApiResult<RecipeModel>> put(RecipeModel recipe) async {
    final response = await makeNetworkCall(() {
      return http.post(urlOf("recipes"),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(recipe.toJson()));
    });
    final ApiResult<RecipeModel> res = processHttpResponse(response,
        transform: (json) => ApiResult.fromJson(json,
            (json) => RecipeModel.fromJson(json as Map<String, dynamic>)));
    notifyListeners();
    return res;
  }

  Future<ApiResult<RecipeModel>> update(RecipeModel recipe) async {
    final response = await makeNetworkCall(() => http.put(urlOf("recipes"),
        headers: {
          "Content-Type": "application/json",
        },
        body: recipe.toJson()));
    final ApiResult<RecipeModel> res = processHttpResponse(response,
        transform: (json) => ApiResult.fromJson(json,
            (json) => RecipeModel.fromJson(json as Map<String, dynamic>)));
    notifyListeners();
    return res;
  }

  Future<ApiResult> delete(String id) async {
    final response =
        await makeNetworkCall(() => http.delete(urlOf("recipes/$id")));
    final ApiResult res = processHttpResponse(response,
        transform: (json) => ApiResult.fromJson(json, (json) => json));
    return res;
  }
}
