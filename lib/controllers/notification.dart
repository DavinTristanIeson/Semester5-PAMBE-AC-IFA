import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:pambe_ac_ifa/models/notification.dart';

class NotificationController extends ChangeNotifier {
  INotificationResourceManager notificationManager;
  NotificationController({required this.notificationManager});

  Future<PaginatedQueryResult<NotificationModel>> getAll(
      {DateTime? page, required String userId}) {
    return notificationManager.getAll(page: page, userId: userId);
  }

  Future<void> readAll({required String userId}) {
    return notificationManager.markAllRead(userId: userId);
  }

  Future<bool> hasUnread({required String userId}) {
    return notificationManager.hasUnread(userId: userId);
  }
}
