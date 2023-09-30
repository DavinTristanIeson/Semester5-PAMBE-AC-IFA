import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/function/future_caller.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/editor/components/step.dart';

class RecipeStepRenderer extends StatefulWidget {
  final Stream<RecipeStep> stream;
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
    return FutureProcedureCaller<void>(
        process: widget.next,
        builder: (context, snapshot, call) {
          return GestureDetector(
            onTap: call,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      itemCount: steps.length,
                      itemBuilder: (context, index) {
                        RecipeStep step = steps[index];
                        return RecipeStepWrapper(
                            index: index + 1,
                            variant: step.type,
                            padding: const EdgeInsets.only(
                              left: AcSizes.xl + AcSizes.sm,
                              top: AcSizes.lg + AcSizes.sm,
                              right: AcSizes.lg,
                              bottom: AcSizes.lg,
                            ),
                            child: Row(
                              children: [
                                Text(step.content),
                              ],
                            ));
                      }),
                ),
              ],
            ),
          );
        });
  }
}
