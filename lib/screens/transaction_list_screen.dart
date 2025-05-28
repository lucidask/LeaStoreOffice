import 'package:flutter/material.dart';
import 'transaction_list_vente.dart';
import 'transaction_list_achat.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  bool _isVente = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Ventes'),
                selected: _isVente,
                onSelected: (val) {
                  setState(() {
                    _isVente = true;
                  });
                },
                selectedColor: Colors.blue.shade100,
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('Achats'),
                selected: !_isVente,
                onSelected: (val) {
                  setState(() {
                    _isVente = false;
                  });
                },
                selectedColor: Colors.green.shade100,
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: _isVente ? const TransactionListVente() : const TransactionListAchat(),
          ),
        ],
      ),
    );
  }
}
