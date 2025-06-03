import 'package:hive/hive.dart';

part 'achat.g.dart'; // Nécessaire pour Hive

@HiveType(typeId: 7)
class Achat extends HiveObject {
  @HiveField(0)
  String id; // UUID

  @HiveField(1)
  String produitId; // Lien vers Produit

  @HiveField(2)
  double prixAchat; // Prix d'achat unitaire au moment de l'achat

  @HiveField(3)
  int quantite; // Quantité achetée

  @HiveField(4)
  DateTime date; // Date de l'achat

  Achat({
    required this.id,
    required this.produitId,
    required this.prixAchat,
    required this.quantite,
    required this.date,
  });
}
