import 'package:pambe_ac_ifa/database/interfaces/common.dart';
import 'package:pambe_ac_ifa/models/notification.dart';

enum NotificationFilterByType {
  type,
}

class NotificationFilterBy {
  NotificationFilterByType type;
  NotificationType notificationType;
  NotificationFilterBy.type(this.notificationType)
      : type = NotificationFilterByType.type;
}

abstract class INotificationResourceManager {
  Future<PaginatedQueryResult<NotificationModel>> getAll(
      {dynamic page,
      required String userId,
      NotificationFilterBy? filter,
      int? limit});
  Future<void> markAllRead({required String userId});
  Future<bool> hasUnread({required String userId});
  Future<void> clear({required String userId});
  Future<void> notify(
      {required String targetUserId,
      required NotificationPayload notification});
}
