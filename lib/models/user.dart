import 'package:json_annotation/json_annotation.dart';
import 'package:pambe_ac_ifa/common/json.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
part 'gen/user.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel with SupportsLocalAndOnlineImagesMixin {
  String id;
  String name;
  String email;
  String? bio;

  @override
  String? imagePath;

  @JsonEpochConverter()
  DateTime? birthdate;

  String? country;

  @override
  @JsonKey(includeToJson: false)
  ExternalImageSource? get imageSource => ExternalImageSource.network;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.imagePath,
    this.bio,
    this.country,
    this.birthdate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return _$UserModelFromJson(json);
    } catch (e) {
      throw ApiError(ApiErrorType.shapeMismatch, inner: e);
    }
  }
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
