import 'package:flutter_offline_music/models/library.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/models/music_folder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Music', () {
    test('json roundtrip keeps values', () {
      final now = DateTime(2026, 2, 27, 10, 0, 0);
      final music = Music(
        id: 1,
        musicFolderId: 2,
        title: 'Song A',
        path: '/music/song_a.mp3',
        creationTime: now,
        artist: 'Artist',
        lengthInSecond: 125,
        thumbnail: '/img/a.jpg',
        genre: 'Pop',
        isHidden: true,
        skipSilentStart: 100,
        skipSilentEnd: 200,
        playedLastTime: now,
        playedCount: 8,
        isFavorite: true,
        isOriginThumbnail: true,
      );

      final parsed = Music.fromJson(music.toJson());

      expect(parsed.id, 1);
      expect(parsed.musicFolderId, 2);
      expect(parsed.title, 'Song A');
      expect(parsed.path, '/music/song_a.mp3');
      expect(parsed.artist, 'Artist');
      expect(parsed.lengthInSecond, 125);
      expect(parsed.thumbnail, '/img/a.jpg');
      expect(parsed.genre, 'Pop');
      expect(parsed.isHidden, isTrue);
      expect(parsed.skipSilentStart, 100);
      expect(parsed.skipSilentEnd, 200);
      expect(parsed.playedLastTime, now);
      expect(parsed.playedCount, 8);
      expect(parsed.isFavorite, isTrue);
      expect(parsed.isOriginThumbnail, isTrue);
      expect(parsed.duration, Duration(seconds: 125));
      expect(parsed.skipSilentStartDuration, Duration(milliseconds: 100));
      expect(parsed.skipSilentEndDuration, Duration(milliseconds: 200));
    });
  });

  group('Library', () {
    test('json roundtrip keeps values', () {
      final now = DateTime(2026, 2, 27, 10, 0, 0);
      final lib = Library(
        id: 9,
        title: 'Favorites',
        creationTime: now,
        lastModificationTime: now.add(Duration(hours: 1)),
      );

      final parsed = Library.fromJson(lib.toJson());
      expect(parsed.id, 9);
      expect(parsed.title, 'Favorites');
      expect(parsed.creationTime, now);
      expect(parsed.lastModificationTime, now.add(Duration(hours: 1)));
    });
  });

  group('MusicFolder', () {
    test('json roundtrip keeps values', () {
      final folder = MusicFolder(
        id: 5,
        path: '/music',
        name: 'Music',
        isHidden: true,
      );

      final parsed = MusicFolder.fromJson(folder.toJson());
      expect(parsed.id, 5);
      expect(parsed.path, '/music');
      expect(parsed.name, 'Music');
      expect(parsed.isHidden, isTrue);
    });
  });
}
