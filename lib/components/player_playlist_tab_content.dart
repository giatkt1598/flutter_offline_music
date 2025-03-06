import 'package:flutter/material.dart';

class PlayerPlaylistTabContent extends StatefulWidget {
  const PlayerPlaylistTabContent({super.key});

  @override
  State<PlayerPlaylistTabContent> createState() =>
      _PlayerPlaylistTabContentState();
}

class _PlayerPlaylistTabContentState extends State<PlayerPlaylistTabContent>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(child: Text('playlist'));
  }

  @override
  bool get wantKeepAlive => true;
}
