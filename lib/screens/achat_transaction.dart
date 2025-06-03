import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lea_store_office/screens/transaction_detail_screen.dart';
import 'package:provider/provider.dart';
import '../models/produit.dart';
import '../models/transaction_item.dart';
import '../providers/achat_provider.dart';
import '../providers/product_provider.dart';
import '../providers/transaction_provider.dart';

class AchatTransactionScreen extends StatefulWidget {
  const AchatTransactionScreen({super.key});

  @override
  State<AchatTransactionScreen> createState() => _AchatTransactionScreenState();
}

class _AchatTransactionScreenState extends State<AchatTransactionScreen> {
  final _fournisseurController = TextEditingController();
  Produit? _selectedProduit;
  final _quantiteController = TextEditingController();
  final _prixController = TextEditingController();
  final List<TransactionItem> _items = [];

  int get _stockActuel => _selectedProduit != null ? _selectedProduit!.stock : 0;
  int get _quantiteAjoutee => int.tryParse(_quantiteController.text) ?? 0;
  double get _prixAjoute => double.tryParse(_prixController.text) ?? 0.0;
  int get _stockApres => _stockActuel + _quantiteAjoutee;

  void _ajouterProduit() {
    if (_selectedProduit == null || _quantiteAjoutee <= 0 || _prixAjoute <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remplissez tous les champs correctement.')),
      );
      return;
    }

    final exist = _items.indexWhere((e) => e.produitId == _selectedProduit!.id);
    if (exist != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ce produit a déjà été ajouté.')),
      );
      return;
    }

    setState(() {
      _items.add(TransactionItem(
        produitId: _selectedProduit!.id,
        produitNom: _selectedProduit!.codeProduit,
        produitImagePath: _selectedProduit!.imagePath,
        quantite: _quantiteAjoutee,
        prixUnitaire: _prixAjoute,
      ));

      _selectedProduit = null;
      _quantiteController.clear();
      _prixController.clear();
    });
  }

  void _saveTransaction() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins un produit.')),
      );
      return;
    }

    final achatProvider = Provider.of<AchatProvider>(context, listen: false);

    final newTransaction = Provider.of<TransactionProvider>(context, listen: false).ajouterTransaction(
      type: 'achat',
      clientId: null,
      isCredit: false,
      produits: _items,
      fournisseur: _fournisseurController.text.isNotEmpty ? _fournisseurController.text : null,
    );

    // ✅ Enregistrer chaque produit dans la table Achat
    for (var item in _items) {
      achatProvider.ajouterAchat(
        item.produitId,
        item.prixUnitaire,
        item.quantite,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Achat enregistré avec succès !')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetailScreen(transactionId: newTransaction.id),
      ),
    );
  }

  @override
  void dispose() {
    _fournisseurController.dispose();
    _quantiteController.dispose();
    _prixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final produits = Provider.of<ProductProvider>(context).produits;
    final transactionsProvider = Provider.of<TransactionProvider>(context);
    final transactionsSorted = transactionsProvider.transactions
        .where((t) => t.type == 'achat')
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final lastFiveTransactions = transactionsSorted.take(5).toList();

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
            const SizedBox(height: 16),

            // Ligne d'ajout
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: DropdownSearch<Produit>(
                      items: produits,
                      selectedItem: _selectedProduit,
                      itemAsString: (Produit? p) => p?.codeProduit ?? '',
                      onChanged: (val) {
                        setState(() {
                          _selectedProduit = val;
                        });
                      },
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: 'Produit',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        itemBuilder: (context, Produit? p, bool isSelected) {
                          if (p == null) return const SizedBox();
                          return ListTile(
                            leading: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: p.imagePath != null
                                    ? DecorationImage(
                                  image: FileImage(File(p.imagePath!)),
                                  fit: BoxFit.cover,
                                )
                                    : null,
                                color: p.imagePath == null ? Colors.grey.shade300 : null,
                              ),
                              child: p.imagePath == null
                                  ? const Icon(Icons.image, size: 18, color: Colors.grey)
                                  : null,
                            ),
                            title: Text(
                              p.codeProduit,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                        constraints: const BoxConstraints(maxHeight: 300),
                        searchFieldProps: const TextFieldProps(
                          decoration: InputDecoration(
                            labelText: 'Rechercher...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      dropdownButtonProps: const DropdownButtonProps(
                        icon: Icon(Icons.arrow_drop_down),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(width: 80, child: Text('Stock: $_stockActuel')),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _quantiteController,
                      decoration: const InputDecoration(labelText: 'Quantité'),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _prixController,
                      decoration: const InputDecoration(labelText: 'Cout'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(width: 80, child: Text('Après: $_stockApres')),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    onPressed: _ajouterProduit,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Liste des produits ajoutés ou derniers achats
            if (_items.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final total = (item.quantite * item.prixUnitaire).toStringAsFixed(2);
                    return Card(
                      child: ListTile(
                        leading: item.produitImagePath != null
                            ? Image.file(File(item.produitImagePath!), width: 40, height: 40, fit: BoxFit.cover)
                            : const Icon(Icons.image_not_supported),
                        title: Text(item.produitNom),
                        subtitle: Text('Quantité: ${item.quantite} | Prix: ${item.prixUnitaire} HTG | Total: $total HTG'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _items.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: lastFiveTransactions.length,
                  itemBuilder: (context, index) {
                    final achat = lastFiveTransactions[index];
                    final total = achat.produits.fold(0.0, (sum, item) => sum + item.quantite * item.prixUnitaire);
                    final formattedDate = DateFormat('dd/MM/yyyy - HH:mm').format(achat.date);
                    final numeroTransaction = DateFormat('yyMMddHHmmssms').format(achat.date);

                    return Card(
                      color: Colors.grey.shade100,
                      child: ListTile(
                        leading: const Icon(Icons.shopping_cart, color: Colors.blue),
                        title: Text('Achat #$numeroTransaction'),
                        subtitle: Text('Date: $formattedDate\nProduits: ${achat.produits.length} | Total: ${total.toStringAsFixed(2)} HTG'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TransactionDetailScreen(transactionId: achat.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total : ${_items.fold(0.0, (sum, item) => sum + item.quantite * item.prixUnitaire).toStringAsFixed(2)} HTG',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
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
