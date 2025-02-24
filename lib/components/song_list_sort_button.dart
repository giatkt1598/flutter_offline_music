import 'package:flutter/material.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/services/music_service.dart';
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
  final MusicService _musicService = MusicService();
  final Map<String, Map<String, IconData>> sortFieldOptions = {
    "title": {"Tên bài hát": Icons.music_note_rounded},
    "artist": {"Tên nghệ sĩ": Icons.person_outline_outlined},
    "lengthInSecond": {"Độ dài": Icons.swap_horiz},
    "creationTime": {"Thời gian tạo": Icons.calendar_today},
  };

  String sortField = '';
  String sortDirection = '';
  @override
  void initState() {
    sortField = widget.initialSortField;
    sortDirection = widget.initialSortDirection;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    showModal() async {
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
                  height: 500,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ModalTitle(title: 'Sắp xếp theo'),
                      for (var item in sortFieldOptions.entries)
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 0),
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
                      Divider(),
                      SizedBox(height: 16),
                      ModalTitle(title: 'Theo thứ tự'),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 0),
                        title: Text('Tăng dần (A ⇀ Z)'),
                        leading: Icon(Icons.arrow_upward_rounded),
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
                        title: Text('Giảm dần (Z ⇀ A)'),
                        leading: Icon(Icons.arrow_downward_rounded),
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

      widget.onChanged(sortField, sortDirection);
    }

    String? label = sortFieldOptions[sortField]?.keys.first;
    if (sortField == 'creationTime') {
      label = sortDirection == 'asc' ? 'Cũ nhất' : 'Mới nhất';
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
