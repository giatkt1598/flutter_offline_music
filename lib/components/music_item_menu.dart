import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/add_music_item_to_library.dart';
import 'package:flutter_offline_music/components/music_info.dart';
import 'package:flutter_offline_music/components/music_thumbnail.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/pages/music_thumbnail_select_from_youtube_page.dart';
import 'package:flutter_offline_music/pages/select_player_theme_page.dart';
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
    this.onDeleted,
    this.showMiniPlayer = true,
    this.type = MusicMenuType.inMusicList,
    this.icon,
  });

  final Music music;
  final Function? afterToggleHide;
  final Function? afterToggleFavorite;
  final Function? onDeleted;
  final bool showMiniPlayer;
  final MusicMenuType type;
  final Widget? icon;
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
                  tr().detailTitle,
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
    await playerProvider.setStopTime(context);
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
                  thumbnailPath: widget.music.thumbnail,
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
                        widget.music.artist ?? tr().music_unknownArtist,
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
                  if (widget.type != MusicMenuType.inPlayer && !isCurrent)
                    ListMenuOption(
                      title: tr().musicMenu_play,
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
                      title: tr().musicMenu_playNext,
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
                            tr().musicMenu_playNextMessage(widget.music.title),
                          );
                          if (nextIndex == 0) {
                            await audioHandler.playMusic(widget.music);
                          }
                        } else {
                          ToastService.showError(tr().musicMenu_error);
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                  if (widget.type == MusicMenuType.inPlaylist)
                    ListMenuOption(
                      title: tr().musicMenu_removeFromPlaylist,
                      icon: Icons.delete_rounded,
                      enabled: !isCurrent,
                      onTap: () {
                        audioHandler.removeItemInPlaylist(widget.music.path);
                        ToastService.showSuccess(
                          tr().musicMenu_removeFromPlaylistSuccess(
                            widget.music.title,
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                    ),
                  ListMenuOption(
                    icon:
                        widget.music.isFavorite
                            ? Icons.heart_broken_outlined
                            : Icons.favorite,
                    iconColor:
                        widget.music.isFavorite ? null : Colors.pinkAccent,
                    title:
                        widget.music.isFavorite
                            ? tr().musicMenu_removeFromFavorite
                            : tr().musicMenu_addToFavorite,
                    onTap: () async {
                      bool isFavorite = widget.music.isFavorite;
                      await playerProvider.toggleFavorite(widget.music);
                      ToastService.showSuccess(
                        isFavorite
                            ? tr().musicMenu_removeFromFavoriteSuccess
                            : tr().musicMenu_addToFavoriteSuccess,
                      );

                      if (widget.afterToggleFavorite != null) {
                        widget.afterToggleFavorite!();
                      }
                      Navigator.pop(context);
                    },
                  ),
                  ListMenuOption(
                    icon: Icons.playlist_add,
                    title: tr().musicMenu_addToLibrary,
                    onTap: () {
                      Navigator.pop(context, true);
                      showAddToLibraryModal();
                    },
                  ),
                  if (widget.type == MusicMenuType.inLibrary)
                    ListMenuOption(
                      title: tr().musicMenu_removeFromLibrary,
                      icon: Icons.playlist_remove_rounded,
                      onTap: () async {
                        if (playerProvider.currentLibraryId == null) {
                          ToastService.showError(
                            tr().musicMenu_notFoundLibrary,
                          );
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
                            tr().musicMenu_removeFromLibrarySuccess(
                              widget.music.title,
                            ),
                          );
                        } else {
                          ToastService.showError(tr().musicMenu_error);
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                  ListMenuOption(
                    iconColor: hasStopTime ? Colors.green : null,
                    icon: Icons.alarm_rounded,
                    title:
                        '${tr().setStopTimeTitle}${hasStopTime ? ' - ${tr().remainingTitle} ${fDurationLong(stopDuration!)}' : ''}',
                    onTap: () {
                      Navigator.pop(context, true);
                      setStopTime();
                    },
                  ),
                  ListMenuOption(
                    title: tr().musicMenu_changeThumbnail,
                    icon: Icons.image,
                    onTap: () async {
                      String? img = await Navigator.of(context).push<String>(
                        MaterialPageRoute(
                          builder:
                              (context) => MusicThumbnailSelectFromYoutubePage(
                                music: widget.music,
                              ),
                        ),
                      );
                      if (img != null) {
                        widget.music.thumbnail = img;
                      }
                      Navigator.pop(context);
                    },
                  ),
                  if (widget.type == MusicMenuType.inPlayer)
                    ListMenuOption(
                      title: tr().musicMenu_changePlayerTheme,
                      icon: Icons.color_lens_outlined,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    SelectPlayerThemePage(music: widget.music),
                          ),
                        );
                      },
                    ),
                  Opacity(opacity: .3, child: Divider()),
                  if (widget.music.thumbnail != null)
                    ListMenuOption(
                      title: tr().musicMenu_removeThumbnail,
                      icon: Icons.image_not_supported,
                      onTap: () async {
                        widget.music.thumbnail = null;
                        await musicService.updateMusicAsync(widget.music);
                        ToastService.showSuccess(
                          tr().musicMenu_removeThumbnailSuccess(
                            widget.music.title,
                          ),
                        );
                        audioHandler.updateThumbnailToPlaylistItems();
                        playerProvider.notifyChanges();
                        Navigator.pop(context);
                      },
                    ),
                  ListMenuOption(
                    icon:
                        widget.music.isHidden
                            ? Icons.visibility
                            : Icons.visibility_off_rounded,
                    title:
                        widget.music.isHidden
                            ? tr().musicMenu_show
                            : tr().musicMenu_hide,
                    onTap: () async {
                      bool isHidden = widget.music.isHidden;
                      await toggleHide();
                      ToastService.showSuccess(
                        isHidden
                            ? tr().musicMenu_musicShown(widget.music.title)
                            : tr().musicMenu_musicHidden(widget.music.title),
                      );
                      Navigator.pop(context, true);
                    },
                  ),
                  if (widget.type != MusicMenuType.inPlayer && !isCurrent)
                    ListMenuOption(
                      icon: Icons.delete_forever,
                      title: tr().musicMenu_deleteOnDevice,
                      iconColor: Colors.red,
                      enabled: !isCurrent,
                      onTap: () async {
                        Navigator.of(context).pop();
                        bool success = await playerProvider.deleteMusicFile(
                          context,
                          widget.music,
                        );

                        if (success) {
                          ToastService.showSuccess(
                            tr().deleteMusicSuccess(widget.music.title),
                          );

                          if (widget.onDeleted != null) {
                            widget.onDeleted!();
                          }
                        }
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
    return IconButton(
      onPressed: showMenu,
      icon: widget.icon ?? Icon(Icons.more_vert),
    );
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
