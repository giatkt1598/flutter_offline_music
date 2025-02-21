import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:provider/provider.dart';

class MusicForegroundService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleTask(response.payload ?? '');
      },
    );
  }

  static Future<void> showNotification(BuildContext context) async {
    print('show noti');
    final audioProvider = Provider.of<PlayerProvider>(context, listen: false);
    String actionText = audioProvider.isPlaying ? '⏸ Pause' : '▶ Play';
    String actionId = audioProvider.isPlaying ? 'pause' : 'play';

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'music_channel',
          'Music Player',
          importance: Importance.max,
          priority: Priority.high,
          ongoing: true,
          playSound: false,
        );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await _notificationsPlugin.show(
      0,
      'Đang phát nhạc',
      'Bấm vào nút điều khiển',
      platformChannelSpecifics,
      payload: actionId,
    );
  }

  static Future<void> startService(BuildContext context) async {
    print('start service fore');
    await FlutterForegroundTask.startService(
      notificationTitle: 'Trình phát nhạc',
      notificationText: 'Nhấn để mở ứng dụng',
      callback: () async => showNotification(context),
    );
  }

  static Future<void> stopService(BuildContext context) async {
    final audioProvider = Provider.of<PlayerProvider>(context, listen: false);
    await audioProvider.stopAsync();
    await FlutterForegroundTask.stopService();
    await _notificationsPlugin.cancelAll();
  }

  static Future<void> _handleTask(String id) async {
    if (id == 'play') {
      // Gọi Provider bằng cách lưu context ở main.dart (tránh lỗi thiếu context)
      PlayerProvider().play();
    } else if (id == 'pause') {
      PlayerProvider().pause();
    } else if (id == 'stop') {
      PlayerProvider().stopAsync();
    }
  }
}
