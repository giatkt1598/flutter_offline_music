import 'package:flutter/material.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/services/audio_handler.dart';
import 'package:just_audio/just_audio.dart';

class BasePlayerData {
  final BuildContext context;
  final PlayerProvider playerProvider;
  final AppAudioHandler audioHandler;
  final Music music;
  final String? backgroundImage;
  final Duration duration;
  final Duration position;
  final bool isPlaying;
  final bool hasNext;
  final bool hasPrevious;
  final bool isShuffle;
  final LoopMode loopMode;
  final Future<void> Function() toggleFavorite;
  final Future<void> Function() toggleShuffle;
  final Future<void> Function() skipToPrevious;
  final Future<void> Function() skipToNext;
  final Future<void> Function() playPause;
  final Future<void> Function(Duration position) seek;
  final Future<void> Function() changeLoopMode;

  BasePlayerData({
    required this.context,
    required this.playerProvider,
    required this.audioHandler,
    required this.music,
    required this.backgroundImage,
    required this.duration,
    required this.position,
    required this.isPlaying,
    required this.hasNext,
    required this.hasPrevious,
    required this.isShuffle,
    required this.loopMode,
    required this.toggleFavorite,
    required this.toggleShuffle,
    required this.skipToPrevious,
    required this.skipToNext,
    required this.playPause,
    required this.seek,
    required this.changeLoopMode,
  });
}
