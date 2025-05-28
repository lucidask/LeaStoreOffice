import 'package:hive/hive.dart';

part 'produit.g.dart'; // Nécessaire pour Hive

@HiveType(typeId: 0)
@HiveType(typeId: 0)
class Produit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String codeProduit;

  @HiveField(2)
  String categorie;

  @HiveField(3)
  double prixUnitaire;

  @HiveField(4)
  int stock; // Stock par défaut = 0

  @HiveField(5)
  String? imagePath; // ✅ Optionnel maintenant

  Produit({
    required this.id,
    required this.codeProduit,
    required this.categorie,
    required this.prixUnitaire,
    this.stock = 0, // ✅ Stock par défaut 0
    this.imagePath, // ✅ Image optionnelle
  });
}

