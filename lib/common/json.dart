import 'package:json_annotation/json_annotation.dart';

class JsonDurationConverter implements JsonConverter<Duration, int> {
  const JsonDurationConverter();

  @override
  fromJson(json) {
    return Duration(milliseconds: json);
  }

  @override
  toJson(object) {
    return object.inMilliseconds;
  }
}

class JsonEpochConverter implements JsonConverter<DateTime, int> {
  const JsonEpochConverter();

  @override
  fromJson(json) {
    return DateTime.fromMillisecondsSinceEpoch(json);
  }

  @override
  toJson(object) {
    return object.millisecondsSinceEpoch;
  }
}
