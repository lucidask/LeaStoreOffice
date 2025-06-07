import 'dart:async';
<<<<<<< HEAD
import 'package:lea_store_office/services/json_export_service.dart';
import 'package:lea_store_office/services/google_drive_service.dart';
import 'package:lea_store_office/utils/google_drive_backup_helper.dart';
import 'package:lea_store_office/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
=======
import 'package:flutter/material.dart';
import 'package:lea_store_office/services/json_export_service.dart';
>>>>>>> 2283ded628918f9e765790a9a7c2222455f4434a

class AutoBackupService {
  static Timer? _timer;

<<<<<<< HEAD
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
=======
  /// Démarre la sauvegarde automatique avec une durée personnalisée (ex: heures, minutes, secondes)
  static void startWithDuration(Duration duration) {
    _timer?.cancel(); // Arrêter tout ancien minuteur
    _timer = Timer.periodic(duration, (_) async {
      try {
        await JsonExportService.exportDataToJson();
        debugPrint('✅ Sauvegarde automatique effectuée');
      } catch (e) {
        debugPrint('❌ Erreur lors de la sauvegarde automatique : $e');
>>>>>>> 2283ded628918f9e765790a9a7c2222455f4434a
      }
    });
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
