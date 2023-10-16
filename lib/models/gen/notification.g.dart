// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      title: json['title'] as String,
      content: json['content'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      reviewTargetId: json['reviewTargetId'] as String?,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'reviewTargetId': instance.reviewTargetId,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.general: 'general',
  NotificationType.system: 'system',
  NotificationType.review: 'review',
};
