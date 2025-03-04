import 'dart:async';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:flutter_offline_music/services/toast_service.dart';
import 'package:flutter_offline_music/utilities/debug_helper.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart';

class AppAudioHandler extends BaseAudioHandler with ChangeNotifier {
  static late AppAudioHandler instance;

  final AudioPlayer _player = AudioPlayer();
  bool playing = false;

  DateTime? _stopTime;
  Timer? _timerStop;
  final List<MediaItem> _playlist = [];

  late List<MediaItem> _originPlaylist;
  MediaItem? _currentMediaItem;
  String? playingMediaItemId;

  StreamSubscription<Duration>? _positionSubscription;
  AppAudioHandler() {
    _createAudioPlayer();
  }
  bool get canNext =>
      _playlist.isNotEmpty && currentIndex + 1 < _playlist.length;
  bool get canPrevious => _playlist.isNotEmpty && currentIndex > 0;

  int get currentIndex =>
      _playlist.indexWhere((x) => x.id == _currentMediaItem?.id);
  MediaItem? get currentMediaItem => _currentMediaItem;
  bool get isShuffle => _player.shuffleModeEnabled;
  AudioPlayer get player => _player;
  List<MediaItem> get playlist => _playlist;
  DateTime? get stopTime => _stopTime;
  Duration get _duration => _player.duration ?? Duration.zero;

  Duration get _position => _player.position;

  @override
  Future customAction(String name, [Map<String, dynamic>? extras]) async {
    logDebug('action $name');
    stop();
    // return super.customAction(name, extras);
  }

  @override
  void dispose() {
    _player.dispose();
    _timerStop?.cancel();
    super.dispose();
  }

  Future<void> fadeOutAudio({bool reverse = false}) {
    Completer completer = Completer<void>();
    double volume = reverse ? 0.0 : 1.0;
    int steps = 20;
    Duration stepDuration = Duration(milliseconds: 50); // 20 step * 50ms = 1s

    Timer.periodic(stepDuration, (timer) {
      if (!reverse) {
        volume -= 1.0 / steps;
        if (volume <= 0) {
          volume = 0;
          timer.cancel();
          completer.complete();
        }
      } else {
        volume += (1.0 / steps);
        if (volume >= 1) {
          volume = 1;
          timer.cancel();
          completer.complete();
        }
      }
      _player.setVolume(volume);
    });
    return completer.future;
  }

  Picture? getPicture(String? path) {
    if (path == null) {
      return null;
    }
    final metadata = readMetadata(File(path), getImage: true);
    if (metadata.pictures.isNotEmpty) {
      Picture pic = metadata.pictures.first;
      return pic;
    } else {
      return null;
    }
  }

  Future<File?> getPictureFile(String? filePath) async {
    if (filePath == null) return null;
    final tempDir = await getTemporaryDirectory();
    final imgName = 'album_art_${filePath.replaceAll('/', '_')}.jpg';
    final albumArtPath = "${tempDir.path}/$imgName";
    var albumArtFile = File(albumArtPath);
    if (albumArtFile.existsSync()) {
      return albumArtFile;
    }
    final pic = getPicture(filePath);
    if (pic != null) {
      albumArtFile.writeAsBytesSync(pic.bytes);
      return albumArtFile;
    }
    return null;
  }

  @override
  Future<void> pause() async {
    _positionSubscription?.pause();
    if (SettingProvider.staticAppSetting.autoVolumnPausePlay) {
      playing = false;
      notifyListeners();
      await fadeOutAudio();
    }
    await _player.pause();
    _positionSubscription?.resume();
  }

  @override
  Future<void> play() async {
    if (SettingProvider.staticAppSetting.autoVolumnPausePlay) {
      innerPlay() async {
        _positionSubscription?.pause();
        playing = true;
        notifyListeners();

        await _player.setVolume(0.1);
        _player.play();

        await fadeOutAudio(reverse: true);
        _positionSubscription?.resume();
      }

      innerPlay();
    } else {
      await _player.setVolume(1);
      await _player.play();
    }
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    if (playingMediaItemId != mediaItem.id || _player.duration == null) {
      if (!File(mediaItem.id).existsSync()) {
        logDebug('Not found path ${mediaItem.id}');
        return;
      }

      playingMediaItemId = mediaItem.id;
      final audioSourceIndex = _player.sequence?.indexWhere(
        (x) => (x as ProgressiveAudioSource).uri.toFilePath() == mediaItem.id,
      );
      logDebug(audioSourceIndex);
      // await _player.setFilePath(mediaItem.id);
      final Music music = mediaItem.extras!['music'] as Music;
      final startPosition =
          SettingProvider.staticAppSetting.skipSilent
              ? music.skipSilentStartDuration ?? Duration.zero
              : Duration.zero;

      if (audioSourceIndex != null) {
        await _player.seek(startPosition, index: audioSourceIndex);
      } else {
        ToastService.show(
          message: "Lỗi không tìm thấy audioSource",
          type: ToastificationType.error,
        );
      }

      await _setCurrentMediaItem(mediaItem);
    } else if (_position >= _duration) {
      seek(Duration.zero);
    }

    await play();
    notifyListeners();
  }

