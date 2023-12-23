import 'package:flutter/foundation.dart';
import 'package:localization/localization.dart';

enum ApiErrorType {
  // Http-based server errors
  uncategorizedServerError(
      name: "Uncategorized", message: "errors/uncategorized"),
  invalidJson(name: "Invalid JSON", message: "errors/invalid_json"),
  shapeMismatch(name: "Shape Mismatch", message: "errors/shape_mismatch"),
  serverUnreachable(
      name: "Server Unreachable", message: "errors/server_unreachable"),
  serverIssues(name: "Server Issues", message: "errors/server_issues"),
  fromServer(name: "Server-Sent Error", message: "errors/server_sent_error"),

  // Auth errors
  authenticationError(
      name: "Authentication Error", message: "errors/authentication_error"),

  // Resource errors
  storeFailure(name: "Store Failure", message: "errors/store_failure"),
  imageManagementFailure(
      name: "Image Management Failure",
      message: "errors/image_management_failure"),
  deleteFailure(name: "Delete Failure", message: "errors/delete_failure"),
  resourceNotFound(
      name: "Resource Not Found", message: "errors/resource_not_found"),
  cleanupFailure(name: "Cleanup Failure", message: "errors/cleanup_failure"),
  fetchFailure(name: "Fetch Failure", message: "errors/fetch_failure");

  final String defaultMessage;
  final String officialName;
  const ApiErrorType({required String message, required String name})
      : defaultMessage = message,
        officialName = name;
  @override
  toString() => name;
}

class _ErrorWrappingError implements Exception {
  Exception? _innerException;
  Error? _innerError;
  _ErrorWrappingError({Object? inner}) {
    if (inner is ApiError) {
      _innerError = inner._innerError;
      _innerException = inner._innerException;
    } else {
      if (inner is Error) {
        _innerError = inner;
        debugPrint(
            "API ERROR: ${_innerError.toString()}\n${_innerError!.stackTrace}");
      } else if (inner is Exception) {
        _innerException = inner;
        debugPrint("API ERROR: ${_innerException.toString()}");
      }
    }
  }
  String? get errorMessage =>
      _innerException?.toString() ?? _innerError?.toString();
}

class ApiError extends _ErrorWrappingError {
  final String? customMessage;
  final ApiErrorType type;

  ApiError(this.type, {String? message, super.inner}) : customMessage = message;
  String get message => customMessage ?? type.defaultMessage.i18n();
  @override
  toString() =>
      "${'common/error'.i18n()} [${'common/type'.i18n()}: $type]: $message${_innerException == null ? '' : "\n$errorMessage"}";
}

class InvalidStateError implements Exception {
  final String? message;
  InvalidStateError(this.message);
  @override
  toString() => "${'common/error'.i18n()}: $message";
}
