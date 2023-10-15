// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewModel _$ReviewModelFromJson(Map<String, dynamic> json) => ReviewModel(
      content: json['content'] as String?,
      reviewedAt:
          const JsonEpochConverter().fromJson(json['reviewedAt'] as int),
      rating: (json['rating'] as num).toDouble(),
      reviewer: UserModel.fromJson(json['reviewer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReviewModelToJson(ReviewModel instance) =>
    <String, dynamic>{
      'content': instance.content,
      'reviewedAt': const JsonEpochConverter().toJson(instance.reviewedAt),
      'rating': instance.rating,
      'reviewer': instance.reviewer,
    };
