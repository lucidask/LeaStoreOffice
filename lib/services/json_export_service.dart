import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import '../models/produit.dart';
import '../models/client.dart';
import '../models/transaction.dart';
import '../models/achat.dart';
import '../models/depot.dart';
import '../models/transaction_supprimee.dart';
import '../models/versement.dart';

class JsonExportService {
  static Future<String> exportDataToJson() async {
    final dir = await getExternalStorageDirectory();
    final backupDir = Directory('${dir!.path}/backup');

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    final produits = Hive.box<Produit>('produits').values.toList();
    final clients = Hive.box<Client>('clients').values.toList();
    final transactions = Hive.box<Transaction>('transactions').values.toList();
    final achats = Hive.box<Achat>('achats').values.toList();
    final depots = Hive.box<Depot>('depots').values.toList();
    final versements = Hive.box<Versement>('versements').values.toList();
    final transactionsSupprimees = Hive.box<TransactionSupprimee>('transactionsSupprimees').values.toList();

    final data = {
      'produits': await Future.wait(produits.map((p) => _produitToJsonWithImage(p))),
      'clients': clients.map((c) => c.toJson()).toList(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'achats': achats.map((a) => a.toJson()).toList(),
      'depots': depots.map((d) => d.toJson()).toList(),
      'versements': versements.map((v) => v.toJson()).toList(),
      'transactionsSupprimees': transactionsSupprimees.map((t) => t.toJson()).toList(),
    };

    final jsonString = jsonEncode(data);
    final filePath = '${backupDir.path}/backup_${DateTime.now().toIso8601String()}.json';
    final file = File(filePath);
    await file.writeAsString(jsonString);
    return filePath;
  }

  static Future<Map<String, dynamic>> _produitToJsonWithImage(Produit p) async {
    String? base64Image;
    if (p.imagePath != null && File(p.imagePath!).existsSync()) {
      final bytes = await File(p.imagePath!).readAsBytes();
      base64Image = base64Encode(bytes);
    }

    return {
      'id': p.id,
      'codeProduit': p.codeProduit,
      'categorie': p.categorie,
      'prixUnitaire': p.prixUnitaire,
      'stock': p.stock,
      'imageBase64': base64Image,
    };
  }
}
