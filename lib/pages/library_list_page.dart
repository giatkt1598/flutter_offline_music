import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/create_edit_library_dialog.dart';
import 'package:flutter_offline_music/components/library_list_item.dart';
import 'package:flutter_offline_music/components/no_data.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
import 'package:flutter_offline_music/models/library.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:flutter_offline_music/providers/tab_provider.dart';
import 'package:flutter_offline_music/services/library_service.dart';
import 'package:provider/provider.dart';

class LibraryListPage extends StatefulWidget {
  const LibraryListPage({super.key});

  @override
  State<LibraryListPage> createState() => _LibraryListPageState();
}

class _LibraryListPageState extends State<LibraryListPage>
    with TabProviderListenerMixin, AutomaticKeepAliveClientMixin {
  List<Library> libraries = [];
  final libraryService = LibraryService();

  Future<void> fetchData() async {
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
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    newLib() {
      showDialogCreateUpdateLibrary(
        context,
        whenDone: (newLibId) {
          fetchData();
        },
      );
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
                    tr().nLibraries(libraries.length),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(child: Container()),
                IconButton(onPressed: newLib, icon: Icon(Icons.library_add)),
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
                      onRefresh: fetchData,
                    ),
                  );
                },
              ),
            )
          // Expanded(
          //   child: SingleChildScrollView(
          //     child: Padding(
          //       padding: const EdgeInsets.only(
          //         left: 16,
          //         right: 16,
          //         bottom: 90,
          //       ),
          //       child: Column(
          //         children: [
          //           StaggeredGrid.count(
          //             crossAxisCount: 2,
          //             crossAxisSpacing: 16,
          //             mainAxisSpacing: 16,
          //             children: [
          //               for (var lib in libraries)
          //                 LibraryCardItem(library: lib, onRefresh: fetchData),
          //             ],
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 200),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 28),
                      NoData(title: tr().noLibraries),
                      SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: newLib,
                        child: Text(tr().createNew),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void onTabActive() {
    fetchData();
  }

  @override
  void didChangeDependencies() {
    context.watch<SettingProvider>().appSetting.languageCode;
    super.didChangeDependencies();
  }

  @override
  bool get wantKeepAlive => true;
}
