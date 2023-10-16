import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/controllers/notification.dart';
import 'package:pambe_ac_ifa/models/notification.dart';
import 'package:pambe_ac_ifa/pages/notification/components/notification_tile.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const NotificationScreenBody();
  }
}

class NotificationScreenBody extends StatefulWidget {
  const NotificationScreenBody({super.key});

  @override
  State<NotificationScreenBody> createState() => _NotificationScreenBodyState();
}

class _NotificationScreenBodyState extends State<NotificationScreenBody> {
  final PagingController<int, NotificationModel> _pagination =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<NotificationController>().readAll();
    });
    _pagination.addPageRequestListener((pageKey) async {
      final notifications = await fetch(pageKey);
      // if (notifications.length != 15) {
      //   _pagination.appendLastPage(recipes);
      // } else {
      _pagination.appendPage(notifications, pageKey + 1);
      // }
    });
    super.initState();
  }

  Future<List<NotificationModel>> fetch(int pageKey) async {
    return context.read<NotificationController>().getNotifications();
  }

  @override
  void dispose() {
    _pagination.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, NotificationModel>(
        pagingController: _pagination,
        builderDelegate: PagedChildBuilderDelegate(
            itemBuilder: (context, item, index) => Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: AcSizes.sm, horizontal: AcSizes.space),
                child: NotificationTile(notification: item))));
  }
}
