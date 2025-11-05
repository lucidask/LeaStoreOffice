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

  // ✅ toJson pour export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'produitId': produitId,
      'prixAchat': prixAchat,
      'quantite': quantite,
      'date': date.toIso8601String(),
    };
  }

  // ✅ fromJson pour import
  factory Achat.fromJson(Map<String, dynamic> json) {
    return Achat(
      id: json['id'],
      produitId: json['produitId'],
      prixAchat: (json['prixAchat'] as num).toDouble(),
      quantite: json['quantite'],
      date: DateTime.parse(json['date']),
    );
  }
}

