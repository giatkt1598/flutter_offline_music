import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

class AppAudioHandler extends BaseAudioHandler with ChangeNotifier {
  static late AppAudioHandler instance;

  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;

  Duration get duration => _player.duration ?? Duration.zero;

  Duration get position => _player.position;

  final List<MediaItem> _playlist = [];
  List<MediaItem> get playlist => _playlist;
  late List<MediaItem> _originPlaylist;
  setPlaylist(List<MediaItem> playlist) {
    _playlist.clear();
    _playlist.addAll(playlist);
    _originPlaylist = [...playlist];
  }

  MediaItem? _currentMediaItem;
  MediaItem? get currentMediaItem => _currentMediaItem;
  int get currentIndex =>
      _playlist.indexWhere((x) => x.id == _currentMediaItem?.id);
  bool get canPrevious => _playlist.isNotEmpty && currentIndex > 0;
  bool get canNext =>
      _playlist.isNotEmpty && currentIndex + 1 < _playlist.length;

  AppAudioHandler() {
    _createAudioPlayer();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> playMusic(Music music) async {
    MediaItem item = MediaItem(
      id: music.path,
      title: music.title,
      artist: music.artist ?? '<Không rõ tác giả>',
      album: 'Tất cả',
      artUri: Uri.parse(
        'https://img.vn/uploads/version/img24-png-20190726133727cbvncjKzsQ.png',
      ),
    );
    await playMediaItem(item);
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    if (_currentMediaItem?.id != mediaItem.id || _player.duration == null) {
      if (!File(mediaItem.id).existsSync()) {
        print('Not found path ${mediaItem.id}');
        return;
      }

      await _player.setFilePath(mediaItem.id);
    } else if (position >= duration) {
      seek(Duration.zero);
    }
    _currentMediaItem = mediaItem;
    this.mediaItem.add(_currentMediaItem);

    await play();
    notifyListeners();
  }

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() {
    return _player.pause();
  }

  @override
  Future<void> seek(Duration position) {
    return _player.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    if (!canNext) return;
    await playMediaItem(_playlist[currentIndex + 1]);
  }

  @override
  Future<void> skipToPrevious() async {
    if (!canPrevious) return;
    await playMediaItem(_playlist[currentIndex - 1]);
  }

  bool get isShuffle => _player.shuffleModeEnabled;
  setShuffle(bool isShuffle) {
    if (_playlist.length < 2) return;
    if (isShuffle) {
      _player.setShuffleModeEnabled(true);
      _playlist.shuffle();
      if (currentMediaItem != null) {
        _playlist.removeAt(currentIndex);
        _playlist.insert(0, currentMediaItem!);
      }
    } else {
      _player.setShuffleModeEnabled(false);
      _playlist.clear();
      _playlist.addAll(_originPlaylist);
    }
  }

  @override
  Future<void> rewind() async {
    // Ví dụ: Quay lại 10 giây
    final currentPosition = playbackState.value.position;
    seek(Duration(seconds: currentPosition.inSeconds - 10));
  }

  @override
  Future customAction(String name, [Map<String, dynamic>? extras]) async {
    print('action $name');
    stop();
    // return super.customAction(name, extras);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _createAudioPlayer() {
    _player.durationStream.listen((d) {
      notifyListeners();
    });

    _player.positionStream.listen((p) {
      if (position >= duration && duration > Duration.zero) {
        if (player.loopMode == LoopMode.one) {
          seek(Duration.zero);
        } else if (canNext) {
          skipToNext();
        } else if (player.loopMode == LoopMode.all && _playlist.isNotEmpty) {
          playMediaItem(_playlist.first);
        } else {
          stop();
        }
      }
      notifyListeners();
    });
    _notifyAudioHandlerAboutPlaybackEvents();
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            MediaControl(
              androidIcon:
                  playing
                      ? MediaControl.pause.androidIcon
                      : MediaControl.play.androidIcon,
              label: playing ? 'Tạm dừng' : 'Phát',
              action: MediaAction.playPause,
            ),
            MediaControl.skipToNext,
          ],
          systemActions: const {MediaAction.seek},
          androidCompactActionIndices: const [0, 1, 2],
          processingState:
              const {
                ProcessingState.idle: AudioProcessingState.idle,
                ProcessingState.loading: AudioProcessingState.loading,
                ProcessingState.buffering: AudioProcessingState.buffering,
                ProcessingState.ready: AudioProcessingState.ready,
                ProcessingState.completed: AudioProcessingState.completed,
              }[_player.processingState]!,
          repeatMode:
              const {
                LoopMode.off: AudioServiceRepeatMode.none,
                LoopMode.one: AudioServiceRepeatMode.one,
                LoopMode.all: AudioServiceRepeatMode.all,
              }[_player.loopMode]!,
          shuffleMode:
              (_player.shuffleModeEnabled)
                  ? AudioServiceShuffleMode.all
                  : AudioServiceShuffleMode.none,
          playing: playing,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
          queueIndex: event.currentIndex,
        ),
      );
    });
  }

  static Future<AppAudioHandler> createInstance() async {
    WidgetsFlutterBinding.ensureInitialized();
    // Kiểm tra & yêu cầu quyền thông báo trên Android 13+
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    instance = await AudioService.init(
      builder: () => AppAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.giatk.flutter_offline_music.audio',
        androidNotificationChannelName: 'Trình phát nhạc',
        androidNotificationChannelDescription: 'Trình phát nhạc - GPlayer',
        androidNotificationOngoing: true,
      ),
    );
    return instance;
  }
}
