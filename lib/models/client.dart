import 'package:hive/hive.dart';

part 'client.g.dart';

@HiveType(typeId: 1)
class Client extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nom;

  @HiveField(2)
  String? telephone; // ✅ Optionnel

  @HiveField(3)
  String? imagePath; // ✅ Optionnel

  @HiveField(4)
  double solde;

  @HiveField(5)
  double? depot;


  Client({
    required this.id,
    required this.nom,
    this.telephone,
    this.imagePath,
    required this.solde,
    this.depot,
  });
}

