import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import '../models/produit.dart';
import '../models/client.dart';
import '../models/transaction.dart';
import '../models/achat.dart';
import '../models/depot.dart';
import '../models/transaction_supprimee.dart';
import '../models/versement.dart';

class JsonImportService {
  static Future<void> importFromFile(File file, {required String mode}) async {
    final content = await file.readAsString();
    final data = jsonDecode(content);

    await Produit.initImageDirectory();
    await Client.initImageDirectory();

    // === PRODUITS ===
    final produitsBox = Hive.box<Produit>('produits');
    _handleImport<Produit>(
      box: produitsBox,
      dataList: data['produits'],
      mode: mode,
      mergeLogic: (old, fresh) => Produit(
        id: old.id,
        codeProduit: old.codeProduit,
        categorie: old.categorie,
        prixUnitaire: fresh.prixUnitaire,
        stock: old.stock + fresh.stock,
        imagePath: old.imagePath ?? fresh.imagePath,
      ),
      fromJson: (item) => Produit.fromJson(item),
    );

    // === CLIENTS ===
    final clientsBox = Hive.box<Client>('clients');
    _handleImport<Client>(
      box: clientsBox,
      dataList: data['clients'],
      mode: mode,
      mergeLogic: (old, fresh) => Client(
        id: old.id,
        nom: old.nom,
        telephone: old.telephone ?? fresh.telephone,
        imagePath: old.imagePath ?? fresh.imagePath,
        solde: old.solde + fresh.solde,
        depot: (old.depot ?? 0) + (fresh.depot ?? 0),
      ),
      fromJson: (item) => Client.fromJson(item),
    );

    // === AUTRES ===
    _simpleImport<Transaction>('transactions', data, mode, Transaction.fromJson);
    _simpleImport<Achat>('achats', data, mode, Achat.fromJson);
    _simpleImport<Depot>('depots', data, mode, Depot.fromJson);
    _simpleImport<Versement>('versements', data, mode, Versement.fromJson);
    _simpleImport<TransactionSupprimee>('transactionsSupprimees', data, mode, TransactionSupprimee.fromJson);
  }

  static void _handleImport<T>({
    required Box<T> box,
    required List? dataList,
    required String mode,
    required T Function(T old, T fresh) mergeLogic,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    if (dataList == null) return;
    if (mode == 'erase') box.clear();

    for (var item in dataList) {
      final obj = fromJson(item);
      final id = (obj as dynamic).id;
      if (mode == 'merge' && box.containsKey(id)) {
        final old = box.get(id) as T;
        final merged = mergeLogic(old, obj);
        box.put(id, merged);
      } else {
        box.put(id, obj);
      }
    }
  }

  static void _simpleImport<T>(
      String key,
      Map data,
      String mode,
      T Function(Map<String, dynamic>) fromJson,
      ) {
    final box = Hive.box<T>(key);
    final items = data[key];
    if (items == null) return;

    if (mode == 'erase') box.clear();
    for (var item in items) {
      final obj = fromJson(item);
      final id = (obj as dynamic).id;
      box.put(id, obj);
    }
  }
}
