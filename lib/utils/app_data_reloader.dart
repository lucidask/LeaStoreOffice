import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/client_provider.dart';
import '../providers/product_provider.dart';
import '../providers/achat_provider.dart';
import '../providers/depot_provider.dart';
import '../providers/versement_provider.dart';
import '../providers/transaction_provider.dart';

class AppDataReloader {
  static void refreshAll(BuildContext context) {
    Provider.of<ClientProvider>(context, listen: false).loadClients();
    Provider.of<ProductProvider>(context, listen: false).loadProduits();
    Provider.of<AchatProvider>(context, listen: false).loadAchats();
    Provider.of<DepotProvider>(context, listen: false).loadDepots();
    Provider.of<VersementProvider>(context, listen: false).loadVersements();
    Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
  }
}
