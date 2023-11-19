import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/models/notification.dart';
import 'package:pambe_ac_ifa/pages/reviews/main.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  const NotificationTile({super.key, required this.notification});

  void Function()? getOnTapBehavior(BuildContext context) {
    return switch (notification.type) {
      NotificationType.general => null,
      NotificationType.system => null,
      NotificationType.review => () {
          context.navigator.push(MaterialPageRoute(
              builder: (context) =>
                  ReviewsScreen(recipeId: notification.reviewTargetId!)));
        },
    };
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(AcSizes.brInput),
      child: Material(
        color: context.colors.surface,
        child: ListTile(
          splashColor: context.colors.primary.withOpacity(0.3),
          onTap: getOnTapBehavior(context),
          leading: CircleAvatar(
            backgroundColor: notification.type.color,
            child: Icon(notification.type.icon),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.title, style: context.texts.titleSmall),
              Text(notification.createdAt.toLocaleString(),
                  style: context.texts.bodySmall),
            ],
          ),
          subtitle:
              notification.content == null ? null : Text(notification.content!),
        ),
      ),
    );
  }
}
