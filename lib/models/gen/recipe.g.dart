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
      user: $userPropertyFromJson(json['user']),
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: const JsonEpochConverter().fromJson(json['createdAt'] as int),
      imagePath: json['imagePath'] as String?,
      imageStoragePath: json['imageStoragePath'] as String?,
      totalRating: (json['totalRating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
    );

Map<String, dynamic> _$RecipeLiteModelToJson(RecipeLiteModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'createdAt': const JsonEpochConverter().toJson(instance.createdAt),
      'imagePath': instance.imagePath,
      'user': $userPropertyToJson(instance.user),
      'totalRating': instance.totalRating,
      'reviewCount': instance.reviewCount,
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
      imageStoragePath: json['imageStoragePath'] as String?,
      user: $userPropertyFromJson(json['user']),
      steps: (json['steps'] as List<dynamic>)
          .map((e) => RecipeStepModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    )
      ..totalRating = (json['totalRating'] as num?)?.toDouble()
      ..reviewCount = json['reviewCount'] as int?;

Map<String, dynamic> _$RecipeModelToJson(RecipeModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'createdAt': const JsonEpochConverter().toJson(instance.createdAt),
      'imagePath': instance.imagePath,
      'user': $userPropertyToJson(instance.user),
      'totalRating': instance.totalRating,
      'reviewCount': instance.reviewCount,
      'steps': instance.steps.map((e) => e.toJson()).toList(),
    };

RecipeRelationshipModel _$RecipeRelationshipModelFromJson(
        Map<String, dynamic> json) =>
    RecipeRelationshipModel(
      createdAt: const JsonEpochConverter().fromJson(json['createdAt'] as int),
      userId: json['userId'] as String,
      recipeId: json['recipeId'] as String,
    );

Map<String, dynamic> _$RecipeRelationshipModelToJson(
        RecipeRelationshipModel instance) =>
    <String, dynamic>{
      'createdAt': const JsonEpochConverter().toJson(instance.createdAt),
      'userId': instance.userId,
      'recipeId': instance.recipeId,
    };
