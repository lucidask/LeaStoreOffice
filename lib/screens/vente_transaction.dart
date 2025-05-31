import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lea_store_office/screens/transaction_detail_screen.dart';
import 'package:provider/provider.dart';
import '../models/transaction_item.dart';
import '../providers/client_provider.dart';
import '../providers/panier_provider.dart';
import '../providers/product_provider.dart';
import '../providers/transaction_provider.dart';

class VenteTransactionScreen extends StatefulWidget {
  const VenteTransactionScreen({super.key});

  @override
  State<VenteTransactionScreen> createState() => _VenteTransactionScreenState();
}

class _VenteTransactionScreenState extends State<VenteTransactionScreen> {
  String? _selectedClientId;
  bool _isCredit = false;
  final TextEditingController _versementController = TextEditingController();



  void _showPanier() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Consumer<PanierProvider>(
          builder: (context, panierProvider, _) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🛒 Panier',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  if (panierProvider.items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Aucun produit sélectionné.'),
                    ),
                  if (panierProvider.items.isNotEmpty)
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: panierProvider.items.length,
                        itemBuilder: (context, index) {
                          final item = panierProvider.items[index];
                          return ListTile(
                            leading: item.produitImagePath != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(item.produitImagePath!),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            )
                                : const Icon(Icons.shopping_bag, size: 30),
                            title: Text(item.produitNom, style: const TextStyle(fontSize: 14),),
                            subtitle: Text('Qté: ${item.quantite} | Prix: ${item.prixUnitaire} HTG'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => panierProvider.decrement(item, 0),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => panierProvider.increment(item, 100000),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => panierProvider.decrement(item, 0),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Total : ${panierProvider.items.fold(0.0, (sum, item) => sum + item.quantite * item.prixUnitaire).toStringAsFixed(2)} HTG',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _saveTransaction() {
    final panierProvider = Provider.of<PanierProvider>(context, listen: false);
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);

    if (panierProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins un produit.')),
      );
      return;
    }

    final anonymeId = clientProvider.clients.firstWhere((c) => c.nom == 'Anonyme').id;
    final clientId = _selectedClientId ?? anonymeId;
    final versement = double.tryParse(_versementController.text) ?? 0.0;

    final total = panierProvider.items.fold(0.0, (sum, item) => sum + item.quantite * item.prixUnitaire);

    // 🌟 Vérifications AVANT la création de la transaction

    if (_isCredit) {
      // Vente CRÉDIT
      if (_selectedClientId == null || _selectedClientId == anonymeId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner un client pour une vente à crédit.')),
        );
        return;
      }

      if (versement > total) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le versement ne peut pas dépasser le total.')),
        );
        return;
      }

      if (versement == total) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez choisir une vente cash.')),
        );
        return;
      }
    } else {
      // Vente CASH
      if (_versementController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le champ versement ne peut pas rester vide.')),
        );
        return;
      }

      if (versement != total) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le versement doit être exactement égal au montant total.')),
        );
        return;
      }
    }

    // 🌟 Création de la transaction APRES toutes les vérifications
    final newTransaction = Provider.of<TransactionProvider>(context, listen: false).ajouterTransaction(
      type: 'vente',
      clientId: clientId,
      isCredit: _isCredit,
      produits: panierProvider.items.map((item) => TransactionItem(
        produitId: item.produitId,
        produitNom: item.produitNom,
        produitImagePath: item.produitImagePath,
        quantite: item.quantite,
        prixUnitaire: item.prixUnitaire,
      )).toList(),
      versement: versement,
    );

    panierProvider.clearPanier();
    _versementController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vente enregistrée avec succès !')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetailScreen(transactionId: newTransaction.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final produits = Provider.of<ProductProvider>(context).produits;
    final clients = Provider.of<ClientProvider>(context).clients;
    final panierProvider = Provider.of<PanierProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Vente'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _showPanier,
              ),
              if (panierProvider.items.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${panierProvider.items.fold(0, (sum, item) => sum + item.quantite)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Réinitialiser le panier',
            onPressed: panierProvider.clearPanier,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedClientId,
              decoration: const InputDecoration(
                labelText: 'Sélectionner un client',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              items: clients.map((c) {
                return DropdownMenuItem(
                  value: c.id,
                  child: Text(c.nom),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClientId = value;
                });
              },
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Paiement à crédit'),
              value: _isCredit,
              onChanged: (val) {
                setState(() {
                  _isCredit = val;
                });
              },
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: _versementController,
                decoration: const InputDecoration(
                  labelText: 'Versement lors de la vente (HTG)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
            ),


            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: produits.length,
                itemBuilder: (context, index) {
                  final p = produits[index];
                  final stockTemp = panierProvider.stockTemp[p.id] ?? p.stock;
                  final quantiteBadge = panierProvider.items.firstWhere(
                        (item) => item.produitId == p.id,
                    orElse: () => TransactionItem(
                      produitId: '',
                      produitNom: '',
                      produitImagePath: '',
                      quantite: 0,
                      prixUnitaire: 0,
                    ),
                  ).quantite;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: p.imagePath != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(p.imagePath!), width: 50, height: 50, fit: BoxFit.cover),
                      )
                          : const Icon(Icons.shopping_bag_outlined, size: 40),
                      title: Row(
                        children: [
                          Expanded(child: Text(p.codeProduit)),
                          if (quantiteBadge > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$quantiteBadge',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text('Prix : ${p.prixUnitaire} HTG\nStock : $stockTemp'),
                      onTap: (p.stock == 0 || stockTemp <= 0)
                          ? null
                          : () {
                        panierProvider.addItem(
                          TransactionItem(
                            produitId: p.id,
                            produitNom: p.codeProduit,
                            produitImagePath: p.imagePath,
                            quantite: 1,
                            prixUnitaire: p.prixUnitaire,
                          ),
                          p.stock,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _saveTransaction,
              icon: const Icon(Icons.check),
              label: const Text('Enregistrer la vente'),
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

  @override
  void dispose() {
    _versementController.dispose();
    super.dispose();
  }

}
