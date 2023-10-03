import 'dart:async';

import 'package:flutter/widgets.dart';

/// Builder that's responsible for passing data asynchronously into its children through a stream.
///
/// The builder has control over when to get new data from the iterator using next().
///
/// All new data is received through the stream passed to the builder.
///
/// The caller can control how data is transmitted using the ``next`` parameter. The function should return the new index if there's still data in the iterator and null if there isn't.
///
/// The ``next`` function received by the builder returns a Future indicating if the data has finished being streamed or not. Callers should prevent ``next`` from being called while the Future is not finished. (Recommendation: Use FutureProcedureCaller with this)
///
/// The ``next`` function will be null when the stream is closed.
class UserControlledDataScroll<T> extends StatefulWidget {
  final FutureOr<int?> Function(StreamSink<T> sink, int index) next;
  final Widget Function(
          BuildContext context, Stream<T> stream, Future<void> Function()? next)
      builder;
  const UserControlledDataScroll(
      {super.key, required this.builder, required this.next});

  @override
  State<UserControlledDataScroll<T>> createState() =>
      _UserControlledDataScrollState<T>();
}

class _UserControlledDataScrollState<T>
    extends State<UserControlledDataScroll<T>> {
  late final StreamController<T> _loop;
  int index = 0;

  @override
  void initState() {
    super.initState();
    _loop = StreamController<T>();
  }

  @override
  void dispose() {
    super.dispose();
    if (!_loop.isClosed) {
      _loop.close();
    }
  }

  Future<void> next() async {
    int? result = await widget.next(_loop.sink, index);
    if (result == null) {
      setState(() {
        _loop.close();
      });
    } else {
      index = result;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _loop.stream, _loop.isClosed ? null : next);
  }
}
