import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/produit.dart';
import '../models/transaction_item.dart';
import '../models/transaction.dart' as t;
import '../providers/product_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/client_provider.dart';

class EditTransactionScreen extends StatefulWidget {
  final t.Transaction transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  String? _selectedClientId;
  bool _isCredit = false;
  final List<TransactionItem> _items = [];
  final _fournisseurController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedClientId = widget.transaction.clientId;
    _isCredit = widget.transaction.isCredit;
    _items.addAll(widget.transaction.produits.map((p) => TransactionItem(
      produitId: p.produitId,
      produitNom: p.produitNom,
      produitImagePath: p.produitImagePath,
      quantite: p.quantite,
      prixUnitaire: p.prixUnitaire,
    )));
    _fournisseurController.text = widget.transaction.fournisseur ?? '';
  }

  void _addProduit(Produit produit) {
    final quantiteController = TextEditingController(text: '1');
    final prixController = TextEditingController(text: produit.prixUnitaire.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ajouter ${produit.codeProduit}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantiteController,
              decoration: const InputDecoration(labelText: 'Quantité'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: prixController,
              decoration: const InputDecoration(labelText: 'Prix unitaire'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final qte = int.tryParse(quantiteController.text) ?? 1;
              final prix = double.tryParse(prixController.text) ?? produit.prixUnitaire;

              setState(() {
                _items.add(TransactionItem(
                  produitId: produit.id,
                  produitNom: produit.codeProduit,
                  produitImagePath: produit.imagePath,
                  quantite: qte,
                  prixUnitaire: prix,
                ));
              });
              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins un produit.')),
      );
      return;
    }

    Provider.of<TransactionProvider>(context, listen: false).modifierTransaction(
      id: widget.transaction.id,
      type: widget.transaction.type,
      clientId: _selectedClientId,
      isCredit: _isCredit,
      produits: _items,
      fournisseur: widget.transaction.type == 'achat' && _fournisseurController.text.isNotEmpty
          ? _fournisseurController.text
          : null,
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
    final clients = Provider.of<ClientProvider>(context).clients;

    return Scaffold(
      appBar: AppBar(title: const Text('Modifier la Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (widget.transaction.type == 'vente')
              DropdownButtonFormField<String>(
                value: _selectedClientId,
                hint: const Text('Sélectionner un client'),
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
            if (widget.transaction.type == 'achat')
              TextFormField(
                controller: _fournisseurController,
                decoration: const InputDecoration(labelText: 'Fournisseur (optionnel)'),
              ),
            SwitchListTile(
              title: const Text('Paiement à crédit'),
              value: _isCredit,
              onChanged: (val) {
                setState(() {
                  _isCredit = val;
                });
              },
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
                    subtitle: Text('${p.prixUnitaire} HTG'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _addProduit(p),
                    ),
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Sauvegarder les modifications'),
            ),
          ],
        ),
      ),
    );
  }
}
