import 'package:flutter/services.dart';
import 'package:flutter_offline_music/utilities/debug_helper.dart';

class AppBackgroundHelper {
  static const MethodChannel _channel = MethodChannel(
    'com.giatk.flutter_offline_music/background',
  );

  static Future<void> moveAppToBackground() async {
    try {
      await _channel.invokeMethod('moveToBackground');
    } on PlatformException catch (e) {
      logDebug("Lỗi khi đưa ứng dụng vào nền: ${e.message}");
    }
  }
}
