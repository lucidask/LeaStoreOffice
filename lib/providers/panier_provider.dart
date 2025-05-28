import 'package:flutter/material.dart';
import '../models/transaction_item.dart';

class PanierProvider extends ChangeNotifier {
  final List<TransactionItem> _items = [];
  final Map<String, int> _stockTemp = {};

  List<TransactionItem> get items => _items;
  Map<String, int> get stockTemp => _stockTemp;

  void addItem(TransactionItem item, int stockActuel) {
    final existing = _items.firstWhere(
          (e) => e.produitId == item.produitId,
      orElse: () => TransactionItem(
        produitId: '',
        produitNom: '',
        produitImagePath: '',
        quantite: 0,
        prixUnitaire: 0,
      ),
    );

    if (existing.produitId != '') {
      existing.quantite += item.quantite;
      _stockTemp[item.produitId] = stockActuel - existing.quantite;
    } else {
      _items.add(item);
      _stockTemp[item.produitId] = stockActuel - item.quantite;
    }
    notifyListeners();
  }

  void increment(TransactionItem item, int stockActuel) {
    if ((_stockTemp[item.produitId] ?? stockActuel) > 0) {
      item.quantite++;
      _stockTemp[item.produitId] = (_stockTemp[item.produitId] ?? stockActuel) - 1;
      notifyListeners();
    }
  }

  void decrement(TransactionItem item, int stockActuel) {
    if (item.quantite > 1) {
      item.quantite--;
      _stockTemp[item.produitId] = (_stockTemp[item.produitId] ?? stockActuel) + 1;
    } else {
      _items.remove(item);
      _stockTemp[item.produitId] = (_stockTemp[item.produitId] ?? stockActuel) + 1;
    }
    notifyListeners();
  }

  void clearPanier() {
    _items.clear();
    _stockTemp.clear();
    notifyListeners();
  }
}
