import 'package:flutter/material.dart';
import '../models/versement.dart';
import '../database/hive_service.dart';
import 'package:uuid/uuid.dart';

class VersementProvider with ChangeNotifier {
  final _versementBox = HiveService.versementsBox;
  List<Versement> _versements = [];

  List<Versement> get versements => _versements;

  // ✅ Recharge la liste depuis Hive
  void loadVersements() {
    _versements = _versementBox.values.toList();
    notifyListeners();
  }

  List<Versement> getVersementsParClient(String clientId) {
    return _versements.where((v) => v.clientId == clientId).toList();
  }

  void ajouterVersement({
    required String clientId,
    required double montant,
  }) {
    final versement = Versement(
      id: const Uuid().v4(),
      clientId: clientId,
      montant: montant,
      date: DateTime.now(),
    );

    _versementBox.put(versement.id, versement);
    loadVersements();
  }

  void supprimerVersement(String id) {
    _versementBox.delete(id);
    loadVersements();
  }

  Versement? getDernierVersementParClient(String clientId) {
    final liste = _versements.where((v) => v.clientId == clientId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return liste.isNotEmpty ? liste.first : null;
  }
}
