// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewModel _$ReviewModelFromJson(Map<String, dynamic> json) => ReviewModel(
      id: json['id'] as String,
      content: json['content'] as String?,
      createdAt: const JsonEpochConverter().fromJson(json['createdAt'] as int),
      rating: json['rating'] as int,
      user: $userPropertyFromJson(json['user']),
    );

Map<String, dynamic> _$ReviewModelToJson(ReviewModel instance) =>
    <String, dynamic>{
      'content': instance.content,
      'createdAt': const JsonEpochConverter().toJson(instance.createdAt),
      'rating': instance.rating,
      'user': $userPropertyToJson(instance.user),
    };
