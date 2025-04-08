import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_offline_music/i18n/app_localizations.dart';
import 'package:flutter_offline_music/i18n/time_ago_vi_message.dart';
import 'package:flutter_offline_music/pages/home_page.dart';
import 'package:flutter_offline_music/pages/splash_page.dart';
import 'package:flutter_offline_music/providers/music_folder_provider.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:flutter_offline_music/providers/tab_provider.dart';
import 'package:flutter_offline_music/services/audio_handler.dart';
import 'package:flutter_offline_music/shared/shared_data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:toastification/toastification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  var initialThemeMode = (await SettingProvider().loadSetting()).themeMode;
  timeago.setLocaleMessages('vi', CustomViMessages());
  await AppAudioHandler.createInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TabProvider()),
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
    final String? fontFamily =
        GoogleFonts.beVietnamProTextTheme().bodyMedium?.fontFamily;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: GlobalContext.navigatorKey,
      locale:
          appSetting.languageCode == 'auto'
              ? null
              : Locale(appSetting.languageCode),
      onGenerateTitle:
          (context) => AppLocalizations.of(context)!.applicationName,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: fontFamily,
        appBarTheme: ThemeData.light().appBarTheme.copyWith(
          shadowColor: Colors.black26,
          backgroundColor: ThemeData.light().scaffoldBackgroundColor,
          surfaceTintColor: ThemeData.light().scaffoldBackgroundColor,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: ThemeData.dark().appBarTheme.copyWith(
          backgroundColor: Colors.black,
          surfaceTintColor: Colors.black,
          shadowColor: Colors.white24,
        ),
        textTheme: ThemeData.dark().textTheme.copyWith(
          bodyMedium: ThemeData.dark().textTheme.bodyMedium?.copyWith(
            fontFamily: fontFamily,
          ),
        ),
      ),
      themeMode: appSetting.themeMode,
      home: const SplashPage(home: HomePage()),
      builder: (context, child) {
        return ToastificationWrapper(child: FlutterEasyLoading(child: child));
      },
    );
  }
}
