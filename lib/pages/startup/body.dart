import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StartupScreenState createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(114, 94, 84, 100),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 120,
                backgroundColor: Colors.black,
                backgroundImage: AssetImage("assets/images/logo.png"),
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
              const SizedBox(height: 10),
              const Text(
                "This is a simple Status ",
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 15),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: const Text(
                  'Register',
                  style: TextStyle(fontSize: 15),
                ),
              ),
              const SizedBox(height: AcSizes.lg),
            ],
          ),
        ),
      ),
    );
  }
}
