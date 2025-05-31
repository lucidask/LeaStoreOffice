import 'package:hive/hive.dart';
import 'package:lea_store_office/models/transaction.dart';
import 'transaction.dart' as t; // Attention au conflit de noms

part 'transaction_supprimee.g.dart';

@HiveType(typeId: 4) // Choisis un typeId unique
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
}
