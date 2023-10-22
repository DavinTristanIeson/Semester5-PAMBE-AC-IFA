enum ApiErrorType {
  // Http-based server errors
  uncategorizedServerError(
      name: "Uncategorized",
      message:
          "An unexpected error has occurred while performing a network request."),
  invalidJson(
      name: "Invalid JSON",
      message: "Response from the server cannot be parsed into valid JSON."),
  shapeMismatch(
      name: "Shape Mismatch",
      message: "JSON response from backend doesn't match expected model."),
  serverUnreachable(
      name: "Server Unreachable", message: "Unable to reach server"),
  serverIssues(
      name: "Server Issues",
      message: "The server is currently experiencing issues."),
  fromServer(
      name: "Server-Sent Error",
      message: "The server has returned an error response."),

  // Resource errors
  storeFailure(
      name: "Store Failure",
      message: "An error occurred while storing the resource"),
  fetchFailure(
      name: "Fetch Failure",
      message: "An error occurred while getting the resource");

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
    if (inner is Error) {
      _innerError = inner;
      // ignore: avoid_print
      print("${_innerError.toString()}\n${_innerError!.stackTrace}");
    } else if (inner is Exception) {
      _innerException = inner;
      // ignore: avoid_print
      print(_innerException.toString());
    }
  }
  String? get errorMessage =>
      _innerException?.toString() ?? _innerError?.toString();
}

class ApiError extends _ErrorWrappingError {
  final String? customMessage;
  final ApiErrorType type;

  ApiError(this.type, {String? message, super.inner}) : customMessage = message;
  String get message => customMessage ?? type.defaultMessage;
  @override
  toString() =>
      "Error [Type: $type]: $message${_innerException == null ? '' : "\n$errorMessage"}";
}
