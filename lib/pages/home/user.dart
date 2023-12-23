import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/app/confirmation.dart';
import 'package:pambe_ac_ifa/components/app/snackbar.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/controllers/notification.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/pages/home/body.dart';
import 'package:pambe_ac_ifa/pages/library/main.dart';
import 'package:pambe_ac_ifa/pages/notification/main.dart';
import 'package:pambe_ac_ifa/pages/profile/main.dart';
import 'package:pambe_ac_ifa/pages/search/main.dart';
import 'package:pambe_ac_ifa/pages/settings/main.dart';
import 'package:provider/provider.dart';

enum RecipeLibTabs {
  home,
  library,
  notifications,
  profile;
}

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  RecipeLibTabs tab = RecipeLibTabs.home;

  Widget buildBody() {
    return switch (tab) {
      RecipeLibTabs.home => const HomePageBody(),
      RecipeLibTabs.library => const LibraryScreen(),
      RecipeLibTabs.notifications => const NotificationScreen(),
      RecipeLibTabs.profile => const ProfileScreen()
    };
  }

  @override
  Widget build(BuildContext context) {
    final notificationController = context.watch<NotificationController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipe.Lib"),
        actions: [
          if (tab == RecipeLibTabs.home)
            IconButton(
                onPressed: () {
                  context.navigator.push(MaterialPageRoute(
                      builder: (context) => const SearchScreen()));
                },
                icon: const Icon(Icons.search)),
          if (tab == RecipeLibTabs.notifications)
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return SimpleConfirmationDialog.delete(
                            onConfirm: () async {
                              final messenger = AcSnackbarMessenger.of(context);
                              try {
                                await context
                                    .read<NotificationController>()
                                    .clear();
                                messenger.sendSuccess(
                                    "screen/home/user/notification_delete"
                                        .i18n());
                              } catch (e) {
                                messenger.sendError(e);
                              }
                            },
                            title: Either.right(
                                "screen/home/user/clear_notifications".i18n()),
                            message: Either.right(
                                "screen/home/user/clear_notifications_desc"
                                    .i18n()),
                            context: context);
                      });
                },
                color: context.colors.error,
                icon: const Icon(Icons.delete_forever)),
          if (tab == RecipeLibTabs.profile) ...[
            IconButton(
                onPressed: () async {
                  context.read<AuthProvider>().logout();
                },
                icon: const Icon(Icons.logout)),
            IconButton(
              onPressed: () {
                context.navigator.push(MaterialPageRoute(
                    builder: (context) => const SettingsScreen()));
              },
              icon: const Icon(Icons.settings),
            )
          ],
        ],
      ),
      body: buildBody(),
      bottomNavigationBar: Theme(
        data: context.theme.copyWith(
          canvasColor: context.colors.secondary,
        ),
        child: BottomNavigationBar(
          currentIndex: tab.index,
          onTap: (value) {
            setState(() {
              tab = RecipeLibTabs.values[value];
            });
          },
          items: [
            const BottomNavigationBarItem(
                icon: Icon(Icons.home), label: "Home"),
            const BottomNavigationBarItem(
                icon: Icon(Icons.library_books), label: "Library"),
            BottomNavigationBarItem(
                icon: FutureBuilder(
                    future: notificationController.hasUnread(),
                    builder: (context, snapshot) {
                      final hasUnread = snapshot.data ?? false;
                      const icon = Icon(Icons.notifications);
                      return hasUnread
                          ? Badge(
                              backgroundColor: context.colors.error,
                              child: icon)
                          : icon;
                    }),
                label: "Notifications"),
            const BottomNavigationBarItem(
                icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
