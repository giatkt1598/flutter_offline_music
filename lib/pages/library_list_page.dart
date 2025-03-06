import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/library_list_item.dart';
import 'package:flutter_offline_music/components/no_data.dart';
import 'package:flutter_offline_music/models/library.dart';
import 'package:flutter_offline_music/pages/music_select_to_library_page.dart';
import 'package:flutter_offline_music/services/library_service.dart';

class LibraryListPage extends StatefulWidget {
  const LibraryListPage({super.key});

  @override
  State<LibraryListPage> createState() => _LibraryListPageState();
}

class _LibraryListPageState extends State<LibraryListPage> {
  List<Library> libraries = [];
  final libraryService = LibraryService();

  Future<void> loadLibraries() async {
    var list = await libraryService.getListAsync(
      orderBy: 'lastModificationTime desc',
    );
    if (!mounted) return;
    setState(() {
      libraries = list;
    });
  }

  @override
  void initState() {
    loadLibraries();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    addNewLibrary() async {
      var newLib = await showDialog<Library>(
        context: context,
        builder: (context) => FormCreateLibrary(),
      );

      if (newLib == null) return;
      int newLibId = await libraryService.insertAsync(newLib);
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder:
                  (context) => MusicSelectToLibraryPage(libraryId: newLibId),
            ),
          )
          .then((_) {
            loadLibraries();
          });
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    '${libraries.length} thư viện',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(child: Container()),
                IconButton(
                  onPressed: addNewLibrary,
                  icon: Icon(Icons.library_add),
                ),
                IconButton(onPressed: null, icon: Icon(Icons.more_vert)),
              ],
            ),
          ),
          if (libraries.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: libraries.length + 1,
                itemBuilder: (context, index) {
                  if (libraries.length == index) {
                    return SizedBox(height: 90);
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: LibraryListItem(
                      library: libraries[index],
                      onRefresh: loadLibraries,
                    ),
                  );
                },
              ),
            )
          else
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        NoData(title: 'Chưa có thư viện nào!'),
                        SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: addNewLibrary,
                          child: Text('Tạo mới'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FormCreateLibrary extends StatefulWidget {
  const FormCreateLibrary({super.key});

  @override
  State<FormCreateLibrary> createState() => _FormCreateLibraryState();
}

class _FormCreateLibraryState extends State<FormCreateLibrary> {
  String? inputVal;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Hủy'),
        ),
        ElevatedButton(
          onPressed:
              inputVal?.isNotEmpty == true
                  ? () {
                    Navigator.of(context).pop(
                      Library(
                        id: 0,
                        title: inputVal!,
                        creationTime: DateTime.now(),
                      ),
                    );
                  }
                  : null,
          child: Text('Xác nhận'),
        ),
      ],
      title: Text(
        'Tạo thư viện',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      content: SizedBox(
        height: 80,
        width: MediaQuery.of(context).size.width,
        child: Form(
          child: Column(
            children: [
              SizedBox(
                height: 60,
                child: TextFormField(
                  onChanged: (value) {
                    setState(() {
                      inputVal = value;
                    });
                  },
                  autofocus: true,
                  decoration: InputDecoration(
                    label: Text('Tên thư viện'),
                    border: UnderlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 0,
                    ),
                  ),

                  maxLength: 50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
