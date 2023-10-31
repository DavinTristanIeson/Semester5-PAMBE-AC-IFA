// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalRecipeLiteModel _$LocalRecipeLiteModelFromJson(
        Map<String, dynamic> json) =>
    LocalRecipeLiteModel(
      id: json['id'] as int,
      remoteId: json['remoteId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: const JsonEpochConverter().fromJson(json['createdAt'] as int),
      imagePath: json['imagePath'] as String?,
    );

Map<String, dynamic> _$LocalRecipeLiteModelToJson(
        LocalRecipeLiteModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'createdAt': const JsonEpochConverter().toJson(instance.createdAt),
      'imagePath': instance.imagePath,
      'id': instance.id,
    };

RecipeLiteModel _$RecipeLiteModelFromJson(Map<String, dynamic> json) =>
    RecipeLiteModel(
      id: json['id'] as String,
      user: _$userPropertyFromJson(json['user']),
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: const JsonEpochConverter().fromJson(json['createdAt'] as int),
      imagePath: json['imagePath'] as String?,
    );

Map<String, dynamic> _$RecipeLiteModelToJson(RecipeLiteModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'createdAt': const JsonEpochConverter().toJson(instance.createdAt),
      'imagePath': instance.imagePath,
      'user': _$userPropertyToJson(instance.user),
    };

LocalRecipeModel _$LocalRecipeModelFromJson(Map<String, dynamic> json) =>
    LocalRecipeModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: const JsonEpochConverter().fromJson(json['createdAt'] as int),
      imagePath: json['imagePath'] as String?,
      remoteId: json['remoteId'] as String?,
      steps: (json['steps'] as List<dynamic>)
          .map((e) => LocalRecipeStepModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LocalRecipeModelToJson(LocalRecipeModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'createdAt': const JsonEpochConverter().toJson(instance.createdAt),
      'imagePath': instance.imagePath,
      'id': instance.id,
      'steps': instance.steps.map((e) => e.toJson()).toList(),
    };

RecipeModel _$RecipeModelFromJson(Map<String, dynamic> json) => RecipeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: const JsonEpochConverter().fromJson(json['createdAt'] as int),
      imagePath: json['imagePath'] as String?,
      user: _$userPropertyFromJson(json['user']),
      steps: (json['steps'] as List<dynamic>)
          .map((e) => RecipeStepModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RecipeModelToJson(RecipeModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'createdAt': const JsonEpochConverter().toJson(instance.createdAt),
      'imagePath': instance.imagePath,
      'user': _$userPropertyToJson(instance.user),
      'steps': instance.steps.map((e) => e.toJson()).toList(),
    };
