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
}

class ApiError implements Exception {
  final String? customMessage;
  final ApiErrorType type;

  const ApiError(this.type, [this.customMessage]);
  String get message => customMessage ?? type.defaultMessage;
}
