import 'package:hive/hive.dart';
import 'transaction_item.dart';

part 'transaction.g.dart';

@HiveType(typeId: 3)
class Transaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type; // 'achat' ou 'vente'

  @HiveField(2)
  String? clientId; // Null si achat

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  bool isCredit;

  @HiveField(5)
  List<TransactionItem> produits;

  @HiveField(6)
  String? note;

  @HiveField(7)
  double total;

  @HiveField(8)
  String? fournisseur; // ✅ Fournisseur pour achat

  @HiveField(9)
  String? clientNom; // ✅ Nouveau champ pour vente

  @HiveField(10)
  double? versement;

  @HiveField(11)
  double? depotUtilise;



  Transaction({
    required this.id,
    required this.type,
    this.clientId,
    required this.date,
    required this.isCredit,
    required this.produits,
    this.note,
    required this.total,
    this.fournisseur,
    this.clientNom,
    this.versement,
    this.depotUtilise,

  });

  factory Transaction.dummy() {
    return Transaction(
      id: '',
      type: '',
      date: DateTime.now(),
      isCredit: false,
      produits: [],
      clientId: '',
      clientNom: '',
      fournisseur: '',
      total: 0,
      versement: null,
      depotUtilise: null,

    );
  }


  @override
  String toString() {
    return 'Transaction(id: $id, type: $type, clientId: $clientId, clientNom: $clientNom, fournisseur: $fournisseur, total: $total, produits: $produits, Balance: $versement, depot d\'avance utilisé: $depotUtilise)';
  }


}
