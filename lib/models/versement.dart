import 'package:hive/hive.dart';

part 'versement.g.dart';

@HiveType(typeId: 5) // TypeId unique
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

  // ✅ toJson pour l'export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'montant': montant,
      'date': date.toIso8601String(),
    };
  }

  // ✅ fromJson pour l'import
  factory Versement.fromJson(Map<String, dynamic> json) {
    return Versement(
      id: json['id'],
      clientId: json['clientId'],
      montant: (json['montant'] as num).toDouble(),
      date: DateTime.parse(json['date']),
    );
  }
}
