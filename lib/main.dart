import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_offline_music/pages/home_page.dart';
import 'package:flutter_offline_music/pages/splash_page.dart';
import 'package:flutter_offline_music/providers/music_folder_provider.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:flutter_offline_music/services/audio_handler.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var initialThemeMode = (await SettingProvider().loadSetting()).themeMode;
  await AppAudioHandler.createInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MusicFolderProvider()),
        ChangeNotifierProvider(create: (context) => PlayerProvider()),
        ChangeNotifierProvider(
          create:
              (context) => SettingProvider(initialThemeMode: initialThemeMode),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final appSetting = Provider.of<SettingProvider>(context).appSetting;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trình phát nhạc',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: appSetting.themeMode,
      home: const SplashPage(home: HomePage()),
      builder: (context, child) {
        return ToastificationWrapper(child: FlutterEasyLoading(child: child));
      },
    );
  }
}
