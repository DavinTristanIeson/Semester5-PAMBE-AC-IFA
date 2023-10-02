import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/function/future_caller.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/recipe/components/step.dart';

class RecipeStepRenderer extends StatefulWidget {
  final Stream<RecipeStep> stream;
  final Future<void> Function()? next;
  final Widget image;

  const RecipeStepRenderer(
      {super.key,
      required this.stream,
      required this.next,
      required this.image});
  @override
  State<RecipeStepRenderer> createState() => _RecipeStepRendererState();
}

class _RecipeStepRendererState extends State<RecipeStepRenderer> {
  late final StreamSubscription _subscribe;
  final ScrollController _scroll = ScrollController();
  List<RecipeStep> steps = [];
  // Cannot just use a single counter mutated by ListView.itemBuilder
  // because itemBuilder will be called when an item that was out of view comes back into view
  // Which means that Step 1 might become Step 6 when you scroll back up.
  List<int> stepNumbers = [];
  bool isDone = false;

  Future<void> scrollToBottom({Duration? duration}) {
    Duration animDuration = duration ?? const Duration(milliseconds: 200);
    return Future.delayed(animDuration, () {
      _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: animDuration, curve: Curves.decelerate);
    });
  }

  @override
  void initState() {
    super.initState();
    _subscribe = widget.stream.listen((data) async {
      setState(() {
        steps.add(data);
        int prevNumber = stepNumbers.isEmpty ? 0 : stepNumbers.last;
        stepNumbers
            .add(prevNumber + (data.type == RecipeStepVariant.regular ? 1 : 0));
      });
      scrollToBottom();
    }, onDone: () {
      setState(() {
        isDone = true;
        scrollToBottom(duration: const Duration(milliseconds: 600));
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
            child: Stack(
              children: [
                ListView.builder(
                    controller: _scroll,
                    itemCount: steps.length + (isDone ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == steps.length && isDone) {
                        return widget.image;
                      }
                      return RecipeStepComponent(
                          step: steps[index], number: stepNumbers[index]);
                    }),
                if (call != null)
                  const Positioned(
                      bottom: AcSizes.space,
                      left: 0,
                      right: 0,
                      child: Text("Click anywhere to continue",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: AcSizes.fontLarge,
                              color: AcColors.hoverColor,
                              fontWeight: FontWeight.w400))),
              ],
            ),
          );
        });
  }
}
