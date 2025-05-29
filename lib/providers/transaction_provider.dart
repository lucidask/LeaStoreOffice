import 'package:flutter/material.dart';
import 'package:lea_store_office/database/hive_service.dart';
import 'package:lea_store_office/models/transaction.dart' as t;
import 'package:lea_store_office/models/transaction_item.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class TransactionProvider extends ChangeNotifier {
  final _transactionBox = HiveService.transactionsBox;
  final _produitBox = HiveService.produitsBox;
  final _clientBox = HiveService.clientsBox;

  List<t.Transaction> _transactions = [];

  List<t.Transaction> get transactions => _transactions;

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
  }) {
    final now = DateTime.now();
    final id = const Uuid().v4(); // 🔥 Génération d'un ID unique et propre

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

    // Mise à jour du solde client si crédit
    if (clientId != null && isCredit) {
      final client = _clientBox.get(clientId);
      if (client != null) {
        client.solde += total;
        client.save();
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

    // Supprimer la transaction
    _transactionBox.delete(id);
    loadTransactions();
    notifyListeners();
  }

  void modifierTransaction({
    required String id,
    required String type,
    String? clientId,
    String? fournisseur,
    required bool isCredit,
    required List<TransactionItem> produits,
  }) {
    final ancienneTransaction = _transactionBox.get(id);
    if (ancienneTransaction == null) return;

    // 🛠️ 1️⃣ Restaurer l'ancienne transaction
    for (var item in ancienneTransaction.produits) {
      final produit = _produitBox.get(item.produitId);
      if (produit != null) {
        if (ancienneTransaction.type == 'vente') {
          produit.stock += item.quantite; // Remet le stock
        } else if (ancienneTransaction.type == 'achat') {
          produit.stock -= item.quantite; // Retire du stock
        }
        produit.save();
      }
    }

    // Restaurer le solde client si crédit
    if (ancienneTransaction.type == 'vente' && ancienneTransaction.isCredit && ancienneTransaction.clientId != null) {
      final client = _clientBox.get(ancienneTransaction.clientId);
      if (client != null) {
        client.solde -= ancienneTransaction.total;
        client.save();
      }
    }

    // 🛠️ 2️⃣ Calculer le nouveau total
    final nouveauTotal = produits.fold(0.0, (sum, item) => sum + item.sousTotal);

    // 🛠️ 3️⃣ Mettre à jour la transaction
    ancienneTransaction.clientId = clientId;
    ancienneTransaction.fournisseur = fournisseur;
    ancienneTransaction.isCredit = isCredit;
    ancienneTransaction.produits = produits;
    ancienneTransaction.total = nouveauTotal;
    ancienneTransaction.date = DateTime.now();
    ancienneTransaction.save();

    // 🛠️ 4️⃣ Appliquer la nouvelle transaction
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

    // Mettre à jour le solde client si vente à crédit
    if (type == 'vente' && isCredit && clientId != null) {
      final client = _clientBox.get(clientId);
      if (client != null) {
        client.solde += nouveauTotal;
        client.save();
      }
    }
    loadTransactions();
    notifyListeners();
  }


}
