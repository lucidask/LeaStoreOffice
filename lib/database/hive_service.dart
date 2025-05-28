import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/produit.dart';
import '../models/client.dart';
import '../models/transaction.dart';
import '../models/transaction_item.dart';

class HiveService {
  static Future<void> initHive() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocDir.path);

    // Register adapters
    Hive.registerAdapter(ProduitAdapter());
    Hive.registerAdapter(ClientAdapter());
    Hive.registerAdapter(TransactionItemAdapter());
    Hive.registerAdapter(TransactionAdapter());

    // Open boxes
    await Hive.openBox<Produit>('produits');
    await Hive.openBox<Client>('clients');
    await Hive.openBox<Transaction>('transactions');
  }

  // Boxes getters
  static Box<Produit> get produitsBox => Hive.box<Produit>('produits');
  static Box<Client> get clientsBox => Hive.box<Client>('clients');
  static Box<Transaction> get transactionsBox => Hive.box<Transaction>('transactions');
}
