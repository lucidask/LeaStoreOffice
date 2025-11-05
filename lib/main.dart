import 'package:flutter/material.dart';
import 'package:lea_store_office/providers/achat_provider.dart';
import 'package:lea_store_office/providers/client_provider.dart';
import 'package:lea_store_office/providers/depot_provider.dart';
import 'package:lea_store_office/providers/panier_provider.dart';
import 'package:lea_store_office/providers/product_provider.dart';
import 'package:lea_store_office/providers/settings_provider.dart';
import 'package:lea_store_office/providers/theme_provider.dart';
import 'package:lea_store_office/providers/transaction_provider.dart';
import 'package:lea_store_office/providers/versement_provider.dart';
import 'package:lea_store_office/database/hive_service.dart';
import 'package:lea_store_office/services/background/background_service_initializer.dart';
import 'package:lea_store_office/utils/duration_parser.dart';
import 'package:provider/provider.dart';
import 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.initHive();
  final settings = HiveService.settingsBox;
  final isLocked = settings.get('lockHome', defaultValue: false);
  final rawInterval = settings.get('backupIntervalRaw', defaultValue: '6h');
  final driveEnabled = settings.get('autoDriveBackupEnabled', defaultValue: false);
  final localEnabled = settings.get('autoBackupEnabled', defaultValue: false);
  final duration = DurationParser.parse(rawInterval);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          final p = ProductProvider();
          p.loadProduits();
          return p;
        }),
        ChangeNotifierProvider(create: (_) {
          final c = ClientProvider();
          c.initialiserClientAnonyme();
          c.loadClients();
          return c;
        }),
        ChangeNotifierProvider(create: (_) {
          final t = TransactionProvider();
          t.loadTransactions();
          return t;
        }),
        ChangeNotifierProvider(create: (_) => PanierProvider()),
        ChangeNotifierProvider(create: (_) {
          final v = VersementProvider();
          v.loadVersements();
          return v;
        }),
        ChangeNotifierProvider(create: (_) {
          final d = DepotProvider();
          d.loadDepots();
          return d;
        }),
        ChangeNotifierProvider(create: (_) {
          final a = AchatProvider();
          a.loadAchats();
          return a;
        }),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(isLocked: isLocked),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (localEnabled || driveEnabled) {
      BackgroundServiceInitializer.initializeWith(duration, driveEnabled: driveEnabled);
    }
  });
}
