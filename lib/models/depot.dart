import 'package:hive/hive.dart';

part 'depot.g.dart';

@HiveType(typeId: 6)
class Depot extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String clientId;

  @HiveField(2)
  double montant;

  @HiveField(3)
  DateTime date;

  Depot({
    required this.id,
    required this.clientId,
    required this.montant,
    required this.date,
  });
}
