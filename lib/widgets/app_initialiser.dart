import 'package:flutter/material.dart';
import 'package:lea_store_office/services/auto_backup_service.dart';
import 'package:lea_store_office/utils/duration_parser.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/google_drive_service.dart';
import '../services/json_export_service.dart';

class AppInitializer {
  static void run(BuildContext context) {
    Provider.of<TransactionProvider>(context, listen: false)
        .supprimerTransactionsSupprimeesAnciennes();
    Future.microtask(() => JsonExportService.supprimerAnciensBackups());
    Future.microtask(() => GoogleDriveService.supprimerBackupsDriveAnciens());

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (settings.autoBackupEnabled) {
      final duration = DurationParser.parse(settings.backupIntervalRaw);
      AutoBackupService.startWithDuration(context, duration);
    }
  }
}
