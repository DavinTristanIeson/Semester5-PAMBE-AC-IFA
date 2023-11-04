import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';

class _DigitCard extends StatelessWidget {
  final int? value;
  const _DigitCard({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 30.0,
        height: 60.0,
        decoration: const BoxDecoration(
            color: AcColors.white,
            borderRadius: BorderRadius.all(Radius.circular(AcSizes.sm))),
        child: Center(
            child: Text(value.toString(), style: AcTypography.displayMedium)));
  }
}

class DigitField extends StatefulWidget {
  final int max;
  final int value;
  final void Function(int value) onChanged;
  const DigitField(
      {super.key,
      required this.value,
      required this.onChanged,
      required this.max});

  int get digitCount {
    return (log(max) / ln10).ceil();
  }

  @override
  State<DigitField> createState() => _DigitFieldState();
}

class _DigitFieldState extends State<DigitField> {
  double? tempValue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(min(widget.max, max(0, widget.value + 1)));
      },
      onVerticalDragStart: (details) {
        setState(() {
          tempValue = widget.value.toDouble();
        });
      },
      onVerticalDragEnd: (details) {
        int copyValue = tempValue?.round() ?? widget.value;
        setState(() {
          tempValue = null;
        });
        widget.onChanged(copyValue);
      },
      onVerticalDragUpdate: (details) {
        setState(() {
          tempValue = clampDouble(tempValue! + details.localPosition.dy / 400.0,
              0.0, widget.max.toDouble());
        });
      },
      onVerticalDragCancel: () {
        setState(() {
          tempValue = null;
        });
      },
      child: Wrap(
        spacing: AcSizes.sm,
        children: [
          for (int i = widget.digitCount - 1; i >= 0; i--)
            _DigitCard(
                value:
                    ((tempValue?.round() ?? widget.value) ~/ pow(10, i)) % 10),
        ],
      ),
    );
  }
}

class TimerField extends StatelessWidget {
  late final Duration value;
  final void Function(Duration) onChanged;
  TimerField({super.key, Duration? value, required this.onChanged}) {
    this.value = value ?? const Duration();
  }

  @override
  Widget build(BuildContext context) {
    const Padding separator = Padding(
      padding: EdgeInsets.symmetric(horizontal: AcSizes.md),
      child: Text(":", style: AcTypography.displayMedium),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DigitField(
            value: value.inHours % 60,
            onChanged: (hours) {
              onChanged(Duration(
                  hours: hours,
                  minutes: value.inMinutes % 60,
                  seconds: value.inSeconds % 60));
            },
            max: 59),
        separator,
        DigitField(
            value: value.inMinutes % 60,
            onChanged: (minutes) {
              onChanged(Duration(
                  hours: value.inHours % 60,
                  minutes: minutes,
                  seconds: value.inSeconds % 60));
            },
            max: 59),
        separator,
        DigitField(
            value: value.inSeconds % 60,
            onChanged: (seconds) {
              onChanged(Duration(
                  hours: value.inHours % 60,
                  minutes: value.inMinutes % 60,
                  seconds: seconds));
            },
            max: 59),
      ],
    );
  }
}
