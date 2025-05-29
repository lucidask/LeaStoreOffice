import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/client_provider.dart';
import '../screens/transaction_detail_screen.dart';

class TransactionListVente extends StatelessWidget {
  const TransactionListVente({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = Provider.of<TransactionProvider>(context)
        .transactions
        .where((tx) => tx.type == 'vente')
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Tri par date et heure

    final clients = Provider.of<ClientProvider>(context).clients;

    return Scaffold(
      appBar: AppBar(title: const Text('Liste des Ventes')),
      body: transactions.isEmpty
          ? const Center(child: Text('Aucune vente enregistrée.'))
          : ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final tx = transactions[index];
          final client = clients.firstWhere(
                (c) => c.id == tx.clientId,
            orElse: () => clients.firstWhere((c) => c.nom == 'Anonyme'),
          );

          final numeroTransaction = DateFormat('yyMMddHHmmssms').format(tx.date);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.sell, color: Colors.white),
              ),
              title: Text(
                'VENTE - ${client.nom}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Numéro : $numeroTransaction'),
                  Text('Montant : ${tx.total.toStringAsFixed(2)} HTG', style: const TextStyle(fontWeight: FontWeight.bold),),
                  Text(DateFormat('dd/MM/yyyy – HH:mm').format(tx.date)),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Édition à implémenter.')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Supprimer la transaction'),
                          content: const Text('Êtes-vous sûr de vouloir supprimer cette transaction ?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () {
                                Provider.of<TransactionProvider>(context, listen: false)
                                    .supprimerTransaction(tx.id);
                                Navigator.pop(context);
                              },
                              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
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
      ),
    );
  }
}
