import 'package:hive/hive.dart';

part 'versement.g.dart';

@HiveType(typeId: 5) // Choisis un typeId unique
class Versement extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String clientId;

  @HiveField(2)
  double montant;

  @HiveField(3)
  DateTime date;

  Versement({
    required this.id,
    required this.clientId,
    required this.montant,
    required this.date,
  });
}
