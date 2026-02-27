import 'package:flutter_offline_music/utilities/future_queue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FutureQueue', () {
    test('runs all queued tasks with bounded concurrency', () async {
      final queue = FutureQueue();
      int running = 0;
      int peakRunning = 0;
      int completed = 0;

      Future<void> task() async {
        running++;
        if (running > peakRunning) peakRunning = running;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        running--;
        completed++;
      }

      queue.add(task);
      queue.add(task);
      queue.add(task);
      queue.add(task);
      await queue.start(concurrency: 2);

      expect(completed, 4);
      expect(peakRunning <= 2, isTrue);
    });
  });
}
