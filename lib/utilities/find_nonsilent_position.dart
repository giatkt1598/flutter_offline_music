import 'dart:async';
import 'dart:io';

import 'package:just_waveform/just_waveform.dart';
import 'package:path_provider/path_provider.dart';

class NonSilentFoundedResult {
  final Duration start;
  final Duration end;

  NonSilentFoundedResult(this.start, this.end);
}

//TODO: Fix performance
Future<NonSilentFoundedResult?> findNonSilentPosition(String filePath) async {
  final tempDir = await getTemporaryDirectory();
  final waveformFile = File(
    '${tempDir.path}/${filePath.replaceAll('/', '_')}.json',
  );
  // Phân tích sóng âm thanh
  final waveformStream = JustWaveform.extract(
    audioInFile: File(filePath),
    waveOutFile: waveformFile,
    zoom: WaveformZoom.samplesPerPixel(1),
  );
  final completer = Completer<NonSilentFoundedResult>();
  late StreamSubscription<WaveformProgress> progressDone;
  progressDone = waveformStream.listen((progress) {
    if (progress.waveform != null) {
      Duration start = _findFirstNonSilent(progress.waveform!);
      Duration end = _findLastNonSilent(progress.waveform!);
      completer.complete(NonSilentFoundedResult(start, end));
      progressDone.cancel();
    }
  });
  return completer.future;
}

abs(int num) {
  if (num < 0) {
    return -num;
  }
  return num;
}

final int _totalStartNonSilentWave = 10;
final int _nonSilentThreshold = 1000;

// Hàm tìm điểm bắt đầu không có khoảng lặng
Duration _findFirstNonSilent(Waveform waveform) {
  for (int i = 0; i < waveform.data.length - _totalStartNonSilentWave; i++) {
    final isTouchedNonSilent = waveform.data
        .sublist(i, i + _totalStartNonSilentWave)
        .every((w) => abs(w) > _nonSilentThreshold);
    if (isTouchedNonSilent) {
      // Ngưỡng khoảng lặng
      Duration position = Duration(
        milliseconds:
            (i / waveform.data.length * waveform.duration.inMilliseconds)
                .toInt(),
      );
      return position;
    }
  }
  return Duration.zero;
}

// Hàm tìm điểm kết thúc không có khoảng lặng
Duration _findLastNonSilent(Waveform waveform) {
  for (int i = waveform.data.length - 1; i > _totalStartNonSilentWave; i--) {
    final isTouchedNonSilent = waveform.data
        .sublist(i - _totalStartNonSilentWave, i)
        .every((w) => abs(w) > _nonSilentThreshold);
    if (isTouchedNonSilent) {
      // Ngưỡng khoảng lặng
      Duration position = Duration(
        milliseconds:
            (i / waveform.data.length * waveform.duration.inMilliseconds)
                .toInt(),
      );
      return position;
    }
  }
  return Duration.zero;
}
