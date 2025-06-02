import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/depot.dart';
import '../database/hive_service.dart';

class DepotProvider with ChangeNotifier {
  final _depotBox = HiveService.depotsBox;

  List<Depot> get depots => _depotBox.values.toList();

  List<Depot> getDepotsParClient(String clientId) {
    return depots.where((d) => d.clientId == clientId).toList();
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
    notifyListeners();
  }

  void supprimerDepot(String id) {
    _depotBox.delete(id);
    notifyListeners();
  }
}
