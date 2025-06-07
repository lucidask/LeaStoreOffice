import 'dart:async';
import 'package:lea_store_office/services/json_export_service.dart';
import 'package:lea_store_office/services/google_drive_service.dart';
import 'package:lea_store_office/utils/google_drive_backup_helper.dart';
import 'package:lea_store_office/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AutoBackupService {
  static Timer? _timer;

  /// Appelé depuis le widget racine pour démarrer avec accès au contexte
  static void startWithDuration(BuildContext context, Duration duration) {
    _timer?.cancel(); // Annule l'ancien timer

    final settings = Provider.of<SettingsProvider>(context, listen: false);

    _timer = Timer.periodic(duration, (_) async {
      try {
        await JsonExportService.exportDataToJson();
     debugPrint('✅ Sauvegarde automatique locale effectuée');

        if (settings.autoDriveBackupEnabled && GoogleDriveService.isSignedIn) {
          await GoogleDriveBackupHelper.uploadBackup();
          debugPrint('☁️ Sauvegarde automatique vers Google Drive effectuée');
        }
      } catch (e) {
        debugPrint('❌ Erreur pendant la sauvegarde automatique : $e');
      }
    });
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
