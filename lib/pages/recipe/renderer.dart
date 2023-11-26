import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'package:pambe_ac_ifa/components/function/future.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/editor/components/step.dart';
import 'package:pambe_ac_ifa/pages/recipe/components/step.dart';

class RecipeStepRenderer extends StatefulWidget {
  final Stream<AbstractRecipeStepModel> stream;
  final Future<void> Function()? next;
  final ImageProvider? image;

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
  List<AbstractRecipeStepModel> steps = [];
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
    final stepNumbers = <int>[];
    for (final step in steps) {
      stepNumbers.add((stepNumbers.lastOrNull ?? 0) +
          (step.type == RecipeStepVariant.regular ? 1 : 0));
    }
    return FutureButtonCompute(
        onPressed: widget.next,
        builder: (context, remote) {
          return GestureDetector(
            onTap: remote.call,
            child: Stack(
              children: [
                ListView.builder(
                    controller: _scroll,
                    itemCount: steps.length + (isDone ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == steps.length && isDone) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              left: AcSizes.lg + StepNumber.defaultDiameter / 4,
                              right: AcSizes.lg,
                              bottom: AcSizes.lg),
                          child: AcImageContainer(
                              borderRadius: const BorderRadius.all(AcSizes.br),
                              child: MaybeImage(image: widget.image)),
                        );
                      }
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: index == steps.length - 1 ? AcSizes.lg : 0),
                        child: RecipeStepComponent(
                            step: steps[index], number: stepNumbers[index]),
                      );
                    }),
                if (remote.call != null)
                  const Positioned(
                      bottom: AcSizes.space,
                      left: 0,
                      right: 0,
                      child: Text("Click anywhere to continue",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: AcSizes.fontEmphasis,
                              color: AcColors.hoverColor,
                              fontWeight: FontWeight.w400))),
              ],
            ),
          );
        });
  }
}
