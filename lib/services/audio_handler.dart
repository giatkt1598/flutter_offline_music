import 'dart:async';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AppAudioHandler extends BaseAudioHandler with ChangeNotifier {
  static late AppAudioHandler instance;

  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;

  Duration get _duration => _player.duration ?? Duration.zero;
  Duration get _position => _player.position;
  bool playing = false;

  DateTime? _stopTime;
  DateTime? get stopTime => _stopTime;
  Timer? _timerStop;

  final List<MediaItem> _playlist = [];
  List<MediaItem> get playlist => _playlist;
  late List<MediaItem> _originPlaylist;
  setPlaylist(List<MediaItem> playlist) {
    _playlist.clear();
    _playlist.addAll(playlist);
    _originPlaylist = [...playlist];

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

  MediaItem? _currentMediaItem;
  MediaItem? get currentMediaItem => _currentMediaItem;
  int get currentIndex =>
      _playlist.indexWhere((x) => x.id == _currentMediaItem?.id);
  bool get canPrevious => _playlist.isNotEmpty && currentIndex > 0;
  bool get canNext =>
      _playlist.isNotEmpty && currentIndex + 1 < _playlist.length;

  StreamSubscription<Duration>? positionSubscription;

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
      duration: music.duration,
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
      if (SettingProvider.staticAppSetting.skipSilent) {
        // print('[wave]start');
        // var nonSilentPosition = await findNonSilentPosition(mediaItem.id);
        // print('[wave]end');
        // if (nonSilentPosition != null) {
        //   print('[wave]${nonSilentPosition.start}');
        //   await _player.seek(nonSilentPosition.start);
        // }
      }
    } else if (_position >= _duration) {
      seek(Duration.zero);
    }

    var albumArtFile = await getPictureFile(mediaItem.id);
    _currentMediaItem =
        albumArtFile != null
            ? mediaItem.copyWith(artUri: albumArtFile.uri)
            : mediaItem;

    this.mediaItem.add(_currentMediaItem);
    await play();
    notifyListeners();
  }

  @override
  Future<void> play() async {
    if (SettingProvider.staticAppSetting.autoVolumnPausePlay) {
      innerPlay() async {
        positionSubscription?.pause();
        playing = true;
        notifyListeners();

        await _player.setVolume(0.1);
        _player.play();

        await fadeOutAudio(reverse: true);
        positionSubscription?.resume();
      }

      innerPlay();
    } else {
      await _player.setVolume(1);
      await _player.play();
    }
  }

  @override
  Future<void> pause() async {
    positionSubscription?.pause();
    if (SettingProvider.staticAppSetting.autoVolumnPausePlay) {
      playing = false;
      notifyListeners();
      await fadeOutAudio();
    }
    await _player.pause();
    positionSubscription?.resume();
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
  Future<void> seek(Duration position) {
    return _player.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    if (!canNext) return;
    await pause();
    await playMediaItem(_playlist[currentIndex + 1]);
  }

  @override
  Future<void> skipToPrevious() async {
    if (!canPrevious) return;
    await pause();
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

  void _countDownStopTime() {
    final period = Duration(milliseconds: 500);
    _timerStop?.cancel();
    _timerStop = Timer.periodic(period, (timer) {
      if (!timer.isActive || _stopTime == null) return;

      if (_stopTime!.difference(DateTime.now()) <= Duration.zero) {
        stop();
        _stopTime = null;
        _timerStop?.cancel();
      }
    });
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
    _timerStop?.cancel();
    super.dispose();
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

  Future<File?> getPictureFile(String filePath) async {
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

  void _createAudioPlayer() {
    _player.durationStream.listen((d) {
      if (currentMediaItem != null) {
        _currentMediaItem = _currentMediaItem!.copyWith(duration: d);
      }
      notifyListeners();
    });

    positionSubscription = _player.positionStream.listen((p) {
      if (_position >= _duration && _duration > Duration.zero) {
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
      if (playing != _player.playing) {
        playing = _player.playing;
        notifyListeners();
      }
    });
    _notifyAudioHandlerAboutPlaybackEvents();
    _countDownStopTime();
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
