import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pambe_ac_ifa/controllers/errors.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:path/path.dart';

/// Ini untuk resep yang disimpan online
class RecipeController extends ChangeNotifier {
  /// CHANGE THIS TO THE URL OF THE SERVER BEFORE RUNNING
  static const host = "localhost:3000/api/recipes";

  Uri _url(String path, {Map<String, dynamic>? params}) {
    return Uri.http(join(host, path), '', params);
  }

  T _processHttpResponse<T>({
    required Response response,
    required T Function(dynamic) transform,
    int expectedStatus = HttpStatus.ok,
  }) {
    if (response.statusCode >= 500) {
      throw const ApiError(ApiErrorType.serverIssues);
    }

    final Map<String, Object?> rawJson;
    try {
      rawJson = jsonDecode(response.body);
    } catch (e) {
      throw const ApiError(ApiErrorType.parseJson);
    }

    if (response.statusCode != expectedStatus) {
      if (rawJson.containsKey("message") && rawJson["message"] is String) {
        throw ApiError(ApiErrorType.fromServer, rawJson["message"] as String);
      } else {
        throw const ApiError(ApiErrorType.fromServer);
      }
    }

    final T result;
    try {
      result = transform(rawJson);
    } catch (e) {
      throw const ApiError(ApiErrorType.shapeMismatch);
    }

    return result;
  }

  get retryClient => RetryClient(http.Client());

  Future<ApiResult<List<RecipeLiteModel>>> getAll(
    RecipeSearchState search, {
    int page = 0,
  }) async {
    final response = await http
        .get(_url("/recipes", params: search.getApiParams(page: page)));
    final ApiResult<List<RecipeLiteModel>> res = _processHttpResponse(
        response: response,
        transform: (json) => ApiResult.fromJson(
            json,
            (json) => (json as List<Map<String, Object?>>)
                .map<RecipeLiteModel>(RecipeLiteModel.fromJson)
                .toList()));
    return res;
  }

  Future<ApiResult<RecipeModel>> get(String id) async {
    final response = await http.get(_url("/recipes/$id"));
    final ApiResult<RecipeModel> res = _processHttpResponse(
        response: response,
        transform: (json) => ApiResult.fromJson(json,
            (json) => RecipeModel.fromJson(json as Map<String, dynamic>)));
    return res;
  }

  Future<ApiResult<RecipeModel>> create(RecipeModel recipe) async {
    final response = await http.post(_url("/recipes"),
        headers: {
          "Content-Type": "application/json",
        },
        body: recipe.toJson());
    final ApiResult<RecipeModel> res = _processHttpResponse(
        response: response,
        transform: (json) => ApiResult.fromJson(json,
            (json) => RecipeModel.fromJson(json as Map<String, dynamic>)));
    notifyListeners();
    return res;
  }

  Future<ApiResult<RecipeModel>> update(RecipeModel recipe) async {
    final response = await http.put(_url("/recipes"),
        headers: {
          "Content-Type": "application/json",
        },
        body: recipe.toJson());
    final ApiResult<RecipeModel> res = _processHttpResponse(
        response: response,
        transform: (json) => ApiResult.fromJson(json,
            (json) => RecipeModel.fromJson(json as Map<String, dynamic>)));
    notifyListeners();
    return res;
  }

  Future<ApiResult> delete(String id) async {
    final response = await http.delete(_url("/recipes/$id"));
    final ApiResult res = _processHttpResponse(
        response: response,
        transform: (json) => ApiResult.fromJson(json, (json) => json));
    return res;
  }
}
