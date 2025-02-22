import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:provider/provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class MusicForegroundService {
  Future<void> checkNotificationPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

    if (!isAllowed) {
      // Hiển thị cảnh báo
      print('🔴 Người dùng chưa cấp quyền thông báo!');

      // Mở cài đặt ứng dụng để người dùng bật quyền
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  void init() {
    WidgetsFlutterBinding.ensureInitialized();
    AwesomeNotifications().initialize(
      null, // Sử dụng icon mặc định của ứng dụng
      [
        NotificationChannel(
          channelKey: 'music_channel',
          channelName: 'Music Player',
          channelDescription: 'Hiển thị trình phát nhạc',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
          playSound: false,
          importance: NotificationImportance.High,
        ),
      ],
    );
  }

  void showMusicNotification() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'music_channel',
        title: '🎵 Đang phát nhạc',
        body: 'Nhấn để điều khiển',
        notificationLayout: NotificationLayout.MediaPlayer,
      ),
      actionButtons: [
        NotificationActionButton(key: 'play', label: '▶ Play'),
        NotificationActionButton(key: 'pause', label: '⏸ Pause'),
        NotificationActionButton(key: 'stop', label: '⏹ Stop'),
      ],
    );
  }
}
