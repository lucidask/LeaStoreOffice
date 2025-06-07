import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/depot.dart';
import '../database/hive_service.dart';

class DepotProvider with ChangeNotifier {
  final _depotBox = HiveService.depotsBox;
  List<Depot> _depots = [];

  List<Depot> get depots => _depots;

  // ✅ Nouvelle méthode pour recharger tous les dépôts depuis Hive
  void loadDepots() {
    _depots = _depotBox.values.toList();
    notifyListeners();
  }

  List<Depot> getDepotsParClient(String clientId) {
    return _depots.where((d) => d.clientId == clientId).toList();
  }

  void ajouterDepot({
    required String clientId,
    required double montant,
  }) {
    final depot = Depot(
      id: const Uuid().v4(),
      clientId: clientId,
      montant: montant,
      date: DateTime.now(),
    );

    _depotBox.put(depot.id, depot);
    loadDepots(); // 🔄 Mise à jour automatique
  }

  void supprimerDepot(String id) {
    _depotBox.delete(id);
    loadDepots(); // 🔄 Mise à jour automatique
  }
}
