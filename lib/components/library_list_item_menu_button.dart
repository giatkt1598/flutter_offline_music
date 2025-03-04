import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/library_list_item_menu.dart';
import 'package:flutter_offline_music/models/library.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:provider/provider.dart';

class LibraryListItemMenuButton extends StatelessWidget {
  const LibraryListItemMenuButton({
    super.key,
    required this.library,
    required this.onRefresh,
  });
  final Library library;
  final Function onRefresh;
  @override
  Widget build(BuildContext context) {
    showMenuOption() async {
      final playerProvider = Provider.of<PlayerProvider>(
        context,
        listen: false,
      );
      playerProvider.hideMiniPlayer();
      await showModalBottomSheet(
        context: context,
        builder: (context) {
          return LibraryListItemMenu(library: library, onRefresh: onRefresh);
        },
      );
      playerProvider.showMiniPlayer();
    }

    return IconButton(onPressed: showMenuOption, icon: Icon(Icons.more_vert));
  }
}
