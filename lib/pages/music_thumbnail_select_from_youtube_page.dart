import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_offline_music/components/search_field.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:flutter_offline_music/services/toast_service.dart';
import 'package:flutter_offline_music/services/youtube_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MusicThumbnailSelectFromYoutubePage extends StatefulWidget {
  const MusicThumbnailSelectFromYoutubePage({super.key, required this.music});

  final Music music;
  @override
  State<MusicThumbnailSelectFromYoutubePage> createState() =>
      _MusicThumbnailSelectFromYoutubePageState();
}

class _MusicThumbnailSelectFromYoutubePageState
    extends State<MusicThumbnailSelectFromYoutubePage> {
  final youtubeService = YoutubeService();
  final musicService = MusicService();
  late String keywords;
  VideoSearchList? videos;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isFullResult = false;
  Video? _selectedVideo;
  @override
  void initState() {
    super.initState();
    keywords = widget.music.title;
    handleSearch();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoading) {
      if (!_isFullResult) {
        handleNextPage();
      }
    }
  }

  handleNextPage() async {
    if (videos == null) return;
    setState(() {
      _isLoading = true;
    });
    var nextPage = await videos!.nextPage();
    setState(() {
      if (nextPage != null) {
        videos!.addAll(nextPage);
      } else {
        _isFullResult = true;
        ToastService.show(message: 'Đã hiển thị toàn bộ kết quả');
      }
      _isLoading = false;
    });
  }

  handleSearch() async {
    _isLoading = true;
    _isFullResult = false;
    _selectedVideo = null;
    EasyLoading.show(status: 'Đang tải');
    var searchResult = await youtubeService.searchYouTube(keywords);
    setState(() {
      videos = searchResult;
    });
    EasyLoading.dismiss();
    _isLoading = false;
  }

  handleSave() async {
    EasyLoading.show(status: 'Đang lưu...');
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    if (_selectedVideo == null) return;
    widget.music.thumbnail = await youtubeService.downloadThumbnail(
      _selectedVideo!,
    );
    if (widget.music.thumbnail != null) {
      await musicService.updateMusicAsync(widget.music);
      await playerProvider.audioHandler.updateThumbnailToPlaylistItems();
      playerProvider.notifyChanges();
      ToastService.showSuccess(
        'Đã cập nhật thumbnail cho "${widget.music.title}"',
      );
    } else {
      ToastService.showError('Xảy ra lỗi, vui lòng thử lại!');
    }
    EasyLoading.dismiss();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đổi ảnh bìa'),
        actions: [
          TextButton(
            onPressed: _selectedVideo != null ? handleSave : null,
            child: Text('Xong'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchField(
                initialValue: keywords,
                onSubmitted: (value) {
                  setState(() {
                    keywords = value;
                  });

                  handleSearch();
                },
              ),
            ),
            if (videos != null)
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Opacity(
                          opacity: 0.6,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Ảnh cung cấp bởi Youtube',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      StaggeredGrid.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 8,
                        children: [
                          ...videos!.map((video) {
                            final isSelected = _selectedVideo?.id == video.id;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedVideo = isSelected ? null : video;
                                });
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      video.thumbnails.mediumResUrl,
                                      fit: BoxFit.cover,
                                    ),

                                    if (isSelected)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            border: Border.all(
                                              width: 6,
                                              color:
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .primaryContainer,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (isSelected)
                                      Positioned(
                                        bottom: 8,
                                        right: 8,
                                        child: Center(
                                          child: Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      if (_isLoading)
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(),
                                ),
                                Text('Đang tải...'),
                              ],
                            ),
                          ),
                        ),
                      if (_isFullResult)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text('Đã hiển thị tất cả kết quả!'),
                          ),
                        ),
                      SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
