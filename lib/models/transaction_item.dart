import 'package:hive/hive.dart';

part 'transaction_item.g.dart';

@HiveType(typeId: 2)
class TransactionItem extends HiveObject {
  @HiveField(0)
  String produitId;

  @HiveField(1)
  String produitNom;

  @HiveField(2)
  final String? produitImagePath;


  @HiveField(3)
  int quantite;

  @HiveField(4)
  double prixUnitaire; // Prix à la date de la transaction

  TransactionItem({
    required this.produitId,
    required this.produitNom,
    required this.produitImagePath,
    required this.quantite,
    required this.prixUnitaire,
  });

  double get sousTotal => prixUnitaire * quantite;
}
