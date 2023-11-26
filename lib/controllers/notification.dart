import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/database/interfaces/common.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/notification.dart';
import 'package:pambe_ac_ifa/models/notification.dart';

class NotificationController implements AuthDependent {
  String? userId;
  INotificationResourceManager notificationManager;

  NotificationController(
      {required this.notificationManager, required this.userId});

  Future<PaginatedQueryResult<NotificationModel>> getAllWithPagination(
      {DateTime? page, NotificationFilterBy? filterBy, int? limit = 15}) {
    if (userId == null) {
      throw InvalidStateError(
          "NotificationController.userId should not be null when getAll is invoked!");
    }
    return notificationManager.getAll(
        page: page, userId: userId!, filter: filterBy, limit: limit);
  }

  Future<List<NotificationModel>> getAll(
      {DateTime? page, NotificationFilterBy? filterBy, int? limit}) async {
    return (await getAllWithPagination(
            page: page, filterBy: filterBy, limit: limit))
        .data;
  }

  Future<void> readAll() {
    if (userId == null) {
      throw InvalidStateError(
          "NotificationController.userId should not be null when readAll is invoked!");
    }
    return notificationManager.markAllRead(userId: userId!);
  }

  Future<bool> hasUnread() {
    if (userId == null) {
      throw InvalidStateError(
          "NotificationController.userId should not be null when hasUnread is invoked!");
    }
    return notificationManager.hasUnread(userId: userId!);
  }

  Future<void> clear() {
    if (userId == null) {
      throw InvalidStateError(
          "NotificationController.userId should not be null when clear is invoked!");
    }
    return notificationManager.clear(userId: userId!);
  }

  Future<void> notify(
      {required String targetUserId,
      required NotificationPayload notification}) {
    if (userId == null) {
      throw InvalidStateError(
          "NotificationController.userId should not be null when put is invoked!");
    }
    return notificationManager.notify(
        targetUserId: targetUserId, notification: notification);
  }
}
