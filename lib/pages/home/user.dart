import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/pages/home/body.dart';
import 'package:pambe_ac_ifa/pages/library/main.dart';
import 'package:pambe_ac_ifa/pages/notification/main.dart';
import 'package:pambe_ac_ifa/pages/profile/main.dart';

enum RecipeLibTabs {
  home,
  library,
  notifications,
  profile;
}

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  RecipeLibTabs tab = RecipeLibTabs.home;

  Widget buildBody() {
    return switch (tab) {
      RecipeLibTabs.home => const HomePageBody(),
      RecipeLibTabs.library => const LibraryPage(),
      RecipeLibTabs.notifications => const NotificationPage(),
      RecipeLibTabs.profile => const ProfilePage()
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipe.Lib"),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tab.index,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books), label: "Library"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Notifications"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
