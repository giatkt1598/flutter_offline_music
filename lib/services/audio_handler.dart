import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:flutter_offline_music/services/toast_service.dart';
import 'package:flutter_offline_music/utilities/debug_helper.dart';
import 'package:just_audio/just_audio.dart';

class AppAudioHandler extends BaseAudioHandler with ChangeNotifier {
  static late AppAudioHandler instance;

  final AudioPlayer _player = AudioPlayer();
  bool playing = false;

  DateTime? _stopTime;
  Timer? _timerStop;
  final List<MediaItem> _playlist = [];
  final List<Music> _musics = [];
  List<Music> get musics => _musics;
  List<MediaItem> _originPlaylist = [];
  MediaItem? _currentMediaItem;
  String? playingMediaItemId;
  Music? _currentMusic;
  Music? get currentMusic => _currentMusic;

  StreamSubscription<Duration>? _positionSubscription;
  final _musicService = MusicService();
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

  Duration _audioListeningDuration = Duration.zero;
  Timer? _audioListeningTimer;
  bool _isPlayedCounted = false;
  final double playedCountThreshold = 0.6; // >= 60% of duration of audio

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

  Future<void> reorderPlaylist(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final item = _playlist.removeAt(oldIndex);
    _playlist.insert(newIndex, item);
    await player.moveAudioSource(oldIndex, newIndex);
  }

  Future<void> removeItemInPlaylist(String musicPath) async {
    int index = _playlist.indexWhere((x) => x.id == musicPath);
    _playlist.removeAt(index);
    _originPlaylist.removeWhere((x) => x.id == musicPath);
    _musics.removeWhere((x) => x.path == musicPath);
    await player.removeAudioSourceAt(index);
    notifyListeners();
  }

  Future<bool> insertItemToPlaylist(MediaItem item, {int? index}) async {
    int oldIndex = _playlist.indexWhere((x) => x.id == item.id);
    if (oldIndex > -1) {
      if (index == null) return false;
      await reorderPlaylist(oldIndex, index);
      notifyListeners();
      return true;
    }

    if (!_musics.any((x) => x.path == item.id)) {
      Music music = await _musicService.getMusicAsync(path: item.id);
      _musics.add(music);
    }

    if (_player.audioSource == null) {
      await _setPlaylist([item]);
      notifyListeners();
      return true;
    } else {
      _playlist.insert(index ?? _playlist.length, item);
      if (!_originPlaylist.any((x) => x.id == item.id)) {
        _originPlaylist.add(item);
      }
      await player.insertAudioSource(
        index ?? player.audioSources.length,
        AudioSource.file(item.id),
      );
      notifyListeners();
      return player.audioSources.any(
        (x) => (x as ProgressiveAudioSource).uri.toFilePath() == item.id,
      );
    }
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
    bool isEnd =
        !_player.playing &&
        _player.position > Duration.zero &&
        _player.duration != null &&
        _player.position >= _player.duration!;

    if (isEnd) {
      await seek(Duration.zero);
    }

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
    if (_playlist.every((x) => x.id != mediaItem.id)) {
      await insertItemToPlaylist(mediaItem, index: currentIndex + 1);
    }

    if (playingMediaItemId != mediaItem.id || _player.duration == null) {
      if (!File(mediaItem.id).existsSync()) {
        ToastService.showError(tr().notFoundFileName(mediaItem.id));
        final mediaIndex = _playlist.indexWhere((x) => x.id == mediaItem.id);
        await _setPlaylist(
          _playlist.where((x) => x.id != mediaItem.id).toList(),
        );
        if (mediaIndex < _playlist.length) {
          playingMediaItemId = null;
          await stop();
          await playMediaItem(_playlist[mediaIndex]);
        } else {
          await stop();
        }
        return;
      }

      playingMediaItemId = mediaItem.id;
      final audioSourceIndex = _player.sequence.indexWhere(
        (x) => (x as ProgressiveAudioSource).uri.toFilePath() == mediaItem.id,
      );

      await _player.seek(Duration.zero, index: audioSourceIndex);

      await _setCurrentMediaItem(mediaItem);
    } else if (_position >= _duration) {
      seek(Duration.zero);
    }

    await play();
    notifyListeners();
  }

