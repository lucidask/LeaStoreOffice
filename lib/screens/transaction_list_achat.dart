import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../screens/transaction_detail_screen.dart';

class TransactionListAchat extends StatelessWidget {
  final String searchQuery;
  final String selectedFilter;

  const TransactionListAchat({
    super.key,
    required this.searchQuery,
    required this.selectedFilter,
  });

  @override
  Widget build(BuildContext context) {
    final transactions = Provider.of<TransactionProvider>(context)
        .transactions
        .where((tx) => tx.type == 'achat')
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Tri par date

    // Filtrage en fonction de searchQuery et selectedFilter
    final filteredTransactions = transactions.where((tx) {
      final numero = DateFormat('yyMMddHHmmssms').format(tx.date);
      final montant = tx.total.toStringAsFixed(2);
      final fournisseur = tx.fournisseur ?? 'Inconnu';

      if (selectedFilter == 'Nom') {
        return fournisseur.toLowerCase().contains(searchQuery.toLowerCase());
      } else if (selectedFilter == 'Numéro') {
        return numero.contains(searchQuery);
      } else if (selectedFilter == 'Montant') {
        return montant.contains(searchQuery);
      }
      return true;
    }).toList();

    return filteredTransactions.isEmpty
        ? const Center(child: Text('Aucun achat correspondant.'))
        : ListView.builder(
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final tx = filteredTransactions[index];
        final numeroTransaction = DateFormat('yyMMddHHmmssms').format(tx.date);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.shopping_cart, color: Colors.white),
            ),
            title: Text(
              'ACHAT - ${tx.fournisseur ?? 'Inconnu'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Numéro : $numeroTransaction'),
                Text('Montant : ${tx.total.toStringAsFixed(2)} HTG',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(DateFormat('dd/MM/yyyy – HH:mm').format(tx.date)),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TransactionDetailScreen(transactionId: tx.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
