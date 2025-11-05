import 'package:hive/hive.dart';
import 'package:lea_store_office/models/transaction.dart';
import 'transaction.dart' as t;

part 'transaction_supprimee.g.dart';

@HiveType(typeId: 4)
class TransactionSupprimee extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime dateSuppression;

  @HiveField(2)
  t.Transaction transactionOriginale;

  TransactionSupprimee({
    required this.id,
    required this.dateSuppression,
    required this.transactionOriginale,
  });

  // ✅ toJson pour l'export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateSuppression': dateSuppression.toIso8601String(),
      'transactionOriginale': transactionOriginale.toJson(), // Appelle le toJson() de Transaction
    };
  }

  // ✅ fromJson pour l'import
  factory TransactionSupprimee.fromJson(Map<String, dynamic> json) {
    return TransactionSupprimee(
      id: json['id'],
      dateSuppression: DateTime.parse(json['dateSuppression']),
      transactionOriginale: t.Transaction.fromJson(json['transactionOriginale']),
    );
  }
}
