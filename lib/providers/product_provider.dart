import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:lea_store_office/models/produit.dart';
import 'package:lea_store_office/database/hive_service.dart';

class ProductProvider extends ChangeNotifier {
  final Box<Produit> _produitBox = HiveService.produitsBox;
  List<Produit> _produits = [];

  List<Produit> get produits => _produits;

  // ✅ Nouvelle méthode pour recharger tous les produits depuis Hive
  void loadProduits() {
    _produits = _produitBox.values.toList();
    notifyListeners();
  }

  void ajouterProduit(String categorie, double prixUnitaire, int? stock, String? imagePath) {
    final codeProduit = 'PRD-${DateTime.now().millisecondsSinceEpoch}';

    final nouveauProduit = Produit(
      id: const Uuid().v4(),
      codeProduit: codeProduit,
      categorie: categorie,
      prixUnitaire: prixUnitaire,
      stock: stock ?? 0,
      imagePath: imagePath,
    );

    _produitBox.put(nouveauProduit.id, nouveauProduit);
    loadProduits(); // 🔁 Mise à jour de la liste
  }

  void modifierProduit(
      String id,
      String codeProduit,
      String categorie,
      double prixUnitaire,
      String? imagePath,
      ) {
    final produit = _produitBox.get(id);
    if (produit != null) {
      produit.codeProduit = codeProduit;
      produit.categorie = categorie;
      produit.prixUnitaire = prixUnitaire;
      produit.imagePath = imagePath;
      produit.save();
      loadProduits(); // 🔁 Mise à jour
    }
  }

  void supprimerProduit(String id) {
    _produitBox.delete(id);
    loadProduits(); // 🔁 Mise à jour
  }

  List<String> getCategories() {
    return _produits
        .map((p) => p.categorie)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
  }
}
