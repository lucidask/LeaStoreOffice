import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lea_store_office/screens/vente_transaction.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart' as t;
import '../providers/panier_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/pdf_invoice.dart';
import 'achat_transaction.dart';

class TransactionDetailScreen extends StatelessWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transaction = transactionProvider.transactions.firstWhere(
          (tx) => tx.id == transactionId,
      orElse: () => t.Transaction.dummy(), // Permet d'éviter l'erreur de type (Dart ne supporte pas null, donc cast forcé)
    );

    final isVente = transaction.type == 'vente';
    final formattedDate = DateFormat('dd/MM/yyyy  HH:mm').format(transaction.date);
    final factureId = DateFormat('yyMMddHHmmssSSS').format(transaction.date);


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
                  factureId: factureId,
                  clientNom: transaction.clientNom ?? 'Anonyme',
                  date: formattedDate,
                  modePaiement: transaction.isCredit ? 'Crédit' : 'Comptant',
                  produits: transaction.produits,
                );
              },
            ),
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.zero,
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'supprimer',
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: const [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Supprimer', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'supprimer') {
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
                              .supprimerTransaction(transaction.id);
                          Navigator.pop(context); // Fermer le dialog
                          Navigator.pop(context); // Retourner à la liste
                        },
                        child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              }
            },
            icon: const Icon(Icons.more_vert, size: 20),
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
                    subtitle: Text('Quantité : ${item.quantite} • Cout : ${item.prixUnitaire.toStringAsFixed(2)} HTG'),
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
            if(isVente)
            ElevatedButton.icon(
              onPressed: () {
                Provider.of<PanierProvider>(context, listen: false).clearPanier();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const VenteTransactionScreen()),
                );
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Nouvelle vente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            if (!isVente)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AchatTransactionScreen()),
                );
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Nouvel Achat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );

  }
}
