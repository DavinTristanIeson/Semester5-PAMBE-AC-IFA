import 'dart:async';

import 'package:flutter/widgets.dart';

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