  Future<void> playMusic(Music music) async {
    MediaItem item = music.toMediaItem();
    if (!_musics.any((x) => x.id == music.id)) {
      _musics.add(music);
    }
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

  Future<void> setPlaylistFromMusics(List<Music> musics) async {
    _musics.clear();
    _musics.addAll(musics);
    await _setPlaylist(musics.map((x) => x.toMediaItem()).toList());
  }

  Future<void> _setPlaylist(List<MediaItem> playlist) async {
    _playlist.clear();
    _playlist.addAll(playlist);
    _originPlaylist = [...playlist];
    try {
      await _player.setAudioSources(
        playlist.map((m) => AudioSource.file(m.id)).toList(),
      );
    } catch (e) {
      logDebug('[Exception] $e');
    }

    if (isShuffle) {
      await setShuffle(true);
    }

    updateThumbnailToPlaylistItems();
  }

  Future<void> updateThumbnailToPlaylistItems() async {
    var allMusics = await _musicService.getListMusicAsync();
    for (var item in _playlist) {
      final music = allMusics.where((x) => x.path == item.id).firstOrNull;
      _playlist[_playlist.indexOf(item)] = _playlist[_playlist.indexOf(item)]
          .copyWith(artUri: music?.toMediaItem().artUri);
      _musics.where((x) => x.path == item.id).firstOrNull?.thumbnail =
          music?.thumbnail;
    }
    // notifyListeners();
  }

  Future<void> setShuffle(bool isShuffle) async {
    if (_player.sequence.length < 2) return;
    if (isShuffle) {
      await _player.setShuffleModeEnabled(true);
      await _player.shuffle();
      _playlist.clear();
      _playlist.addAll(_player.shuffleIndices.map((x) => _findMediaItem(x)!));
    } else {
      await _player.setShuffleModeEnabled(false);
      _playlist.clear();
      _playlist.addAll(
        _player.sequence.map(
          (x) => _findMediaItem(_player.sequence.indexOf(x))!,
        ),
      );
    }
    notifyListeners();
  }

  void setStopTime({Duration? duration}) {
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
    // _setCurrentMediaItem(null);
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

  void _evaluateIncreasingPlayedCount() {
    bool isIncreasePlayedCount =
        _currentMediaItem != null &&
        _isPlayedCounted == false &&
        _currentMediaItem?.duration != null &&
        _currentMediaItem!.duration! > Duration.zero &&
        _audioListeningDuration >=
            _currentMediaItem!.duration! * playedCountThreshold;
    if (!isIncreasePlayedCount) {
      return;
    }
    // logDebug('increase count for ${_currentMediaItem!.id}');
    _musicService.increaseMusicPlayedCount(_currentMediaItem!.id);
    _audioListeningDuration = Duration.zero;
    _isPlayedCounted = true;
  }

  void _createAudioPlayer() {
    _player.setSkipSilenceEnabled(SettingProvider.staticAppSetting.skipSilent);

    _player.playingStream.listen((isPlaying) {
      if (isPlaying) {
        _audioListeningTimer ??= Timer.periodic(Duration(seconds: 1), (timer) {
          _audioListeningDuration += Duration(seconds: 1);
        });
      } else {
        _audioListeningTimer?.cancel();
        _audioListeningTimer = null;
      }
    });

    _player.currentIndexStream.listen((index) {
      if (index == null) {
        return;
      }
      if (SettingProvider.staticAppSetting.autoVolumnPausePlay) {
        _player.setVolume(0.1).then((_) {
          fadeOutAudio(reverse: true);
        });
      }

      _isPlayedCounted = false;
      _audioListeningDuration = Duration.zero;

      final currentMediaItem = _findMediaItem(index);
      playingMediaItemId = currentMediaItem?.id;
      bool isNullCurrent = _currentMediaItem == null;
      _setCurrentMediaItem(currentMediaItem);
      if (!isNullCurrent) {
        notifyListeners();
      }
    });

    _player.processingStateStream.listen((state) {
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

      if (latestPosition < Duration(seconds: 1) && _isPlayedCounted) {
        _audioListeningDuration = Duration.zero;
        _isPlayedCounted = false;
      }
      _evaluateIncreasingPlayedCount();
    });

    _notifyAudioHandlerAboutPlaybackEvents();
    _countDownStopTime();
  }

  MediaItem? _findMediaItem(int audioSourceIndex) {
    final audioSource =
        _player.sequence[audioSourceIndex] as ProgressiveAudioSource?;
    final item =
        _originPlaylist
            .where((x) => x.id == audioSource?.uri.toFilePath())
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
    _currentMediaItem = mediaItem;
    _currentMusic =
        _currentMediaItem != null
            ? _musics.where((x) => x.path == _currentMediaItem!.id).firstOrNull
            : null;
    this.mediaItem.add(_currentMediaItem?.copyWith(extras: null));

    if (mediaItem != null) {
      await _musicService.updateMusicPlayedLastTime(mediaItem.id);
    }
  }

  static Future<AppAudioHandler> createInstance() async {
    WidgetsFlutterBinding.ensureInitialized();

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
