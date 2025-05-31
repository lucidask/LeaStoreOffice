import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/versement.dart';
import '../database/hive_service.dart';
import 'package:uuid/uuid.dart';

class VersementProvider with ChangeNotifier {
  final _versementBox = HiveService.versementsBox;

  List<Versement> get versements => _versementBox.values.toList();

  List<Versement> getVersementsParClient(String clientId) {
    return versements.where((v) => v.clientId == clientId).toList();
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
    notifyListeners();
  }

  void supprimerVersement(String id) {
    _versementBox.delete(id);
    notifyListeners();
  }

}
