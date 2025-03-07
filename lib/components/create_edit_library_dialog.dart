import 'package:flutter/material.dart';
import 'package:flutter_offline_music/models/library.dart';
import 'package:flutter_offline_music/pages/music_select_to_library_page.dart';
import 'package:flutter_offline_music/services/library_service.dart';
import 'package:flutter_offline_music/services/toast_service.dart';

Future<void> showDialogCreateUpdateLibrary(
  BuildContext context, {
  Function(int newLibId)? whenDone,
  int? libraryIdForUpdate,
}) async {
  var libraryResult = await showDialog<Library>(
    context: context,
    builder:
        (context) => CreateEditLibraryDialog(libraryId: libraryIdForUpdate),
  );
  if (libraryResult == null) {
    return;
  }
  returnFunc() {
    if (whenDone != null) whenDone(libraryResult.id);
  }

  if (libraryIdForUpdate != null) {
    returnFunc();
  } else {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder:
                (context) =>
                    MusicSelectToLibraryPage(libraryId: libraryResult.id),
          ),
        )
        .then((_) {
          returnFunc();
        });
  }
}

class CreateEditLibraryDialog extends StatefulWidget {
  const CreateEditLibraryDialog({super.key, this.libraryId});

  final int? libraryId;
  @override
  State<CreateEditLibraryDialog> createState() =>
      _CreateEditLibraryDialogState();
}

class _CreateEditLibraryDialogState extends State<CreateEditLibraryDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final _libraryService = LibraryService();
  late Library library;
  List<Library> allLibraries = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ToastService.showError('Vui lòng kiểm tra lại thông tin');
      return;
    }

    library.title = _titleController.text;
    if (widget.libraryId == null) {
      library.creationTime = DateTime.now();
      await _libraryService.insertAsync(library) > 0;
    } else {
      library.lastModificationTime = DateTime.now();
      await _libraryService.updateAsync(library) > 0;
    }
    Navigator.of(context).pop<Library>(library);
  }

  Future<void> fetchData() async {
    var libs = await _libraryService.getListAsync();
    setState(() {
      library = libs.firstWhere(
        (x) => x.id == widget.libraryId,
        orElse: () => Library(id: 0, title: '', creationTime: DateTime.now()),
      );
      allLibraries = libs;
      _titleController.text = library.title;
    });
  }

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
        ElevatedButton(onPressed: _submitForm, child: Text('Xác nhận')),
      ],
      title: Text(
        widget.libraryId == null ? 'Tạo thư viện' : 'Cập nhật thư viện',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      content: SizedBox(
        height: 80,
        width: MediaQuery.of(context).size.width,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              SizedBox(
                height: 60,
                child: TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Tên không được để trống";
                    }

                    bool isExistsTitle = allLibraries
                        .where((x) => x.id != widget.libraryId)
                        .any(
                          (x) => x.title.toLowerCase() == value.toLowerCase(),
                        );
                    if (isExistsTitle) return 'Tên đã tồn tại';
                    return null;
                  },
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
