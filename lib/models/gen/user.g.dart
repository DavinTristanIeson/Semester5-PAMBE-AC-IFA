// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      imagePath: json['imagePath'] as String?,
      country: json['location'] as String?,
      birthdate: _$JsonConverterFromJson<int, DateTime>(
          json['birthdate'], const JsonEpochConverter().fromJson),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'imagePath': instance.imagePath,
      'birthdate': _$JsonConverterToJson<int, DateTime>(
          instance.birthdate, const JsonEpochConverter().toJson),
      'location': instance.country,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
