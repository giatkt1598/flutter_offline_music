import 'dart:collection';

class FutureQueue {
  final Queue<Future Function()> _taskQueue = Queue();

  void add(Future Function() func) {
    _taskQueue.add(func);
  }

  Future<void> start({required int concurrency}) async {
    while (_taskQueue.isNotEmpty) {
      // Lấy ra tối đa `concurrency` task để chạy cùng lúc
      List<Future> batch = List.generate(
        concurrency,
        (index) =>
            _taskQueue.isNotEmpty ? _taskQueue.removeFirst()() : Future.value(),
      );

      // Đợi tất cả các task trong batch hoàn thành
      await Future.wait(batch);
    }
  }
}
