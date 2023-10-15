import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
part 'gen/user.g.dart';

@JsonSerializable()
class UserModel {
  String id;
  String name;
  String email;
  String imagePath;
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.imagePath,
  });

  ImageProvider get image {
    return NetworkImage(imagePath);
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
