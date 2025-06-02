import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lea_store_office/database/hive_service.dart';
import 'package:lea_store_office/models/transaction.dart' as t;
import 'package:lea_store_office/models/transaction_item.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_supprimee.dart';

class TransactionProvider extends ChangeNotifier {
  final _transactionBox = HiveService.transactionsBox;
  final _produitBox = HiveService.produitsBox;
  final _clientBox = HiveService.clientsBox;
  List<t.Transaction> _transactions = [];
  List<t.Transaction> get transactions => _transactions;
  final Box<TransactionSupprimee> _transactionSupprimeeBox = Hive.box<TransactionSupprimee>('transactionsSupprimees');
  List<TransactionSupprimee> get transactionsSupprimees => _transactionSupprimeeBox.values.toList();



  TransactionProvider() {
    loadTransactions();
  }


  void loadTransactions() {
    _transactions = _transactionBox.values.toList().cast<t.Transaction>();
    notifyListeners();
  }


  t.Transaction ajouterTransaction({
    required String type,
    String? clientId,
    String? fournisseur,
    required bool isCredit,
    required List<TransactionItem> produits,
    String? note,
    double? versement,
    double? depotUtilise,
  }) {
    final now = DateTime.now();
    final id = const Uuid().v4();

    final total = produits.fold(0.0, (sum, item) => sum + item.sousTotal);
    final client = clientId != null ? _clientBox.get(clientId) : null;

    final newTransaction = t.Transaction(
      id: id,
      type: type,
      clientId: clientId,
      clientNom: client?.nom,
      fournisseur: fournisseur,
      date: now,
      isCredit: isCredit,
      produits: produits,
      note: note,
      total: total,
      versement: versement,
      depotUtilise: depotUtilise,
    );

    _transactionBox.put(newTransaction.id, newTransaction);

    // Mise à jour du stock
    for (var item in produits) {
      final produit = _produitBox.get(item.produitId);
      if (produit != null) {
        if (type == 'vente') {
          produit.stock -= item.quantite;
        } else if (type == 'achat') {
          produit.stock += item.quantite;
        }
        produit.save();
      }
    }
    loadTransactions();
    notifyListeners();
    return newTransaction;
  }



  void supprimerTransaction(String id) {
    final transaction = _transactionBox.get(id);
    if (transaction == null) return;

    // Restaurer le stock
    for (var item in transaction.produits) {
      final produit = _produitBox.get(item.produitId);
      if (produit != null) {
        if (transaction.type == 'vente') {
          produit.stock += item.quantite; // Remet le stock
        } else if (transaction.type == 'achat') {
          produit.stock -= item.quantite; // Retire du stock
        }
        produit.save();
      }
    }

    // Restaurer le solde client si crédit
    if (transaction.type == 'vente' && transaction.isCredit && transaction.clientId != null) {
      final client = _clientBox.get(transaction.clientId);
      if (client != null) {
        client.solde -= transaction.total;
        client.save();
      }
    }

    // Sauvegarder l'historique de la suppression
    final suppression = TransactionSupprimee(
      id: DateTime.now().toIso8601String(),
      dateSuppression: DateTime.now(),
      transactionOriginale: transaction,
    );
    _transactionSupprimeeBox.put(suppression.id, suppression);

    // Supprimer la transaction
    _transactionBox.delete(id);

    // Mettre à jour la liste
    loadTransactions();
    notifyListeners();
  }

}
