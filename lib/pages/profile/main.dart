import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/components/display/notice.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/pages/profile/screens/profile_screens.dart';
import 'package:provider/provider.dart';

class OtherUserProfileScreen extends StatelessWidget {
  final String userId;
  const OtherUserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<AuthProvider>();
    return FutureBuilder(
        future: controller.get(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return ErrorView(error: Either.right(snapshot.error.toString()));
          }
          if (!snapshot.hasData) {
            return EmptyView(
              content: Either.right("Cannot find user with ID $userId"),
            );
          }
          return ProfileScreenBody(user: snapshot.data!, editable: false);
        });
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    return ProfileScreenBody(user: user, editable: true);
  }
}
