import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import '../models/achat.dart';
import '../database/hive_service.dart'; // Ou ton service Hive

class AchatProvider extends ChangeNotifier {
  final _achatBox = HiveService.achatsBox; // À ajouter dans HiveService

  List<Achat> _achats = [];

  List<Achat> get achats => _achats;

  AchatProvider() {
    loadAchats();
  }

  void loadAchats() {
    _achats = _achatBox.values.toList().cast<Achat>();
    notifyListeners();
  }

  void ajouterAchat(String produitId, double prixAchat, int quantite) {
    final achat = Achat(
      id: const Uuid().v4(),
      produitId: produitId,
      prixAchat: prixAchat,
      quantite: quantite,
      date: DateTime.now(),
    );
    _achatBox.put(achat.id, achat);
    _achats.add(achat);
    notifyListeners();
  }

  Achat? dernierAchatPourProduit(String produitId) {
    final achatsProduit = _achats.where((a) => a.produitId == produitId).toList();
    achatsProduit.sort((a, b) => b.date.compareTo(a.date));
    return achatsProduit.isNotEmpty ? achatsProduit.first : null;
  }
}
