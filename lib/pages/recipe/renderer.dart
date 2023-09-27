import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/components/function/future_caller.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';

class RecipeStepRenderer extends StatefulWidget {
  final Stream<dynamic> stream;
  final Future<void> Function()? next;

  const RecipeStepRenderer(
      {super.key, required this.stream, required this.next});
  @override
  State<RecipeStepRenderer> createState() => _RecipeStepRendererState();
}

class _RecipeStepRendererState extends State<RecipeStepRenderer> {
  late final StreamSubscription _subscribe;
  List<RecipeStep> steps = [];
  @override
  void initState() {
    super.initState();
    _subscribe = widget.stream.listen((data) {
      setState(() {
        steps.add(data);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscribe.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
              itemCount: steps.length,
              itemBuilder: (context, index) {
                return Text(steps[index].toString());
              }),
        ),
        FutureProcedureCaller<void>(
            process: widget.next,
            builder: (context, snapshot, call) =>
                ElevatedButton(onPressed: call, child: const Text("Next")))
      ],
    );
  }
}
