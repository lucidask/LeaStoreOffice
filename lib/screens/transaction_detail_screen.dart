import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart' as t;
import '../providers/transaction_provider.dart';
import '../utils/pdf_invoice.dart';

class TransactionDetailScreen extends StatelessWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transaction = transactionProvider.transactions.firstWhere(
          (tx) => tx.id == transactionId,
      orElse: () => null as t.Transaction, // Permet d'éviter l'erreur de type (Dart ne supporte pas null, donc cast forcé)
    );

    if (transaction == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails de la transaction')),
        body: const Center(child: Text('Transaction introuvable.')),
      );
    }

    final isVente = transaction.type == 'vente';
    final formattedDate = DateFormat('dd/MM/yyyy – HH:mm').format(transaction.date);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la transaction'),
        actions: [
          if (isVente)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Imprimer la facture',
              onPressed: () async {
                await PDFInvoice.generateInvoice(
                  factureId: transaction.id.toString(),
                  clientNom: transaction.clientId ?? 'Anonyme',
                  date: formattedDate,
                  modePaiement: transaction.isCredit ? 'Crédit' : 'Comptant',
                  produits: transaction.produits,
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Numéro : ${DateFormat('HHmmssSSS').format(transaction.date)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Type : ${transaction.type.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Date : $formattedDate'),
            Text('Mode : ${transaction.isCredit ? 'Crédit' : 'Cash'}'),
            if (transaction.type == 'vente')
              Text('Client : ${transaction.clientNom ?? 'Anonyme'}'),
            if (transaction.type == 'achat')
              Text('Fournisseur : ${transaction.fournisseur ?? 'Inconnu'}'),
            const Divider(height: 30),
            const Text('Produits :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.separated(
                itemCount: transaction.produits.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = transaction.produits[index];
                  return ListTile(
                    leading: item.produitImagePath != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(item.produitImagePath!), width: 50, height: 50, fit: BoxFit.cover),
                    )
                        : const Icon(Icons.shopping_bag_outlined),
                    title: Text(item.produitNom, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Quantité : ${item.quantite} • Prix : ${item.prixUnitaire.toStringAsFixed(2)} HTG'),
                    trailing: Text('${item.sousTotal.toStringAsFixed(2)} HTG'),
                  );
                },
              ),
            ),
            const Divider(height: 30),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total : ${transaction.total.toStringAsFixed(2)} HTG',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
