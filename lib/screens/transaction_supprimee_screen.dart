import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/produit.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart' as t;

class TransactionSupprimeeScreen extends StatelessWidget {
  const TransactionSupprimeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionsSupprimees = Provider.of<TransactionProvider>(context)
        .transactionsSupprimees
      ..sort((a, b) => b.dateSuppression.compareTo(a.dateSuppression)); // ✅ Tri du plus récent au plus ancien

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des suppressions'),
      ),
      body: transactionsSupprimees.isEmpty
          ? const Center(child: Text('Aucune transaction supprimée.'))
          : ListView.builder(
        itemCount: transactionsSupprimees.length,
        itemBuilder: (context, index) {
          final tS = transactionsSupprimees[index];
          final t.Transaction tOriginale = tS.transactionOriginale;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: Text(
                'Transaction supprimée le ${DateFormat.yMd().add_Hm().format(tS.dateSuppression)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Type : ${tOriginale.type}'),
                  Text('Total : ${tOriginale.total.toStringAsFixed(2)} HTG'),
                  if (tOriginale.clientId != null)
                    Text('Client : ${tOriginale.clientNom}'),
                ],
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Détails de la transaction supprimée'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 150,
                          maxHeight: 400,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Type : ${tOriginale.type}'),
                              Text('Total : ${tOriginale.total.toStringAsFixed(2)} HTG'),
                              Text('Client : ${tOriginale.clientNom ?? 'N/A'}'),
                              Text('Date de suppression : ${DateFormat.yMd().add_Hm().format(tS.dateSuppression)}'),
                              Text('Date de la transaction : ${DateFormat.yMd().add_Hm().format(tOriginale.date)}'),
                              const SizedBox(height: 8),
                              const Text('Produits :', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              ...tOriginale.produits.map((p) {
                                final produit = Hive.box<Produit>('produits').get(p.produitId);
                                final nom = produit?.codeProduit ?? 'Inconnu';
                                return Text('- $nom x${p.quantite}');
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Fermer'),
                      ),
                    ],
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