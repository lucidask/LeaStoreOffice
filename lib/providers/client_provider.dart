import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:lea_store_office/models/client.dart';
import 'package:lea_store_office/database/hive_service.dart';

class ClientProvider extends ChangeNotifier {
  final Box<Client> _clientBox = HiveService.clientsBox;

  List<Client> get clients => _clientBox.values.toList();

  Client ajouterClient(String nom, String? telephone, String? imagePath) {
    final nouveauClient = Client(
      id: const Uuid().v4(),
      nom: nom,
      telephone: telephone,
      imagePath: imagePath,
      solde: 0,
    );

    _clientBox.put(nouveauClient.id, nouveauClient);
    notifyListeners();
    return nouveauClient;
  }

  void modifierClient(String id, String nom, String? telephone, String? imagePath) {
    final client = _clientBox.get(id);
    if (client != null) {
      client.nom = nom;
      client.telephone = telephone;
      client.imagePath = imagePath;
      client.save();
      notifyListeners();
    }
  }

  void supprimerClient(String id) {
    _clientBox.delete(id);
    notifyListeners();
  }

  void initialiserClientAnonyme() {
    final anonymeExiste = _clientBox.values.any((c) => c.nom == 'Anonyme');
    if (!anonymeExiste) {
      final clientAnonyme = Client(
        id: const Uuid().v4(),
        nom: 'Anonyme',
        telephone: null,
        imagePath: null,
        solde: 0,
      );
      _clientBox.put(clientAnonyme.id, clientAnonyme);
      notifyListeners();
    }
  }


}
