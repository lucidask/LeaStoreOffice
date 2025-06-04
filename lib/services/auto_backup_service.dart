import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lea_store_office/services/json_export_service.dart';

class AutoBackupService {
  static Timer? _timer;

  /// Démarre la sauvegarde automatique avec une durée personnalisée (ex: heures, minutes, secondes)
  static void startWithDuration(Duration duration) {
    _timer?.cancel(); // Arrêter tout ancien minuteur
    _timer = Timer.periodic(duration, (_) async {
      try {
        await JsonExportService.exportDataToJson();
        debugPrint('✅ Sauvegarde automatique effectuée');
      } catch (e) {
        debugPrint('❌ Erreur lors de la sauvegarde automatique : $e');
      }
    });
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
