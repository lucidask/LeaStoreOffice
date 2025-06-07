import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsProvider extends ChangeNotifier {
  bool lockHome = false;
  String password = '';
  bool autoBackupEnabled = false;
  String backupIntervalRaw = '6h';
<<<<<<< HEAD
  bool autoDriveBackupEnabled = false;
=======

>>>>>>> 2283ded628918f9e765790a9a7c2222455f4434a

  final Box settingsBox = Hive.box('settings');

  SettingsProvider() {
    lockHome = settingsBox.get('lockHome', defaultValue: false);
    password = settingsBox.get('password', defaultValue: '');
    autoBackupEnabled = settingsBox.get('autoBackupEnabled', defaultValue: false);
    backupIntervalRaw = settingsBox.get('backupIntervalRaw', defaultValue: '6h').toString();
<<<<<<< HEAD
    autoDriveBackupEnabled = settingsBox.get('autoDriveBackupEnabled', defaultValue: false);
=======
>>>>>>> 2283ded628918f9e765790a9a7c2222455f4434a
  }

  void toggleLock(bool value) {
    lockHome = value;
    settingsBox.put('lockHome', value);
    notifyListeners();
  }

  void setPassword(String newPassword) {
    password = newPassword;
    settingsBox.put('password', newPassword);
    notifyListeners();
  }

  void setAutoBackupEnabled(bool value) {
    autoBackupEnabled = value;
    settingsBox.put('autoBackupEnabled', value);
    notifyListeners();
  }

  void setBackupIntervalRaw(String raw) {
    backupIntervalRaw = raw;
    settingsBox.put('backupIntervalRaw', raw);
    notifyListeners();
  }

<<<<<<< HEAD
  void setAutoDriveBackupEnabled(bool value) {
    autoDriveBackupEnabled = value;
    settingsBox.put('autoDriveBackupEnabled', value);
    notifyListeners();
  }


=======
>>>>>>> 2283ded628918f9e765790a9a7c2222455f4434a
}
