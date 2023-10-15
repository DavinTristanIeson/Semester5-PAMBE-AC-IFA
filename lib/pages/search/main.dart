import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: OnlyReturnAppBar(),
    );
  }
}
