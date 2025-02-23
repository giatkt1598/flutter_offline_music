import 'package:flutter/material.dart';

class SettingProvider extends ChangeNotifier {
  bool isLoading = true;

  setLoading(bool loading) {
    isLoading = loading;
  }
}
