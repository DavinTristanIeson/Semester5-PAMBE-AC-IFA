import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/display/notice.dart';
import 'package:pambe_ac_ifa/components/display/pagination.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/controllers/notification.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/notification.dart';
import 'package:pambe_ac_ifa/pages/notification/components/notification_tile.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<NotificationController>();
    final user = context.watch<AuthProvider>().user!;
    return FutureBuilder(future: Future.sync(() async {
      await controller.readAll(userId: user.id);
    }), builder: (context, snapshot) {
      if (snapshot.hasError) {
        return ErrorView(error: Either.right(snapshot.error!.toString()));
      }
      return const NotificationScreenBody();
    });
  }
}

class NotificationScreenBody extends StatefulWidget {
  const NotificationScreenBody({super.key});

  @override
  State<NotificationScreenBody> createState() => _NotificationScreenBodyState();
}

class _NotificationScreenBodyState extends State<NotificationScreenBody> {
  late final String userId;
  final PagingController<DateTime?, NotificationModel> _pagination =
      PagingController(firstPageKey: null);

  @override
  void initState() {
    userId = context.read<AuthProvider>().user!.id;
    _pagination.addPageRequestListener((pageKey) async {
      final (:data, :nextPage) = await fetch(pageKey);
      if (nextPage == null) {
        _pagination.appendLastPage(data);
      } else {
        _pagination.appendPage(data, nextPage);
      }
    });
    super.initState();
  }

  Future<PaginatedQueryResult<NotificationModel>> fetch(
      DateTime? pageKey) async {
    return context
        .read<NotificationController>()
        .getAll(page: pageKey, userId: userId);
  }

  @override
  void dispose() {
    _pagination.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AcPagedListView(
        controller: _pagination,
        itemBuilder: (context, item, index) {
          return Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: AcSizes.sm, horizontal: AcSizes.space),
              child: NotificationTile(notification: item));
        });
  }
}
