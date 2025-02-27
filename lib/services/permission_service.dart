import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestStoragePermissionAsync() async {
    var status = await Permission.manageExternalStorage.request();
    return status.isGranted;
  }
}
