import 'package:flutter/material.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';

Future<bool?> showConfirmDialog({
  required BuildContext context,
  String? title,
  String? message,
  String? cancelText,
  String? okText,
}) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title ?? tr().confirmDialog_defaultTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: Text(
          message ?? tr().confirmDialog_defaultMessage,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Hủy
            },
            child: Text(cancelText ?? tr().formAction_cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Xác nhận
            },
            child: Text(okText ?? tr().formAction_confirm),
          ),
        ],
      );
    },
  );
}
