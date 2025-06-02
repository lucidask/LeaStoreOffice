import 'package:flutter/material.dart';
import 'package:lea_store_office/providers/client_provider.dart';
import 'package:lea_store_office/providers/depot_provider.dart';
import 'package:lea_store_office/providers/panier_provider.dart';
import 'package:lea_store_office/providers/product_provider.dart';
import 'package:lea_store_office/providers/transaction_provider.dart';
import 'package:lea_store_office/providers/versement_provider.dart';
import 'package:provider/provider.dart';

import 'database/hive_service.dart';
import 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.initHive(); // Initialise Hive avant tout

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()..initialiserClientAnonyme()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => PanierProvider()),
        ChangeNotifierProvider(create: (_) => VersementProvider()),
        ChangeNotifierProvider(create: (_) => DepotProvider()),
      ],

      child: const MyApp(),
    ),
  );
}
