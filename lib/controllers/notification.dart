import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/models/notification.dart';

class NotificationController extends ChangeNotifier {
  Future<List<NotificationModel>> getNotifications() async {
    return [
      NotificationModel(
          type: NotificationType.general,
          title: "Test General",
          content: "Hello world",
          createdAt: DateTime.now()),
      NotificationModel(
          type: NotificationType.system,
          title: "Test System",
          createdAt: DateTime.now()),
      NotificationModel(
          type: NotificationType.review,
          title: "Test Review",
          content: "Some bozo reviewed your recipe",
          createdAt: DateTime.now(),
          reviewTargetId: '0'),
    ];
  }

  Future<void> readAll() async {}
}
