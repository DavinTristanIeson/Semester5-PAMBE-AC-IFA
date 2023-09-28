import 'dart:async';

import 'package:flutter/widgets.dart';

/// Builder that's responsible for passing data from an iterator into a stream (which is passed to the builder).
///
/// The builder has control over when to get new data from the iterator using next().
///
/// All new data is received through the stream passed to the builder.
///
/// By default, ``UserControlledDataScroll`` takes one item from the iterator, and then sends it through the stream until there's no item in the iterator anymore and the stream is closed.
///
/// The caller can control how data is transmitted using the ``next`` parameter. The function should return true if there's still data in the iterator and false if there isn't.
///
/// The ``next`` function received by the builder returns a Future indicating if the data has finished being streamed or not. Callers should prevent ``next`` from being called while the Future is not finished. (Recommendation: Use FutureProcedureCaller with this)
///
/// The ``next`` function will be null when the stream is closed.
class UserControlledDataScroll<T> extends StatefulWidget {
  final Iterator<T> data;
  final FutureOr<bool> Function(StreamSink sink, Iterator<T> iterator)? next;
  final Widget Function(
          BuildContext context, Stream<T> stream, Future<void> Function()? next)
      builder;
  const UserControlledDataScroll(
      {super.key, required this.data, required this.builder, this.next});

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
    if (widget.next != null) {
      bool hasNext = await widget.next!(_loop.sink, widget.data);
      setState(() {
        if (!hasNext && !_loop.isClosed) {
          _loop.close();
        }
      });
    } else {
      setState(() {
        if (widget.data.moveNext()) {
          _loop.sink.add(widget.data.current);
        } else if (!_loop.isClosed) {
          _loop.close();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _loop.stream, _loop.isClosed ? null : next);
  }
}
