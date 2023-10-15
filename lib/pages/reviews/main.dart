import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';

class ReviewScreen extends StatelessWidget {
  final String recipeId;
  const ReviewScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: OnlyReturnAppBar(),
    );
  }
}
