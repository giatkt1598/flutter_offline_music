import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/pages/player_pages/base/base_player_widget.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:flutter_offline_music/services/audio_handler.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

abstract class BasePlayerWidgetState extends State<BasePlayerWidget>
    with AutomaticKeepAliveClientMixin {
  Duration position = Duration.zero;
  StreamSubscription<Duration?>? positionSubscription;
  final musicService = MusicService();

  @override
  void initState() {
    onInitState();
    super.initState();
  }

  void onInitState() {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final audioHandler = playerProvider.audioHandler;

    setState(() {
      positionSubscription = audioHandler.player.positionStream.listen((p) {
        setState(() {
          position = p;
        });
      });
    });
  }

  void onDispose() {
    positionSubscription?.cancel();
  }

  @override
  void dispose() {
    onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final playerProvider = Provider.of<PlayerProvider>(context);
    final audioHandler = playerProvider.audioHandler;
    final settingProvider = Provider.of<SettingProvider>(context);
    final music = playerProvider.audioHandler.currentMusic!;
    String? backgroundImage = settingProvider.appSetting.playerBackgroundImage;
    if (backgroundImage == '') backgroundImage = null;
    final duration = audioHandler.currentMediaItem?.duration ?? Duration.zero;
    final currentPosition =
        audioHandler.playingMediaItemId == audioHandler.currentMediaItem?.id
            ? position
            : Duration.zero;

    bool isPlaying = audioHandler.playing;
    bool hasNext = audioHandler.canNext;
    bool hasPrevious = audioHandler.canPrevious;
    bool isShuffle = audioHandler.isShuffle;
    LoopMode loopMode = audioHandler.player.loopMode;

    Future<void> toggleFavorite() async {
      await playerProvider.toggleFavorite(music);
    }

    toggleShuffle() => audioHandler.setShuffle(!audioHandler.isShuffle);

    skipToPrevious() => audioHandler.skipToPrevious();

    skiptoNext() => audioHandler.skipToNext();

    seek(Duration position) => audioHandler.seek(position);

    Future<void> playPause() async {
      if (audioHandler.playing) {
        await audioHandler.pause();
      } else {
        await audioHandler.play();
      }
    }

    Future<void> changeLoopMode() async {
      switch (audioHandler.player.loopMode) {
        case LoopMode.off:
          await audioHandler.setLoopMode(LoopMode.all);
          break;
        case LoopMode.all:
          await audioHandler.setLoopMode(LoopMode.one);
          break;
        default:
          await audioHandler.setLoopMode(LoopMode.off);
          break;
      }
    }

    return buildUI(
      context: context,
      music: music,
      backgroundImage: backgroundImage,
      duration: duration,
      position: currentPosition,
      hasNext: hasNext,
      hasPrevious: hasPrevious,
      isPlaying: isPlaying,
      isShuffle: isShuffle,
      loopMode: loopMode,
      playerProvider: playerProvider,
      audioHandler: audioHandler,
      toggleFavorite: toggleFavorite,
      playPause: playPause,
      skipToNext: skiptoNext,
      skipToPrevious: skipToPrevious,
      seek: seek,
      toggleShuffle: toggleShuffle,
      changeLoopMode: changeLoopMode,
      stopTime: audioHandler.stopTime,
      setStopTimer: () => playerProvider.setStopTime(context),
    );
  }

  Widget buildUI({
    required BuildContext context,
    required PlayerProvider playerProvider,
    required AppAudioHandler audioHandler,
    required Music music,
    required String? backgroundImage,
    required Duration duration,
    required Duration position,
    required bool isPlaying,
    required bool hasNext,
    required bool hasPrevious,
    required bool isShuffle,
    required LoopMode loopMode,
    required Future<void> Function() toggleFavorite,
    required Future<void> Function() toggleShuffle,
    required Future<void> Function() skipToPrevious,
    required Future<void> Function() skipToNext,
    required Future<void> Function() playPause,
    required Future<void> Function(Duration position) seek,
    required Future<void> Function() changeLoopMode,
    required DateTime? stopTime,
    required Future<void> Function() setStopTimer,
  });

  @override
  void didChangeDependencies() {
    context.watch<SettingProvider>().appSetting.languageCode;
    super.didChangeDependencies();
  }

  @override
  bool get wantKeepAlive => true;
}
