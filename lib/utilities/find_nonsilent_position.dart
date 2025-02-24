import 'dart:async';
import 'dart:io';

import 'package:just_waveform/just_waveform.dart';
import 'package:path_provider/path_provider.dart';

class NonSilentFoundedResult {
  final Duration start;
  final Duration end;

  NonSilentFoundedResult(this.start, this.end);
}

@Deprecated('Quá chậm')
Future<NonSilentFoundedResult?> findNonSilentPosition(String filePath) async {
  final tempDir = await getTemporaryDirectory();
  final waveformFile = File('${tempDir.path}/waveform.json');
  // Phân tích sóng âm thanh
  final waveformStream = JustWaveform.extract(
    audioInFile: File(filePath),
    waveOutFile: waveformFile,
    zoom: WaveformZoom.samplesPerPixel(1),
  );
  final completer = Completer<NonSilentFoundedResult>();
  late StreamSubscription<WaveformProgress> progressDone;
  progressDone = waveformStream.listen((progress) {
    print('[wave]${progress.progress}');
    if (progress.waveform != null) {
      Duration start = _findFirstNonSilent(progress.waveform!);
      if (start != Duration.zero) {
        print('[wave]done');
        completer.complete(NonSilentFoundedResult(start, Duration.zero));
        progressDone.cancel();
      }
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

// Hàm tìm điểm bắt đầu không có khoảng lặng
Duration _findFirstNonSilent(Waveform waveform) {
  for (int i = 0; i < waveform.data.length - 3; i++) {
    if (abs(waveform.data[i]) > 1000 &&
        abs(waveform.data[i + 1]) > 1000 &&
        abs(waveform.data[i + 2]) > 1000) {
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
  for (int i = waveform.data.length - 1; i >= 0; i--) {
    if (waveform.data[i] > 0.02) {
      return Duration(milliseconds: (i / waveform.sampleRate * 1000).toInt());
    }
  }
  return Duration.zero;
}
