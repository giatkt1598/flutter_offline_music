import 'dart:io';

import 'package:flutter_offline_music/utilities/debug_helper.dart';
import 'package:flutter_offline_music/utilities/file_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;

class YoutubeService {
  Future<String?> getVideoThumbnailAsync(String videoName) async {
    if (videoName.endsWith('_Audio_128k')) {
      videoName = videoName.replaceAll('_Audio_128k', '');
    }
    String? videoUrl = await _searchYouTube(videoName);
    if (videoUrl != null) {
      String videoId = videoUrl.split("v=")[1]; // Lấy ID video từ URL
      return await _downloadThumbnail(videoId);
    }
    return null;
  }

  Future<String?> _searchYouTube(String query) async {
    var yt = YoutubeExplode();
    var searchResults = await yt.search.search(query);
    if (searchResults.isNotEmpty) {
      var video = searchResults.first; // Lấy video đầu tiên
      yt.close();
      return video.url; // Trả về URL video
    }

    yt.close();
    return null;
  }

  String _getThumbnailUrl(String videoId) {
    return "https://img.youtube.com/vi/$videoId/maxresdefault.jpg";
  }

  Future<String?> _downloadThumbnail(String videoId) async {
    try {
      String url = _getThumbnailUrl(videoId);
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var dir = await getApplicationDocumentsDirectory();
        String folderPath = '${dir.path}/youtube_thumbnail';
        await FileHelper.createDirectoryIfNotExists(folderPath);

        File file = File('$folderPath/$videoId.jpg');
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
    } catch (e) {
      logDebug("❌ Lỗi tải thumbnail: $e");
    }
    return null;
  }
}
