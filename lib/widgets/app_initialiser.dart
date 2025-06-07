import 'package:flutter/material.dart';
import 'package:lea_store_office/services/auto_backup_service.dart';
import 'package:lea_store_office/utils/duration_parser.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class AppInitializer {
  static void run(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    if (settings.autoBackupEnabled) {
      final duration = DurationParser.parse(settings.backupIntervalRaw);
      AutoBackupService.startWithDuration(context, duration);
    }
  }
}
