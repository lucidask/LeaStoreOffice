import 'package:flutter/material.dart';
import 'package:lea_store_office/providers/achat_provider.dart';
import 'package:lea_store_office/providers/client_provider.dart';
import 'package:lea_store_office/providers/depot_provider.dart';
import 'package:lea_store_office/providers/panier_provider.dart';
import 'package:lea_store_office/providers/product_provider.dart';
import 'package:lea_store_office/providers/settings_provider.dart';
import 'package:lea_store_office/providers/transaction_provider.dart';
import 'package:lea_store_office/providers/versement_provider.dart';
<<<<<<< HEAD
import 'package:lea_store_office/database/hive_service.dart';
=======
import 'package:lea_store_office/services/auto_backup_service.dart';
import 'package:lea_store_office/utils/duration_parser.dart';
>>>>>>> 2283ded628918f9e765790a9a7c2222455f4434a
import 'package:provider/provider.dart';
import 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.initHive();
  final settings = HiveService.settingsBox;
  final bool autoBackupEnabled = settings.get('autoBackupEnabled', defaultValue: false);
  final String rawInterval = settings.get('backupIntervalRaw', defaultValue: '6h');
  if (autoBackupEnabled) {
    final duration = DurationParser.parse(rawInterval);
    AutoBackupService.startWithDuration(duration);
  }
  final isLocked = settings.get('lockHome', defaultValue: false);

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
      ],
      child: MyApp(isLocked: isLocked),
    ),
  );
}

