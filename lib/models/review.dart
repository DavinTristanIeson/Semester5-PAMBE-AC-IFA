import 'package:json_annotation/json_annotation.dart';
import 'package:pambe_ac_ifa/common/json.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/models/user.dart';

part 'gen/review.g.dart';

@JsonSerializable(explicitToJson: true)
class ReviewModel {
  @JsonKey(includeToJson: false)
  String id;
  String? content;

  @JsonEpochConverter()
  DateTime createdAt;
  int rating;

  @JsonKey(
    toJson: $userPropertyToJson,
    fromJson: $userPropertyFromJson,
  )
  UserModel? user;
  ReviewModel(
      {required this.id,
      this.content,
      required this.createdAt,
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
