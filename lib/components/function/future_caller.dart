import 'dart:async';

import 'package:flutter/material.dart';

/// Builder that supports calling a future function more than once.
///
/// Use call() with the input to trigger the function again.
///
/// call() will be null when the future is loading.
class FutureFunctionCaller<TOutput, TInput> extends StatefulWidget {
  final Future<TOutput> Function(TInput)? process;
  final Widget Function(BuildContext context, AsyncSnapshot snapshot,
      void Function(TInput)? call) builder;
  const FutureFunctionCaller(
      {super.key, required this.process, required this.builder});

  @override
  State<FutureFunctionCaller<TOutput, TInput>> createState() =>
      _FutureFunctionCallerState<TOutput, TInput>();
}

class _FutureFunctionCallerState<TOutput, TInput>
    extends State<FutureFunctionCaller<TOutput, TInput>> {
  Future<TOutput>? future;

  void call(TInput input) {
    setState(() {
      future = widget.process!(input);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TOutput>(
        future: future,
        builder: (context, snapshot) => widget.builder(
            context,
            snapshot,
            snapshot.connectionState == ConnectionState.waiting ||
                    widget.process == null
                ? null
                : call));
  }
}

/// Same as FutureFunctionCaller, but receives no input (Dart Generics don't support void functions)
///
/// Since call() is a void function, and will be null when the future is loading, you can directly pass it to buttons/touchables and expect it to be disabled.
class FutureProcedureCaller<TOutput> extends StatefulWidget {
  final Future<TOutput> Function()? process;
  final Widget Function(
          BuildContext context, AsyncSnapshot snapshot, void Function()? call)
      builder;
  const FutureProcedureCaller(
      {super.key, required this.process, required this.builder});

  @override
  State<FutureProcedureCaller<TOutput>> createState() =>
      _FutureProcedureCallerState<TOutput>();
}

class _FutureProcedureCallerState<TOutput>
    extends State<FutureProcedureCaller<TOutput>> {
  Future<TOutput>? future;

  void call() {
    setState(() {
      future = widget.process!();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TOutput>(
        future: future,
        builder: (context, snapshot) => widget.builder(
            context,
            snapshot,
            snapshot.connectionState == ConnectionState.waiting ||
                    widget.process == null
                ? null
                : call));
  }
}
