import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:lea_store_office/services/background/background_service_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/duration_parser.dart';

class BackgroundServiceInitializer {
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final rawInterval = prefs.getString('backupIntervalRaw') ?? '6h';
    final driveEnabled = prefs.getBool('autoDriveBackupEnabled') ?? false;

    final duration = DurationParser.parse(rawInterval);
    await initializeWith(duration, driveEnabled: driveEnabled);
  }

  static Future<void> initializeWith(Duration interval, {required bool driveEnabled}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('backupIntervalInSeconds', interval.inSeconds);
    await prefs.setBool('autoDriveBackupEnabled', driveEnabled);

    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: false,
        autoStart: true,
        autoStartOnBoot: false,
      ),
      iosConfiguration: IosConfiguration(),
    );

    await service.startService();
  }

  static Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke('stopService');
  }
}
