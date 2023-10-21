import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:pambe_ac_ifa/controllers/lib/errors.dart';
import 'package:path/path.dart';

/// CHANGE THIS TO THE URL OF THE SERVER BEFORE RUNNING
final Uri globalBaseUrl =
    Uri(scheme: 'https', host: "bewildered-jersey-lion.cyclic.app");

mixin HttpController {
  Uri get baseUrl => globalBaseUrl;
  Uri urlOf(String path, {Map<String, dynamic>? params}) {
    Uri resultUrl = baseUrl.replace(
        path: join(baseUrl.path, path), queryParameters: params);
    return resultUrl;
  }

  T processHttpResponse<T>(
    Response response, {
    required T Function(dynamic) transform,
    int expectedStatus = HttpStatus.ok,
  }) {
    if (response.statusCode >= 500) {
      throw ApiError(ApiErrorType.serverIssues);
    }

    final Map<String, Object?> rawJson;
    try {
      rawJson = jsonDecode(response.body);
    } on Exception catch (e) {
      throw ApiError(ApiErrorType.parseJson, innerException: e);
    }

    if (response.statusCode != expectedStatus) {
      if (rawJson.containsKey("message") && rawJson["message"] is String) {
        throw ApiError(ApiErrorType.fromServer,
            message: rawJson["message"] as String);
      } else {
        throw ApiError(ApiErrorType.fromServer);
      }
    }

    final T result;
    try {
      result = transform(rawJson);
    } on Error catch (e) {
      throw ApiError(ApiErrorType.shapeMismatch, innerError: e);
    } on Exception catch (e) {
      throw ApiError(ApiErrorType.shapeMismatch, innerException: e);
    }

    return result;
  }
}
