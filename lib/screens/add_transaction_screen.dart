import 'package:flutter/material.dart';
import 'package:lea_store_office/screens/vente_transaction.dart';
import 'achat_transaction.dart';


class AddTransactionScreen extends StatelessWidget {
  final String type;
  const AddTransactionScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    if (type == 'vente') {
      return const VenteTransactionScreen();
    } else {
      return const AchatTransactionScreen();
    }
  }
}
