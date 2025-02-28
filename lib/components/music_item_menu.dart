import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/add_music_item_to_library.dart';
import 'package:flutter_offline_music/components/duration_picker.dart';
import 'package:flutter_offline_music/components/music_info.dart';
import 'package:flutter_offline_music/components/music_thumbnail.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:flutter_offline_music/utilities/time_helper.dart';
import 'package:provider/provider.dart';

class MusicItemMenu extends StatefulWidget {
  const MusicItemMenu({super.key, required this.music, this.afterToggleHide});

  final Music music;
  final Function? afterToggleHide;
  @override
  State<MusicItemMenu> createState() => _MusicItemMenuState();
}

class _MusicItemMenuState extends State<MusicItemMenu> {
  final musicService = MusicService();

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
    playerProvider.showMiniPlayer();
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
    playerProvider.showMiniPlayer();
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
              DurationPicker(
                value: newDuration,
                onChanged: (du) {
                  newDuration = du;
                },
              ),
              SizedBox(
                width: 120,
                child: OutlinedButton(
                  onPressed: () {
                    audioHandler.setStopTime(duration: newDuration);
                    String message = '';
                    if (newDuration != null && newDuration! > Duration.zero) {
                      message = 'Tắt nhạc sau ${fDurationLong(newDuration!)}';
                    } else {
                      message = "Đã tắt hẹn giờ";
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ),
              TextButton(
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
            ],
          ),
        );
      },
    );
    playerProvider.showMiniPlayer();
  }

  showMenu() async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    playerProvider.hideMiniPlayer();
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
                  ListMenuOption(
                    icon: Icons.post_add_sharp,
                    title: 'Thêm vào hàng đợi',
                    onTap: () {},
                  ),
                  ListMenuOption(
                    icon: Icons.playlist_add,
                    title: 'Thêm vào thư viện',
                    onTap: () {
                      Navigator.pop(context, true);
                      showAddToLibraryModal();
                    },
                  ),
                  ListMenuOption(
                    icon: Icons.alarm_rounded,
                    title: 'Hẹn giờ tắt nhạc',
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
                      await toggleHide();
                      Navigator.pop(context, true);
                    },
                  ),
                  Opacity(opacity: .3, child: Divider()),
                  ListMenuOption(
                    icon: Icons.delete_forever,
                    title: 'Xóa khỏi thiết bị',
                    iconColor: Colors.red,
                    onTap: () {},
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
      playerProvider.showMiniPlayer();
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
  });

  final String title;
  final IconData icon;
  final Function onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity(vertical: -2),
      onTap: () {
        onTap();
      },
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
