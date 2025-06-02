import 'package:hive_flutter/hive_flutter.dart';
import 'package:lea_store_office/models/depot.dart';
import 'package:path_provider/path_provider.dart';
import '../models/produit.dart';
import '../models/client.dart';
import '../models/transaction.dart';
import '../models/transaction_item.dart';
import '../models/transaction_supprimee.dart';
import '../models/versement.dart';

class HiveService {
  static Future<void> initHive() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocDir.path);

    // Register adapters
    Hive.registerAdapter(ProduitAdapter());
    Hive.registerAdapter(ClientAdapter());
    Hive.registerAdapter(TransactionItemAdapter());
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(TransactionSupprimeeAdapter());
    Hive.registerAdapter(VersementAdapter());
    Hive.registerAdapter(DepotAdapter());


    // Open boxes
    await Hive.openBox<Produit>('produits');
    await Hive.openBox<Client>('clients');
    await Hive.openBox<Transaction>('transactions');
    await Hive.openBox<TransactionSupprimee>('transactionsSupprimees');
    await Hive.openBox<Versement>('versements');
    await Hive.openBox<Depot>('depots');

  }

  // Boxes getters
  static Box<Produit> get produitsBox => Hive.box<Produit>('produits');
  static Box<Client> get clientsBox => Hive.box<Client>('clients');
  static Box<Transaction> get transactionsBox => Hive.box<Transaction>('transactions');
  static Box<TransactionSupprimee> get transactionsSupprimeesBox => Hive.box<TransactionSupprimee>('transactionsSupprimees');
  static Box<Versement> get versementsBox => Hive.box<Versement>('versements');
  static Box<Depot> get depotsBox => Hive.box<Depot>('depots');

}
