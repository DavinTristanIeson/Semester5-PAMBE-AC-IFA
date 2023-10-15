// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeStep _$RecipeStepFromJson(Map<String, dynamic> json) => RecipeStep(
      json['content'] as String,
      type: $enumDecodeNullable(_$RecipeStepVariantEnumMap, json['type']) ??
          RecipeStepVariant.regular,
      imagePath: json['imagePath'] as String?,
      imageSource: $enumDecodeNullable(
              _$ExternalImageSourceEnumMap, json['imageSource']) ??
          ExternalImageSource.local,
      timer: _$JsonConverterFromJson<int, Duration>(
          json['timer'], const JsonDurationConverter().fromJson),
    )..id = json['id'] as String?;

Map<String, dynamic> _$RecipeStepToJson(RecipeStep instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'type': _$RecipeStepVariantEnumMap[instance.type]!,
      'imagePath': instance.imagePath,
      'timer': _$JsonConverterToJson<int, Duration>(
          instance.timer, const JsonDurationConverter().toJson),
    };

const _$RecipeStepVariantEnumMap = {
  RecipeStepVariant.regular: 'regular',
  RecipeStepVariant.tip: 'tip',
  RecipeStepVariant.warning: 'warning',
};

const _$ExternalImageSourceEnumMap = {
  ExternalImageSource.network: 'network',
  ExternalImageSource.local: 'local',
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

RecipeLiteModel _$RecipeLiteModelFromJson(Map<String, dynamic> json) =>
    RecipeLiteModel(
      id: _parseRecipeId(json['id'] as Object),
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: const JsonEpochConverter().fromJson(json['createdAt'] as int),
      imagePath: json['imagePath'] as String?,
      imageSource: $enumDecodeNullable(
              _$ExternalImageSourceEnumMap, json['imageSource']) ??
          ExternalImageSource.local,
      creator: json['creator'] == null
          ? null
          : User.fromJson(json['creator'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RecipeLiteModelToJson(RecipeLiteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'createdAt': const JsonEpochConverter().toJson(instance.createdAt),
      'imagePath': instance.imagePath,
      'imageSource': _$ExternalImageSourceEnumMap[instance.imageSource],
      'creator': instance.creator,
    };

RecipeModel _$RecipeModelFromJson(Map<String, dynamic> json) => RecipeModel(
      id: _parseRecipeId(json['id'] as Object),
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: const JsonEpochConverter().fromJson(json['createdAt'] as int),
      imagePath: json['imagePath'] as String?,
      imageSource: $enumDecodeNullable(
              _$ExternalImageSourceEnumMap, json['imageSource']) ??
          ExternalImageSource.local,
      creator: json['creator'] == null
          ? null
          : User.fromJson(json['creator'] as Map<String, dynamic>),
      steps: (json['steps'] as List<dynamic>)
          .map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RecipeModelToJson(RecipeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'createdAt': const JsonEpochConverter().toJson(instance.createdAt),
      'imagePath': instance.imagePath,
      'imageSource': _$ExternalImageSourceEnumMap[instance.imageSource],
      'creator': instance.creator,
      'steps': instance.steps,
    };
