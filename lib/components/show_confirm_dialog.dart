import 'package:flutter/material.dart';

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
        title: Text(title ?? "Xác nhận"),
        content: Text(message ?? "Bạn chắc chắn?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Hủy
            },
            child: Text(cancelText ?? "Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Xác nhận
            },
            child: Text(okText ?? "Xác nhận"),
          ),
        ],
      );
    },
  );
}
