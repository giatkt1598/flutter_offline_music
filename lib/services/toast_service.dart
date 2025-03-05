import 'package:flutter/material.dart';
import 'package:flutter_offline_music/shared/shared_data.dart';
import 'package:toastification/toastification.dart';

class ToastService {
  ToastService._();

  static void showSuccess(String message, {Duration? duration}) {
    show(
      message: message,
      type: ToastificationType.success,
      duration: duration,
    );
  }

  static void showError(String message, {Duration? duration}) {
    show(message: message, type: ToastificationType.error, duration: duration);
  }

  static void show({
    required String message,
    Duration? duration,
    ToastificationType? type,
  }) {
    final context = SharedData.rootContext;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    toastification.showCustom(
      context: context, // optional if you use ToastificationWrapper
      autoCloseDuration: duration ?? const Duration(seconds: 3),
      animationDuration: Duration(milliseconds: 300),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      alignment: Alignment.topCenter,
      builder: (BuildContext context, ToastificationItem holder) {
        return GestureDetector(
          onTap: () {
            toastification.dismiss(holder);
          },
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color.lerp(
                        Theme.of(context).cardColor,
                        isDarkMode ? Colors.white : Colors.black,
                        isDarkMode ? 0.1 : 0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.1),
                          blurRadius: 5,
                          spreadRadius: 2,
                          offset: Offset.zero,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 32,
                    ),
                    child: IconTheme(
                      data: IconThemeData(size: 16),
                      child: Row(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (type == ToastificationType.success)
                            Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                            ),
                          if (type == ToastificationType.error)
                            Icon(Icons.error_outline, color: Colors.red),
                          if (type == ToastificationType.info)
                            Icon(Icons.info_outline, color: Colors.blue),
                          if (type == ToastificationType.warning)
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.yellow,
                            ),
                          Flexible(
                            child: Text(
                              message,
                              softWrap: true,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
