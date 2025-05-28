import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/produit.dart';
import '../models/transaction_item.dart';
import '../providers/product_provider.dart';
import '../providers/transaction_provider.dart';

class AchatTransactionScreen extends StatefulWidget {
  const AchatTransactionScreen({super.key});

  @override
  State<AchatTransactionScreen> createState() => _AchatTransactionScreenState();
}

class _AchatTransactionScreenState extends State<AchatTransactionScreen> {
  final _fournisseurController = TextEditingController();
  final List<TransactionItem> _items = [];
  final Map<String, int> _stockTemp = {};

  void _addProduit(Produit produit) {
    final quantiteController = TextEditingController(text: '1');
    final prixController = TextEditingController(text: produit.prixUnitaire.toString());

    showDialog(
      context: context,
      builder: (_) {
        final stockActuel = _stockTemp[produit.id] ?? produit.stock;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            int quantite = int.tryParse(quantiteController.text) ?? 1;
            int stockFinal = stockActuel + quantite;

            return AlertDialog(
              title: Text('Ajouter ${produit.codeProduit}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Stock actuel : $stockActuel'),
                  TextField(
                    controller: quantiteController,
                    decoration: const InputDecoration(labelText: 'Quantité'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setStateDialog(() {
                        quantite = int.tryParse(value) ?? 1;
                        stockFinal = stockActuel + quantite;
                      });
                    },
                  ),
                  TextField(
                    controller: prixController,
                    decoration: const InputDecoration(labelText: 'Prix unitaire'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  Text('Stock final : $stockFinal', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    final qte = int.tryParse(quantiteController.text) ?? 1;
                    final prix = double.tryParse(prixController.text) ?? produit.prixUnitaire;

                    setState(() {
                      final existing = _items.firstWhere(
                            (e) => e.produitId == produit.id,
                        orElse: () => TransactionItem(
                          produitId: '',
                          produitNom: '',
                          produitImagePath: '',
                          quantite: 0,
                          prixUnitaire: 0,
                        ),
                      );

                      if (existing.produitId != '') {
                        existing.quantite += qte;
                        _stockTemp[produit.id] = (_stockTemp[produit.id] ?? produit.stock) + qte;
                      } else {
                        _items.add(TransactionItem(
                          produitId: produit.id,
                          produitNom: produit.codeProduit,
                          produitImagePath: produit.imagePath,
                          quantite: qte,
                          prixUnitaire: prix,
                        ));
                        _stockTemp[produit.id] = stockActuel + qte;
                      }
                    });

                    Navigator.pop(context);
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveTransaction() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins un produit.')),
      );
      return;
    }

    Provider.of<TransactionProvider>(context, listen: false).ajouterTransaction(
      type: 'achat',
      clientId: null,
      isCredit: false,
      produits: _items,
      fournisseur: _fournisseurController.text.isNotEmpty ? _fournisseurController.text : null,
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _fournisseurController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final produits = Provider.of<ProductProvider>(context).produits;

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvel Achat')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _fournisseurController,
              decoration: const InputDecoration(labelText: 'Fournisseur (optionnel)'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: produits.map((p) {
                  return ListTile(
                    leading: p.imagePath != null
                        ? Image.file(File(p.imagePath!), width: 40, height: 40, fit: BoxFit.cover)
                        : const Icon(Icons.image_not_supported),
                    title: Text(p.codeProduit),
                    subtitle: Text('Prix : ${p.prixUnitaire} HTG\nStock : ${_stockTemp[p.id] ?? p.stock}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _addProduit(p),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (_items.isNotEmpty)
              ...[
                const Divider(),
                const Text(
                  'Produits ajoutés :',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final total = (item.quantite * item.prixUnitaire).toStringAsFixed(2);
                    return ListTile(
                      title: Text(item.produitNom),
                      subtitle: Text('Quantité : ${item.quantite} | Prix : ${item.prixUnitaire} HTG'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              setState(() {
                                if (item.quantite > 1) {
                                  item.quantite--;
                                  _stockTemp[item.produitId] = _stockTemp[item.produitId]! - 1;
                                } else {
                                  _items.remove(item);
                                  _stockTemp[item.produitId] = _stockTemp[item.produitId]! - 1;
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setState(() {
                                item.quantite++;
                                _stockTemp[item.produitId] = _stockTemp[item.produitId]! + 1;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _stockTemp[item.produitId] = _stockTemp[item.produitId]! - item.quantite;
                                _items.remove(item);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Total : ${_items.fold(0.0, (sum, item) => sum + item.quantite * item.prixUnitaire).toStringAsFixed(2)} HTG',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveTransaction,
              child: const Text('Enregistrer l\'achat'),
            ),
          ],
        ),
      ),
    );
  }
}
