import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/app_button.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestStoragePermissionAsync(BuildContext context) async {
    if (!await Permission.manageExternalStorage.isDenied) {
      return true;
    }

    final isConfirm = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    tr().requestStoragePermissionTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                tr().requestStoragePermissionMessage,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Image.asset('assets/access_external_storage.jpg'),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      type: AppButtonType.primary,
                      child: Text(tr().allowTitle),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14),
            ],
          ),
        );
      },
    );

    if (isConfirm == true) {
      var status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    }

    return await Permission.manageExternalStorage.isGranted;
  }

  Future<bool?> requestNotificationPermissionAsync(BuildContext context) async {
    if (!await Permission.notification.status.isPermanentlyDenied &&
        !await Permission.notification.isGranted) {
      final isConfirm = await showModalBottomSheet<bool>(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      tr().requestNotificationPermissionTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  tr().requestNotificationPermissionMessage,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Image.asset('assets/player_notification.png'),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        type: AppButtonType.primary,
                        child: Text(tr().allowTitle),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14),
              ],
            ),
          );
        },
      );

      if (isConfirm == true) {
        await Permission.notification.request();
      }
    }
    return await Permission.notification.isGranted;
  }
}
