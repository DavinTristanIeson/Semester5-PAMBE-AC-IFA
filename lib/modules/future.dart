class FutureChunkDistributor<T> {
  final int chunkSize;
  final int count;
  final Future<T> Function(int index) compute;
  FutureChunkDistributor(this.compute,
      {required this.chunkSize, required this.count});
  Future<List<T>> wait() async {
    final List<T> result = [];

    int i = 0;
    while (i < count) {
      List<Future<T>> futures = [];
      while (i < count && futures.length < chunkSize) {
        futures.add(compute(i));
        i++;
      }
      result.addAll(await Future.wait(futures));
    }
    return result;
  }
}
