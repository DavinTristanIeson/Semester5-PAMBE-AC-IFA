// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../recipe_steps.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalRecipeStepModel _$LocalRecipeStepModelFromJson(
        Map<String, dynamic> json) =>
    LocalRecipeStepModel(
      id: json['id'] as int,
      content: json['content'] as String,
      type: $enumDecodeNullable(_$RecipeStepVariantEnumMap, json['type']) ??
          RecipeStepVariant.regular,
      timer: _$JsonConverterFromJson<int, Duration>(
          json['timer'], const JsonDurationConverter().fromJson),
      imagePath: json['imagePath'] as String?,
    );

Map<String, dynamic> _$LocalRecipeStepModelToJson(
        LocalRecipeStepModel instance) =>
    <String, dynamic>{
      'content': instance.content,
      'type': _$RecipeStepVariantEnumMap[instance.type]!,
      'timer': _$JsonConverterToJson<int, Duration>(
          instance.timer, const JsonDurationConverter().toJson),
      'imagePath': instance.imagePath,
      'id': instance.id,
    };

const _$RecipeStepVariantEnumMap = {
  RecipeStepVariant.regular: 'regular',
  RecipeStepVariant.tip: 'tip',
  RecipeStepVariant.warning: 'warning',
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

RecipeStepModel _$RecipeStepModelFromJson(Map<String, dynamic> json) =>
    RecipeStepModel(
      id: json['id'] as String,
      content: json['content'] as String,
      type: $enumDecodeNullable(_$RecipeStepVariantEnumMap, json['type']) ??
          RecipeStepVariant.regular,
      timer: _$JsonConverterFromJson<int, Duration>(
          json['timer'], const JsonDurationConverter().fromJson),
      imagePath: json['imagePath'] as String?,
    );

Map<String, dynamic> _$RecipeStepModelToJson(RecipeStepModel instance) =>
    <String, dynamic>{
      'content': instance.content,
      'type': _$RecipeStepVariantEnumMap[instance.type]!,
      'timer': _$JsonConverterToJson<int, Duration>(
          instance.timer, const JsonDurationConverter().toJson),
      'imagePath': instance.imagePath,
      'id': instance.id,
    };
