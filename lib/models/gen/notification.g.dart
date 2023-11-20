// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      title: json['title'] as String,
      content: json['content'] as String?,
      createdAt: const JsonEpochConverter().fromJson(json['createdAt'] as int),
      reviewId: json['reviewId'] as String?,
      recipeId: json['recipeId'] as String?,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'content': instance.content,
      'createdAt': const JsonEpochConverter().toJson(instance.createdAt),
      'reviewId': instance.reviewId,
      'recipeId': instance.recipeId,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.general: 'general',
  NotificationType.system: 'system',
  NotificationType.review: 'review',
};

Map<String, dynamic> _$NotificationPayloadToJson(
        NotificationPayload instance) =>
    <String, dynamic>{
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'content': instance.content,
      'reviewId': instance.reviewId,
      'recipeId': instance.recipeId,
      'createdAt': const JsonEpochConverter().toJson(instance.createdAt),
    };
