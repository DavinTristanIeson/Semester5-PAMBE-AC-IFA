import 'package:json_annotation/json_annotation.dart';
import 'package:pambe_ac_ifa/common/json.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/models/user.dart';

part 'gen/review.g.dart';

@JsonSerializable(explicitToJson: true)
class ReviewModel {
  String? content;

  @JsonEpochConverter()
  DateTime reviewedAt;
  int rating;

  @JsonKey(
    toJson: $userPropertyToJson,
    fromJson: $userPropertyFromJson,
  )
  UserModel? user;
  ReviewModel(
      {this.content,
      required this.reviewedAt,
      required this.rating,
      required this.user});

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    try {
      return _$ReviewModelFromJson(json);
    } catch (e) {
      throw ApiError(ApiErrorType.shapeMismatch, inner: e);
    }
  }
  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);
}
