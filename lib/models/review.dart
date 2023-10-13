import 'package:json_annotation/json_annotation.dart';
import 'package:pambe_ac_ifa/common/json.dart';
import 'package:pambe_ac_ifa/models/user.dart';

@JsonSerializable()
class Review {
  String? content;

  @JsonEpochConverter()
  DateTime reviewedAt;
  double rating;

  User reviewer;
  Review(
      {this.content,
      required this.reviewedAt,
      required this.rating,
      required this.reviewer});
}
