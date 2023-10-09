import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';

class RecipeLibLogoTitle extends StatelessWidget {
  const RecipeLibLogoTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CircleAvatar(
        radius: clampDouble(MediaQuery.of(context).size.width / 4, 80.0, 150.0),
        backgroundColor: Colors.black,
        backgroundImage: const AssetImage("assets/images/logo.png"),
      ),
      const SizedBox(height: 10),
      Text(
        "Recipe.Lib",
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 40,
            color: Theme.of(context).colorScheme.primary),
      ),
      const SizedBox(height: 10),
    ]);
  }
}

class StartupMessageBoard extends StatelessWidget {
  final String text;
  const StartupMessageBoard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AcSizes.space),
      child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(AcSizes.br),
            color: Color.fromRGBO(0, 0, 0, 0.1),
          ),
          padding: const EdgeInsets.all(AcSizes.space),
          child: Text(
            text,
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500),
          )),
    );
  }
}
