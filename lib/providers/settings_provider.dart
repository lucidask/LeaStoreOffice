import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsProvider extends ChangeNotifier {
  bool lockHome = false;
  String password = '';

  final Box settingsBox = Hive.box('settings');

  SettingsProvider() {
    lockHome = settingsBox.get('lockHome', defaultValue: false);
    password = settingsBox.get('password', defaultValue: '');
  }

  void toggleLock(bool value) {
    lockHome = value;
    settingsBox.put('lockHome', value);
    notifyListeners();
  }

  void setPassword(String newPassword) {
    password = newPassword;
    settingsBox.put('password', newPassword); // 📌 Peut être hashé si besoin
    notifyListeners();
  }
}
