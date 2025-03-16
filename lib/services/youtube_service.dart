import 'dart:io';

import 'package:flutter_offline_music/utilities/debug_helper.dart';
import 'package:flutter_offline_music/utilities/file_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;

class YoutubeService {
  var yt = YoutubeExplode();
  Future<String?> getVideoThumbnailAsync(String videoName) async {
    VideoSearchList? videos = await searchYouTube(videoName);
    return videos.isEmpty ? null : await downloadThumbnail(videos.first);
  }

  Future<VideoSearchList> searchYouTube(String query) async {
    VideoSearchList result = await yt.search.search(query);
    return result;
  }

  Future<String?> downloadThumbnail(Video video) async {
    try {
      late http.Response response;
      List<String> thumbUrls = [
        video.thumbnails.maxResUrl,
        video.thumbnails.highResUrl,
        video.thumbnails.mediumResUrl,
        video.thumbnails.standardResUrl,
        video.thumbnails.lowResUrl,
      ];
      for (var url in thumbUrls) {
        response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          break;
        }
      }

      if (response.statusCode == 200) {
        var dir = await getApplicationDocumentsDirectory();
        String folderPath = '${dir.path}/youtube_thumbnail';
        await FileHelper.createDirectoryIfNotExists(folderPath);

        File file = File('$folderPath/${video.id}.jpg');
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
    } catch (e) {
      logDebug("❌ Lỗi tải thumbnail: $e");
    }
    return null;
  }
}
