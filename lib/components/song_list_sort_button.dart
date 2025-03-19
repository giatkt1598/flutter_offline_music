import 'package:flutter/material.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:provider/provider.dart';

class SongListSortButton extends StatefulWidget {
  const SongListSortButton({
    super.key,
    required this.initialSortDirection,
    required this.initialSortField,
    required this.onChanged,
  });

  final String initialSortField;
  final String initialSortDirection;
  final Function(String sortField, String sortDirection) onChanged;

  @override
  State<SongListSortButton> createState() => _SongListSortButtonState();
}

class _SongListSortButtonState extends State<SongListSortButton> {
  String sortField = '';
  String sortDirection = '';

  String get sortBy => '$sortField $sortDirection';
  @override
  void initState() {
    sortField = widget.initialSortField;
    sortDirection = widget.initialSortDirection;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    final Map<String, Map<String, IconData>> sortFieldOptions = {
      "title": {tr().sortField_musicName: Icons.music_note_rounded},
      "artist": {tr().sortField_artist: Icons.person_outline_outlined},
      "lengthInSecond": {tr().sortField_length: Icons.swap_horiz},
    };

    showModal() async {
      playerProvider.hideMiniPlayer();
      await showModalBottomSheet(
        context: context,
        builder: (context) {
          closeModal() {
            Navigator.pop(context);
          }

          return StatefulBuilder(
            builder:
                (context, setState) => Container(
                  padding: EdgeInsets.all(16),
                  height: 440,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ModalTitle(title: tr().sortByTitle),
                      for (var item in sortFieldOptions.entries)
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 0),
                          minTileHeight: 30,

                          onTap: () {
                            setState(() {
                              sortField = item.key;
                            });
                            closeModal();
                          },
                          title: Text(item.value.keys.first),
                          leading: Icon(item.value.values.first),
                          trailing: Radio(
                            value: item.key,
                            groupValue: sortField,
                            onChanged:
                                (val) => setState(() {
                                  sortField = val!;
                                  closeModal();
                                }),
                          ),
                        ),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 0),
                        onTap: () {
                          setState(() {
                            sortField = 'creationTime';
                            sortDirection = 'desc';
                          });
                          closeModal();
                        },
                        minTileHeight: 30,
                        title: Text(tr().sortField_newest),
                        leading: Icon(Icons.fiber_new_rounded),
                        trailing: Radio(
                          value: 'creationTime desc',
                          groupValue: sortBy,
                          onChanged:
                              (val) => setState(() {
                                sortField = val!;
                                sortDirection = 'desc';

                                closeModal();
                              }),
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 0),
                        minTileHeight: 30,
                        onTap: () {
                          setState(() {
                            sortField = 'creationTime';
                            sortDirection = 'asc';
                          });
                          closeModal();
                        },
                        title: Text(tr().sortField_oldest),
                        leading: Icon(Icons.history),
                        trailing: Radio(
                          value: 'creationTime asc',
                          groupValue: sortBy,
                          onChanged:
                              (val) => setState(() {
                                sortField = val!;
                                sortDirection = 'asc';

                                closeModal();
                              }),
                        ),
                      ),
                      Divider(),
                      SizedBox(height: 16),
                      ModalTitle(title: tr().sortDirectionTitle),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 0),
                        title: Text(tr().sortDirection_ascending),
                        leading: Icon(Icons.arrow_upward_rounded),
                        minTileHeight: 30,
                        onTap: () {
                          setState(() {
                            sortDirection = 'asc';
                            closeModal();
                          });
                        },
                        trailing: Radio(
                          value: 'asc',
                          groupValue: sortDirection,
                          onChanged:
                              (val) => setState(() {
                                sortDirection = val!;
                                closeModal();
                              }),
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 0),
                        title: Text(tr().sortDirection_descending),
                        leading: Icon(Icons.arrow_downward_rounded),
                        minTileHeight: 30,
                        onTap: () {
                          setState(() {
                            sortDirection = 'desc';
                          });
                          closeModal();
                        },
                        trailing: Radio(
                          value: 'desc',
                          groupValue: sortDirection,
                          onChanged:
                              (val) => setState(() {
                                sortDirection = val!;
                                closeModal();
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
          );
        },
      );
      playerProvider.showMiniPlayer();

      widget.onChanged(sortField, sortDirection);
    }

    String? label = sortFieldOptions[sortField]?.keys.first;
    if (sortField == 'creationTime') {
      label =
          sortDirection == 'asc'
              ? tr().sortField_oldest
              : tr().sortField_newest;
    }

    return TextButton(
      onPressed: showModal,
      child: Row(
        children: [
          Text(label ?? ''),
          Icon(
            sortDirection == 'asc'
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
          ),
        ],
      ),
    );
  }
}

class ModalTitle extends StatelessWidget {
  final String title;

  const ModalTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }
}
