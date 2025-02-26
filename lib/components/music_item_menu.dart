import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/music_info.dart';
import 'package:flutter_offline_music/components/music_thumbnail.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:provider/provider.dart';

class MusicItemMenu extends StatefulWidget {
  const MusicItemMenu({super.key, required this.music});

  final Music music;
  @override
  State<MusicItemMenu> createState() => _MusicItemMenuState();
}

class _MusicItemMenuState extends State<MusicItemMenu> {
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
                    title: 'Thêm vào danh sách phát',
                    onTap: () {},
                  ),
                  ListMenuOption(
                    icon: Icons.visibility_off_rounded,
                    title: 'Ẩn khỏi danh sách',
                    onTap: () {},
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
      visualDensity: VisualDensity(vertical: -4),
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
