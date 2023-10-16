import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
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

@JsonSerializable()
class NotificationModel {
  NotificationType type;
  String title;
  String? content;
  DateTime createdAt;

  String? reviewTargetId;

  NotificationModel({
    required this.type,
    required this.title,
    this.content,
    required this.createdAt,
    this.reviewTargetId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}
