import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
part 'gen/user.g.dart';

String _parseUserId(Object value) {
  return value.toString();
}

@JsonSerializable()
class UserModel {
  @JsonKey(fromJson: _parseUserId)
  String id;
  String name;
  String email;
  String? imagePath;
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.imagePath,
  });

  ImageProvider get image {
    if (imagePath == null) {
      return const AssetImage(MaybeImage.fallbackImagePath);
    }
    return NetworkImage(imagePath!);
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
