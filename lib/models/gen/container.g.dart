// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../container.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MinimalModel _$MinimalModelFromJson(Map<String, dynamic> json) => MinimalModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$MinimalModelToJson(MinimalModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

ApiResult<T> _$ApiResultFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    ApiResult<T>(
      message: json['message'] as String,
      data: fromJsonT(json['data']),
    );

Map<String, dynamic> _$ApiResultToJson<T>(
  ApiResult<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'message': instance.message,
      'data': toJsonT(instance.data),
    };