  Future<void> playMusic(Music music) async {
    MediaItem item = music.toMediaItem();
    await playMediaItem(item);
  }

  @override
  Future<void> rewind() async {
    // Ví dụ: Quay lại 10 giây
    final currentPosition = playbackState.value.position;
    seek(Duration(seconds: currentPosition.inSeconds - 10));
  }

  @override
  Future<void> seek(Duration position) {
    return _player.seek(position);
  }

  Future<void> setLoopMode(LoopMode mode) async {
    await _player.setLoopMode(mode);
    notifyListeners();
  }

  setPlaylist(List<MediaItem> playlist) {
    _playlist.clear();
    _playlist.addAll(playlist);
    _originPlaylist = [...playlist];
    _player.setAudioSource(
      ConcatenatingAudioSource(
        children: playlist.map((m) => AudioSource.file(m.id)).toList(),
      ),
    );

    addArtPictureToPlaylist() async {
      for (var item in _playlist) {
        var art = await getPictureFile(item.id);
        if (art == null) continue;
        _playlist[_playlist.indexOf(item)] = item.copyWith(artUri: art.uri);
      }
      notifyListeners();
    }

    addArtPictureToPlaylist();
  }

  Future<void> setShuffle(bool isShuffle) async {
    if (_player.sequence == null || _player.sequence!.length < 2) return;
    if (isShuffle) {
      await _player.setShuffleModeEnabled(true);
      await _player.shuffle();
      _playlist.clear();
      _playlist.addAll(_player.shuffleIndices!.map((x) => _findMediaItem(x)!));
    } else {
      await _player.setShuffleModeEnabled(false);
      _playlist.clear();
      _playlist.addAll(
        _player.sequence!.map(
          (x) => _findMediaItem(_player.sequence!.indexOf(x))!,
        ),
      );
    }
    notifyListeners();
  }

  setStopTime({Duration? duration}) {
    if (duration == null) {
      // off feature auto stop
      _stopTime = null;
    } else {
      _stopTime = DateTime.now().add(duration);
      _countDownStopTime();
    }
    notifyListeners();
  }

  @override
  Future<void> skipToNext() async {
    if (!canNext) return;
    final nextMediaItem = _playlist[currentIndex + 1];
    _setCurrentMediaItem(nextMediaItem);
    notifyListeners();
    if (SettingProvider.staticAppSetting.autoVolumnPausePlay) {
      await fadeOutAudio();
    }
    await playMediaItem(nextMediaItem);
  }

  @override
  Future<void> skipToPrevious() async {
    if (!canPrevious) return;
    final preMediaItem = _playlist[currentIndex - 1];
    _setCurrentMediaItem(preMediaItem);
    notifyListeners();
    if (SettingProvider.staticAppSetting.autoVolumnPausePlay) {
      await fadeOutAudio();
    }
    await playMediaItem(preMediaItem);
  }

  @override
  Future<void> stop() async {
    playing = false;
    await _player.stop();
    notifyListeners();
  }

  void _countDownStopTime() {
    final period = Duration(milliseconds: 500);
    _timerStop?.cancel();
    _timerStop = Timer.periodic(period, (timer) {
      if (!timer.isActive || _stopTime == null) return;

      if (_stopTime!.difference(DateTime.now()) <= Duration.zero) {
        _positionSubscription?.pause();
        stop();
        _stopTime = null;
        _timerStop?.cancel();
        Future.delayed(Duration(seconds: 1), () {
          _positionSubscription?.resume();
        });
      }
    });
  }

  void _createAudioPlayer() {
    player.currentIndexStream.listen((index) {
      if (index == null) {
        return;
      }
      if (SettingProvider.staticAppSetting.autoVolumnPausePlay) {
        _player.setVolume(0.1).then((_) {
          fadeOutAudio(reverse: true);
        });
      }
      final currentMediaItem = _findMediaItem(index);
      playingMediaItemId = currentMediaItem?.id;
      _setCurrentMediaItem(currentMediaItem);
    });

    player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        stop();
      }
    });

    _positionSubscription = _player.positionStream.listen((latestPosition) {
      if (_positionSubscription?.isPaused == true) return;

      if (playing != _player.playing) {
        playing = _player.playing;
        notifyListeners();
      }
    });
    _notifyAudioHandlerAboutPlaybackEvents();
    _countDownStopTime();
  }

  MediaItem? _findMediaItem(int audioSourceIndex) {
    final audioSource =
        _player.sequence![audioSourceIndex] as ProgressiveAudioSource;
    final item =
        _originPlaylist
            .where((x) => x.id == audioSource.uri.toFilePath())
            .firstOrNull;
    return item;
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

  Future<void> _setCurrentMediaItem(MediaItem? mediaItem) async {
    var albumArtFile = await getPictureFile(mediaItem?.id);
    _currentMediaItem =
        albumArtFile != null
            ? mediaItem?.copyWith(artUri: albumArtFile.uri)
            : mediaItem;

    this.mediaItem.add(_currentMediaItem?.copyWith(extras: null));
    notifyListeners();
  }

  static Future<AppAudioHandler> createInstance() async {
    WidgetsFlutterBinding.ensureInitialized();
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
