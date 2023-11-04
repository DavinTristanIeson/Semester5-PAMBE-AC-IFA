import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:pambe_ac_ifa/models/notification.dart';

class NotificationController {
  String? userId;
  INotificationResourceManager notificationManager;

  NotificationController(
      {required this.notificationManager, required this.userId});

  Future<PaginatedQueryResult<NotificationModel>> getAll({DateTime? page}) {
    return notificationManager.getAll(page: page, userId: userId!);
  }

  Future<void> readAll() {
    return notificationManager.markAllRead(userId: userId!);
  }

  Future<bool> hasUnread() {
    return notificationManager.hasUnread(userId: userId!);
  }
}
