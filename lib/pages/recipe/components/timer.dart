import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/function/timer.dart';

class TimerText extends StatelessWidget {
  final int seconds;
  const TimerText({super.key, required this.seconds});

  @override
  Widget build(BuildContext context) {
    String hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    String minutes = ((seconds ~/ 60) % 60).toString().padLeft(2, '0');
    String secs = (seconds % 60).toString().padLeft(2, '0');
    return Text("$hours:$minutes:$secs",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: AcSizes.fontExtraLarge,
        ));
  }
}

class RecipeStepTimer extends StatelessWidget {
  final Duration duration;
  const RecipeStepTimer({super.key, required this.duration});

  Widget buildPlayingButton(TimerController controller) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        controller.isPaused
            ? IconButton(
                iconSize: AcSizes.iconBig,
                onPressed: controller.resume,
                icon: const Icon(Icons.play_arrow))
            : IconButton(
                iconSize: AcSizes.iconBig,
                onPressed: controller.pause,
                icon: const Icon(Icons.pause)),
        const SizedBox(width: AcSizes.space),
        IconButton(
            onPressed: controller.stop,
            iconSize: AcSizes.iconBig,
            icon: const Icon(Icons.stop)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return TimerBuilder(
        onEnded: (isManual) {
          if (!isManual) {
            SystemSound.play(SystemSoundType.alert);
          }
        },
        timer: duration,
        builder: (context, controller) {
          // SizedBox with maxFinite width is necessary to make the WrapAlignment.spaceBetween behave properly
          return SizedBox(
            width: double.maxFinite,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                TimerText(seconds: controller.current),
                if (!controller.hasStarted)
                  ElevatedButton.icon(
                      onPressed: controller.resume,
                      icon: const Icon(Icons.play_arrow, size: AcSizes.iconBig),
                      label: const Text(
                        "Start",
                      )),
                if (controller.hasEnded)
                  IconButton(
                      iconSize: AcSizes.iconBig,
                      onPressed: controller.reset,
                      icon: const Icon(Icons.refresh)),
                if (controller.isOngoing) buildPlayingButton(controller),
              ],
            ),
          );
        });
  }
}
