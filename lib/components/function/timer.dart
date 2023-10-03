import 'dart:async';

import 'package:flutter/material.dart';

class TimerRemote {
  final int original;
  int current;
  bool isPaused;
  bool hasStarted;
  void Function() pause;
  void Function() resume;
  void Function() reset;
  void Function() stop;
  TimerRemote({
    required this.original,
    required this.current,
    required this.isPaused,
    required this.pause,
    required this.resume,
    required this.reset,
    required this.stop,
    required this.hasStarted,
  });

  get hasEnded {
    return current == 0;
  }

  get isOngoing {
    return hasStarted && !hasEnded;
  }
}

/// A builder that runs a StreamSubscription and the number of seconds remaining on the timer.
///
/// The provided StreamSubscription in the builder should only be used for pausing and resuming the stream.
/// This widget is responsible for disposing of the subscription.
class TimerBuilder extends StatefulWidget {
  final Duration timer;
  final Widget Function(BuildContext context, TimerRemote controller) builder;

  /// isManual indicates whether the callback is called because the timer is manually stopped or not
  final void Function(bool isManual)? onEnded;
  const TimerBuilder(
      {super.key, required this.builder, required this.timer, this.onEnded});

  @override
  State<TimerBuilder> createState() => _TimerBuilderState();
}

class _TimerBuilderState extends State<TimerBuilder>
    with AutomaticKeepAliveClientMixin {
  late Stream _stream;
  late StreamSubscription _subscribe;
  int? seconds;
  // Needs to be a separate state rather than computed from seconds == widget.timer.inSeconds
  // because seconds is only updated every second, which means that there's some lag between pressing the start button
  // and it entering the ongoing state
  bool hasStarted = false;
  @override
  void initState() {
    super.initState();
    _initializeStream();
    _subscribe.pause();
  }

  @override
  void dispose() {
    super.dispose();
    _subscribe.cancel();
  }

  void _initializeStream() {
    seconds = widget.timer.inSeconds;
    _stream =
        Stream.periodic(const Duration(seconds: 1), (i) => i).take(seconds!);
    _subscribe = _stream.listen((event) {
      setState(() {
        seconds = seconds! - 1;
        if (seconds == 0 && widget.onEnded != null) {
          widget.onEnded!(false);
        }
      });
    });
  }

  void reset() {
    setState(_initializeStream);
  }

  void stop() {
    setState(() {
      _subscribe.cancel();
      seconds = 0;
      if (widget.onEnded != null) widget.onEnded!(true);
    });
  }

  void pause() {
    setState(_subscribe.pause);
  }

  void resume() {
    setState(() {
      _subscribe.resume();
      if (!hasStarted) {
        hasStarted = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.builder(
        context,
        TimerRemote(
            original: widget.timer.inSeconds,
            current: seconds!,
            isPaused: _subscribe.isPaused,
            hasStarted: hasStarted,
            pause: pause,
            resume: resume,
            reset: reset,
            stop: stop));
  }

  /// We want to keep the timer alive even in ListView.builder
  /// Reference: https://stackoverflow.com/questions/55699781/how-to-maintain-the-state-of-widget-in-listview
  @override
  bool get wantKeepAlive {
    return seconds != null && seconds! > 0;
  }
}
