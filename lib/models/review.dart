import 'package:json_annotation/json_annotation.dart';
import 'package:pambe_ac_ifa/common/json.dart';
import 'package:pambe_ac_ifa/models/user.dart';

part 'gen/review.g.dart';

@JsonSerializable()
class ReviewModel {
  String? content;

  @JsonEpochConverter()
  DateTime reviewedAt;
  double rating;

  UserModel reviewer;
  ReviewModel(
      {this.content,
      required this.reviewedAt,
      required this.rating,
      required this.reviewer});

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);
}
