import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:pambe_ac_ifa/controllers/lib/errors.dart';
import 'package:path/path.dart';

/// CHANGE THIS TO THE URL OF THE SERVER BEFORE RUNNING
const String globalBaseUrl = "localhost:3000";

mixin HttpController {
  String get baseUrl => globalBaseUrl;
  Uri urlOf(String path, {Map<String, dynamic>? params}) {
    return Uri.http(join(baseUrl, path), '', params);
  }

  T processHttpResponse<T>(
    Response response, {
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
}
