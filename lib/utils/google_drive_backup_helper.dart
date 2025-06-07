import 'dart:io';
import 'package:lea_store_office/services/json_export_service.dart';
import 'package:lea_store_office/services/google_drive_service.dart';

class GoogleDriveBackupHelper {
  static Future<void> uploadBackup() async {
    // Génére le vrai backup avec Hive (et image base64)
    final filePath = await JsonExportService.exportDataToJson();
    final file = File(filePath);

    if (!file.existsSync()) throw Exception("Fichier JSON introuvable.");

    await GoogleDriveService.uploadFileToDrive(file);
  }
}
