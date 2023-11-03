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
      reviewTargetId: json['reviewTargetId'] as String?,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'content': instance.content,
      'createdAt': const JsonEpochConverter().toJson(instance.createdAt),
      'reviewTargetId': instance.reviewTargetId,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.general: 'general',
  NotificationType.system: 'system',
  NotificationType.review: 'review',
};
