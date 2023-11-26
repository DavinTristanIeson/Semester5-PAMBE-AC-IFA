import 'package:pambe_ac_ifa/common/extensions.dart';

class FutureChunkDistributor<T> {
  final int chunkSize;
  final Iterable<Future<T>> futures;
  FutureChunkDistributor(this.futures, {required this.chunkSize});
  Future<List<T>> wait() async {
    final chunkedFutures =
        futures.chunks(chunkSize).map((chunk) => Future.wait(chunk));
    final List<T> result = [];
    for (final chunk in chunkedFutures) {
      result.addAll(await chunk);
    }
    return result;
  }
}
