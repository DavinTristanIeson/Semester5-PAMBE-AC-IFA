import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/json.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
part 'gen/notification.g.dart';

enum NotificationType {
  @JsonValue("general")
  general(icon: Icons.notifications, color: AcColors.primary),
  @JsonValue("system")
  system(icon: Icons.settings, color: Colors.lightBlue),
  @JsonValue("review")
  review(icon: Icons.chat, color: Colors.lightGreen);

  final IconData icon;
  final Color color;
  const NotificationType({required this.icon, required this.color});
}

@JsonSerializable(explicitToJson: true)
class NotificationModel {
  @JsonKey(includeToJson: false)
  String id;
  NotificationType type;
  String title;
  String? content;
  @JsonEpochConverter()
  DateTime createdAt;

  String? reviewId;
  String? recipeId;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    this.content,
    required this.createdAt,
    this.reviewId,
    this.recipeId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    try {
      return _$NotificationModelFromJson(json);
    } catch (e) {
      throw ApiError(ApiErrorType.shapeMismatch, inner: e);
    }
  }
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}

@JsonSerializable(explicitToJson: true, createFactory: false)
class NotificationPayload {
  NotificationType type;
  String title;
  String? content;
  String? reviewId;
  String? recipeId;

  @JsonEpochConverter()
  DateTime createdAt;
  NotificationPayload.general({required this.title, this.content})
      : type = NotificationType.general,
        createdAt = DateTime.now();
  NotificationPayload.system({required this.title, this.content})
      : type = NotificationType.system,
        createdAt = DateTime.now();
  NotificationPayload.review(
      {required this.title,
      required this.reviewId,
      required this.recipeId,
      this.content})
      : type = NotificationType.review,
        createdAt = DateTime.now();

  Map<String, dynamic> toJson() => _$NotificationPayloadToJson(this);
}
