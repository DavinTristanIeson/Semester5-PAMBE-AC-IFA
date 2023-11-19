// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewModel _$ReviewModelFromJson(Map<String, dynamic> json) => ReviewModel(
      content: json['content'] as String?,
      reviewedAt:
          const JsonEpochConverter().fromJson(json['reviewedAt'] as int),
      rating: json['rating'] as int,
      user: $userPropertyFromJson(json['user']),
    );

Map<String, dynamic> _$ReviewModelToJson(ReviewModel instance) =>
    <String, dynamic>{
      'content': instance.content,
      'reviewedAt': const JsonEpochConverter().toJson(instance.reviewedAt),
      'rating': instance.rating,
      'user': $userPropertyToJson(instance.user),
    };
