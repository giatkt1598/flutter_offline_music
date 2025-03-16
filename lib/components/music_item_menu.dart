import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_offline_music/components/add_music_item_to_library.dart';
import 'package:flutter_offline_music/components/app_button.dart';
import 'package:flutter_offline_music/components/duration_picker.dart';
import 'package:flutter_offline_music/components/music_info.dart';
import 'package:flutter_offline_music/components/music_thumbnail.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/services/library_service.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:flutter_offline_music/services/toast_service.dart';
import 'package:flutter_offline_music/services/youtube_service.dart';
import 'package:flutter_offline_music/utilities/time_helper.dart';
import 'package:provider/provider.dart';

enum MusicMenuType { inMusicList, inPlayer, inPlaylist, inLibrary }

class MusicItemMenu extends StatefulWidget {
  const MusicItemMenu({
    super.key,
    required this.music,
    this.afterToggleHide,
    this.afterToggleFavorite,
    this.showMiniPlayer = true,
    this.type = MusicMenuType.inMusicList,
  });

  final Music music;
  final Function? afterToggleHide;
  final Function? afterToggleFavorite;
  final bool showMiniPlayer;
  final MusicMenuType type;
  @override
  State<MusicItemMenu> createState() => _MusicItemMenuState();
}

class _MusicItemMenuState extends State<MusicItemMenu> {
  final musicService = MusicService();
  final libraryService = LibraryService();
  final youtubeService = YoutubeService();
  showMusicInfo() async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    playerProvider.hideMiniPlayer();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chi tiết',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Opacity(opacity: 0.3, child: Divider()),
                MusicInfo(music: widget.music),
              ],
            ),
          ),
        );
      },
    );
    if (widget.showMiniPlayer) {
      playerProvider.showMiniPlayer();
    }
  }

  showAddToLibraryModal() async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    playerProvider.hideMiniPlayer();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.7,
          expand: false,
          builder: (context, scrollController) {
            return AddMusicItemToLibrary(music: widget.music);
          },
        );
      },
    );
    if (widget.showMiniPlayer) {
      playerProvider.showMiniPlayer();
    }
  }

  toggleHide() async {
    widget.music.isHidden = !widget.music.isHidden;
    await musicService.updateMusicAsync(widget.music);
    if (widget.afterToggleHide != null) {
      widget.afterToggleHide!();
    }
  }

  setStopTime() async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final audioHandler = playerProvider.audioHandler;
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        Duration? newDuration = audioHandler.stopTime?.difference(
          DateTime.now(),
        );

        return SizedBox(
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Hẹn giờ ngủ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16, width: 30, child: Divider()),
              DurationPicker(
                value: newDuration,
                onChanged: (du) {
                  newDuration = du == Duration.zero ? null : du;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, right: 64, left: 64),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 8,
                children: [
                  SizedBox(
                    width: 120,
                    child: AppButton(
                      type: AppButtonType.secondary,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: AppButton(
                      type: AppButtonType.primary,
                      onPressed: () {
                        audioHandler.setStopTime(duration: newDuration);
                        String message = '';
                        if (newDuration != null &&
                            newDuration! > Duration.zero) {
                          message =
                              'Tắt nhạc sau ${fDurationLong(newDuration!)}';
                        } else {
                          message = "Đã tắt hẹn giờ";
                        }
                        ToastService.showSuccess(message);
                        Navigator.pop(context);
                      },
                      child: Text('OK'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    if (widget.showMiniPlayer) {
      playerProvider.showMiniPlayer();
    }
  }

  showMenu() async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final audioHandler = playerProvider.audioHandler;
    playerProvider.hideMiniPlayer();
    final bool hasStopTime = playerProvider.audioHandler.stopTime != null;
    final Duration? stopDuration = playerProvider.audioHandler.stopTime
        ?.difference(DateTime.now());
    final isCurrent = widget.music.path == audioHandler.currentMediaItem?.id;
    bool? hideMiniPlayer = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8),
              ListTile(
                leading: MusicThumbnail(
                  musicPath: widget.music.path,
                  boxShape: BoxShape.rectangle,
                ),
                trailing: IconButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                    showMusicInfo();
                  },
                  icon: Icon(Icons.info_outline),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.music.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Opacity(
                      opacity: 0.4,
                      child: Text(
                        widget.music.artist ?? '<Không rõ tác giả>',
                        style: TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Opacity(opacity: .3, child: Divider()),
              Column(
                children: [
                  if (widget.type == MusicMenuType.inPlaylist)
                    ListMenuOption(
                      title: 'Phát',
                      icon: Icons.play_arrow_rounded,
                      enabled: !isCurrent,
                      onTap: () {
                        audioHandler.playMusic(widget.music);
                        Navigator.of(context).pop();
                      },
                    ),
                  if ((widget.type == MusicMenuType.inMusicList ||
                      widget.type == MusicMenuType.inPlaylist))
                    ListMenuOption(
                      icon: Icons.post_add_sharp,
                      title: 'Phát tiếp theo',
                      enabled: !isCurrent,
                      onTap: () async {
                        final nextIndex =
                            audioHandler.playlist.isEmpty
                                ? 0
                                : audioHandler.currentIndex + 1;
                        final success = await audioHandler.insertItemToPlaylist(
                          widget.music.toMediaItem(),
                          index: nextIndex,
                        );
                        if (success) {
                          ToastService.showSuccess(
                            'Tiếp theo sẽ phát bài "${widget.music.title}"',
                          );
                          if (nextIndex == 0) {
                            await audioHandler.playMusic(widget.music);
                          }
                        } else {
                          ToastService.showError('Xảy ra lỗi');
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                  if (widget.type == MusicMenuType.inPlaylist)
                    ListMenuOption(
                      title: 'Xóa khỏi danh sách phát',
                      icon: Icons.delete_rounded,
                      enabled: !isCurrent,
                      onTap: () {
                        audioHandler.removeItemInPlaylist(widget.music.path);
                        ToastService.showSuccess(
                          'Đã xóa "${widget.music.title}" khỏi danh sách phát',
                        );
                        Navigator.of(context).pop();
                      },
                    ),
                  ListMenuOption(
                    icon:
                        widget.music.isFavorite
                            ? Icons.heart_broken_outlined
                            : Icons.favorite,
                    title:
                        widget.music.isFavorite
                            ? 'Xóa khỏi Yêu thích'
                            : 'Thêm vào Yêu thích',
                    onTap: () {
                      widget.music.isFavorite = !widget.music.isFavorite;
                      musicService.updateMusicAsync(widget.music);
                      ToastService.showSuccess(
                        widget.music.isFavorite
                            ? 'Đã thêm vào Yêu thích'
                            : 'Đã xóa khỏi Yêu thích',
                      );
                      final musicInList =
                          playerProvider.musics
                              .where((x) => x.id == widget.music.id)
                              .firstOrNull;

                      if (musicInList != null) {
                        musicInList.isFavorite = widget.music.isFavorite;
                      }

                      final musicInPlaylist =
                          playerProvider.audioHandler.musics
                              .where((x) => x.id == widget.music.id)
                              .firstOrNull;
                      if (musicInPlaylist != null) {
                        musicInPlaylist.isFavorite = widget.music.isFavorite;
                        playerProvider.notifyChanges();
                      }

                      if (widget.afterToggleFavorite != null) {
                        widget.afterToggleFavorite!();
                      }
                      Navigator.pop(context);
                    },
                  ),
                  ListMenuOption(
                    icon: Icons.playlist_add,
                    title: 'Thêm vào thư viện',
                    onTap: () {
                      Navigator.pop(context, true);
                      showAddToLibraryModal();
                    },
                  ),
                  if (widget.type == MusicMenuType.inLibrary)
                    ListMenuOption(
                      title: 'Xóa khỏi thư viện',
                      icon: Icons.playlist_remove_rounded,
                      onTap: () async {
                        if (playerProvider.currentLibraryId == null) {
                          ToastService.showError('Không tìm thấy thư viện');
                          Navigator.of(context).pop();
                          return;
                        }

                        bool isSuccess =
                            await libraryService.removeMusicInLibraryAsync(
                              musicId: widget.music.id,
                              libraryId: playerProvider.currentLibraryId,
                            ) >
                            0;

                        if (isSuccess) {
                          playerProvider.musics.removeWhere(
                            (x) => x.id == widget.music.id,
                          );
                          playerProvider.setMusics(playerProvider.musics);
                          ToastService.showSuccess(
                            'Đã xóa bài hát "${widget.music.title}" khỏi thư viện',
                          );
                        } else {
                          ToastService.showError('Xảy ra lỗi');
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                  ListMenuOption(
                    iconColor: hasStopTime ? Colors.green : null,
                    icon: Icons.alarm_rounded,
                    title:
                        'Hẹn giờ ngủ${hasStopTime ? ' - Còn lại ${fDurationLong(stopDuration!)}' : ''}',
                    onTap: () {
                      Navigator.pop(context, true);
                      setStopTime();
                    },
                  ),
                  ListMenuOption(
                    icon:
                        widget.music.isHidden
                            ? Icons.visibility
                            : Icons.visibility_off_rounded,
                    title: widget.music.isHidden ? 'Hiển thị' : 'Ẩn',
                    onTap: () async {
                      bool isHidden = widget.music.isHidden;
                      await toggleHide();
                      ToastService.showSuccess(
                        'Đã ${isHidden ? 'hiển thị' : 'ẩn'} "${widget.music.title}"',
                      );
                      Navigator.pop(context, true);
                    },
                  ),
                  if (!widget.music.isOriginThumbnail &&
                      widget.music.thumbnail == null)
                    ListMenuOption(
                      title: 'Tải thumbnail từ youtube',
                      icon: Icons.image,
                      onTap: () async {
                        EasyLoading.show(
                          maskType: EasyLoadingMaskType.black,
                          status: 'Đang xử lý...',
                          dismissOnTap: false,
                        );
                        var thumbUrl = await youtubeService
                            .getVideoThumbnailAsync(widget.music.title);
                        if (thumbUrl != null) {
                          widget.music.thumbnail = thumbUrl;
                          await musicService.updateMusicAsync(widget.music);
                          ToastService.showSuccess(
                            'Đã cập nhật thumbnail cho bài hát từ youtube',
                          );
                          audioHandler.addThumbnailToPlaylistItems();
                        } else {
                          ToastService.showError(
                            'Xảy ra lỗi hoặc không tìm thấy thumbnail phù hợp',
                          );
                        }
                        EasyLoading.dismiss();
                        Navigator.pop(context);
                      },
                    ),
                  if (!widget.music.isOriginThumbnail &&
                      widget.music.thumbnail != null)
                    ListMenuOption(
                      title: 'Xóa thumbnail đã tải',
                      icon: Icons.image_not_supported,
                      onTap: () async {
                        widget.music.thumbnail = null;
                        await musicService.updateMusicAsync(widget.music);
                        ToastService.showSuccess('Đã xóa thumbnail');
                        audioHandler.addThumbnailToPlaylistItems();
                        Navigator.pop(context);
                      },
                    ),
                  Opacity(opacity: .3, child: Divider()),
                  ListMenuOption(
                    icon: Icons.delete_forever,
                    title: 'Xóa khỏi thiết bị',
                    iconColor: Colors.red,
                    onTap: () {
                      ToastService.show(
                        message: 'Chưa làm tính năng xóa này : <',
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
    if (hideMiniPlayer != true) {
      if (widget.showMiniPlayer) {
        playerProvider.showMiniPlayer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: showMenu, icon: Icon(Icons.more_vert));
  }
}

class ListMenuOption extends StatelessWidget {
  const ListMenuOption({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.enabled = true,
  });

  final String title;
  final IconData icon;
  final Function? onTap;
  final Color? iconColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity(vertical: -2),
      enabled: enabled,
      onTap: onTap != null ? () => onTap!() : null,
      leading: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: iconColor ?? Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
      ),
      title: Text(title),
    );
  }
}
