import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:lea_store_office/services/json_export_service.dart';
import 'package:lea_store_office/services/google_drive_service.dart';
import 'package:lea_store_office/utils/google_drive_backup_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

void onStart(ServiceInstance service) async {
  final prefs = await SharedPreferences.getInstance();
  final intervalInSeconds = prefs.getInt('backupIntervalInSeconds') ?? 6 * 3600;

  Timer.periodic(Duration(seconds: intervalInSeconds), (timer) async {
    final prefs = await SharedPreferences.getInstance();
    final isLocalEnabled = prefs.getBool('autoBackupEnabled') ?? false;
    final isDriveEnabled = prefs.getBool('autoDriveBackupEnabled') ?? false;

    if (!isLocalEnabled && !isDriveEnabled) {
      debugPrint('⏹️ Backup désactivé, on arrête la tâche');
      timer.cancel();
      return;
    }

    try {
      if (isLocalEnabled) {
        await JsonExportService.exportDataToJson();
        debugPrint('✅ Backup local terminé');
      }

      if (isDriveEnabled && GoogleDriveService.isSignedIn) {
        await GoogleDriveBackupHelper.uploadBackup();
        debugPrint('☁️ Backup Drive terminé');
      }
    } catch (e) {
      debugPrint('❌ Erreur dans la tâche de fond : $e');
    }
  });
}
