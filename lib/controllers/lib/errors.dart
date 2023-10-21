enum ApiErrorType {
  parseJson(
      defaultMessage:
          "Response from the server cannot be parsed into valid JSON."),
  shapeMismatch(
      defaultMessage:
          "JSON response from backend doesn't match expected model."),
  unreachable(defaultMessage: "Unable to reach server"),
  generic(
      defaultMessage:
          "An unexpected error has occurred while performing a network request."),
  serverIssues(defaultMessage: "The server is currently experiencing issues."),
  fromServer(defaultMessage: "The server has returned an error response.");

  final String defaultMessage;
  const ApiErrorType({required this.defaultMessage});
  @override
  toString() => name;
}

class ApiError implements Exception {
  final String? customMessage;
  final ApiErrorType type;
  final Exception? innerException;
  final Error? innerError;

  ApiError(this.type, {String? message, this.innerException, this.innerError})
      : customMessage = message {
    if (innerException != null) {
      // ignore: avoid_print
      print(innerException.toString());
    }
    if (innerError != null) {
      // ignore: avoid_print
      print("${innerError.toString()}\n${innerError!.stackTrace}");
    }
  }
  String get message => customMessage ?? type.defaultMessage;
  String? get errorMessage =>
      innerException?.toString() ?? innerError?.toString();
  @override
  toString() =>
      "Error [Type: $type]: $message${innerException == null ? '' : "\n$errorMessage"}";
}
