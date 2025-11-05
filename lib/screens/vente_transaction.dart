import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:lea_store_office/screens/transaction_detail_screen.dart';
import 'package:provider/provider.dart';
import '../models/transaction_item.dart';
import '../providers/client_provider.dart';
import '../providers/panier_provider.dart';
import '../providers/product_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/custom_search_bar.dart';

class VenteTransactionScreen extends StatefulWidget {
  const VenteTransactionScreen({super.key});

  @override
  State<VenteTransactionScreen> createState() => _VenteTransactionScreenState();
}

class _VenteTransactionScreenState extends State<VenteTransactionScreen> {
  String? _selectedClientId;
  bool _isCredit = false;
  final TextEditingController _versementController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Code';
  final List<String> _filters = ['Code', 'Prix'];
  bool _utiliserDepot = false;

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
                                  onPressed: () => panierProvider.removeItem(item),
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
    final client = clientProvider.clients.firstWhere((c) => c.id == clientId);
    final depotDispo = client.depot ?? 0.0;
    final versement = double.tryParse(_versementController.text) ?? 0.0;
    final total = panierProvider.items.fold(0.0, (sum, item) => sum + item.quantite * item.prixUnitaire);

    if (_isCredit) {
      // 🔒 Vérifications initiales
      if (_selectedClientId == null || _selectedClientId == anonymeId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner un client pour une vente à crédit.')),
        );
        return;
      }

      double depotUtilise = 0.0;
      if (_utiliserDepot) {
        depotUtilise = depotDispo.clamp(0, total - versement);
      }

      final resteAPayer = total - versement - depotUtilise;

      if (resteAPayer < -0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le paiement dépasse le total.')),
        );
        return;
      }

      if (resteAPayer.abs() < 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le paiement est exact. Faites une vente cash.')),
        );
        return;
      }

      // 🔥 Confirmer l'ajout à la balance
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Montant insuffisant'),
          content: Text('Le paiement ne couvre pas le total. Mettre le reste (${resteAPayer.toStringAsFixed(2)} HTG) sur la balance du client ?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                // ✅ Déduire le dépôt si utilisé
                if (_utiliserDepot && depotUtilise > 0) {
                  clientProvider.ajouterDepot(clientId, -depotUtilise);
                }

                // ✅ Ajouter le reste à la balance
                clientProvider.augmenterSolde(clientId, resteAPayer);

                // ✅ Créer la transaction
                final newTransaction = Provider.of<TransactionProvider>(context, listen: false).ajouterTransaction(
                  type: 'vente',
                  clientId: clientId,
                  isCredit: true,
                  produits: panierProvider.items.map((item) => TransactionItem(
                    produitId: item.produitId,
                    produitNom: item.produitNom,
                    produitImagePath: item.produitImagePath,
                    quantite: item.quantite,
                    prixUnitaire: item.prixUnitaire,
                  )).toList(),
                  versement: versement,
                  depotUtilise: depotUtilise,

                );

                panierProvider.clearPanier();
                _versementController.clear();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vente crédit enregistrée avec succès !')),
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TransactionDetailScreen(transactionId: newTransaction.id),
                  ),
                );
              },
              child: const Text('Oui'),
            ),
          ],
        ),
      );

      return;
    }else {
      // Vente CASH

      // ✅ Vérifier si le client est valide pour utiliser le dépôt
      if (_utiliserDepot && (_selectedClientId == null || _selectedClientId == anonymeId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sélectionnez un client pour utiliser le dépôt.')),
        );
        return;
      }

      // ✅ Vérifier si ni versement ni dépôt
      if (_versementController.text.isEmpty && (!_utiliserDepot || (client.depot ?? 0.0) <= 0)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entrez un versement ou utilisez le dépôt.')),
        );
        return;
      }

      // ✅ Calcul du dépôt disponible et utilisé
      double depotUtilise = 0.0;
      if (_utiliserDepot && _selectedClientId != null && _selectedClientId != anonymeId) {
        depotUtilise = (client.depot ?? 0.0).clamp(0, total);
      }

      final montantTotalPaye = versement + depotUtilise;

      // ✅ Cas spécial : Dépôt seul couvre exactement ou dépasse le total
      if (_utiliserDepot && versement == 0 && depotUtilise >= total - 0.01) {
        depotUtilise = total; // On limite le dépôt au total exact
        clientProvider.ajouterDepot(client.id, -depotUtilise);

        final newTransaction = Provider.of<TransactionProvider>(context, listen: false).ajouterTransaction(
          type: 'vente',
          clientId: clientId,
          isCredit: false,
          produits: panierProvider.items.map((item) => TransactionItem(
            produitId: item.produitId,
            produitNom: item.produitNom,
            produitImagePath: item.produitImagePath,
            quantite: item.quantite,
            prixUnitaire: item.prixUnitaire,
          )).toList(),
          versement: versement,
          depotUtilise: depotUtilise,

        );

        panierProvider.clearPanier();
        _versementController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vente cash (avec dépôt) enregistrée avec succès !')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionDetailScreen(transactionId: newTransaction.id),
          ),
        );
        return;
      }

      // ✅ Cas général : Paiement exact
      if ((montantTotalPaye - total).abs() < 0.01) {
        // OK, continuer
      } else if (montantTotalPaye < total - 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le paiement ne couvre pas le total.')),
        );
        return;
      } else if (montantTotalPaye > total + 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le paiement dépasse le total.')),
        );
        return;
      }

      // ✅ Déduire le dépôt si utilisé
      if (_utiliserDepot && _selectedClientId != null && _selectedClientId != anonymeId) {
        clientProvider.ajouterDepot(client.id, -depotUtilise);
      }

      // ✅ Créer la transaction
      final newTransaction = Provider.of<TransactionProvider>(context, listen: false).ajouterTransaction(
        type: 'vente',
        clientId: clientId,
        isCredit: false,
        produits: panierProvider.items.map((item) => TransactionItem(
          produitId: item.produitId,
          produitNom: item.produitNom,
          produitImagePath: item.produitImagePath,
          quantite: item.quantite,
          prixUnitaire: item.prixUnitaire,
        )).toList(),
        versement: versement,
        depotUtilise: depotUtilise,
      );

      panierProvider.clearPanier();
      _versementController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vente cash enregistrée avec succès !')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TransactionDetailScreen(transactionId: newTransaction.id),
        ),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    final produits = Provider.of<ProductProvider>(context).produits;
    final clients = Provider.of<ClientProvider>(context).clients;
    final panierProvider = Provider.of<PanierProvider>(context);

    final filteredProduits = produits.where((p) {
      final query = _searchController.text.toLowerCase();
      if (query.isEmpty) return true;
      if (_selectedFilter == 'Code') {
        return p.codeProduit.toLowerCase().contains(query);
      } else if (_selectedFilter == 'Prix') {
        return p.prixUnitaire.toString().contains(query);
      }
      return true;
    }).toList();

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
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha((0.3 * 255).round()),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🎨 DropdownSearch amélioré
                  DropdownSearch<String>(
                    items: clients.map((c) => c.nom).toList(),
                    selectedItem: _selectedClientId != null
                        ? clients.firstWhere((c) => c.id == _selectedClientId).nom
                        : null,
                    onChanged: (value) {
                      if (value != null) {
                        final client = clients.firstWhere((c) => c.nom == value);
                        setState(() {
                          _selectedClientId = client.id;
                        });
                      }
                    },
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Sélectionner un client',
                        prefixIcon: const Icon(Icons.person, size: 20),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          labelText: 'Rechercher...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      constraints: BoxConstraints(maxHeight: 300),
                    ),
                    dropdownButtonProps: const DropdownButtonProps(
                      icon: Icon(Icons.arrow_drop_down),
                    ),
                  ),

                  const SizedBox(height: 2),

                  // 🎨 Ligne switch + versement + case à cocher
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                Switch(
                                  value: _isCredit,
                                  onChanged: (val) {
                                    setState(() {
                                      _isCredit = val;
                                    });
                                  },
                                ),
                                const Text('Paiement à crédit'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: _versementController,
                              decoration: InputDecoration(
                                labelText: 'Versement (HTG)',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),

                      // Petite marge réduite
                      const SizedBox(height: 2),

                      // Case à cocher alignée au centre
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: _utiliserDepot,
                                  onChanged: (val) {
                                    setState(() {
                                      _utiliserDepot = val ?? false;
                                    });
                                  },
                                ),
                                const Text('Utiliser le dépôt d\'avance'),
                              ],
                            ),
                            if (_utiliserDepot)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  (_selectedClientId != null)
                                      ? (() {
                                    final client = clients.firstWhere((c) => c.id == _selectedClientId);
                                    final depotDisponible = client.depot ?? 0.0;
                                    if (client.nom == 'Anonyme' || depotDisponible <= 0) {
                                      return 'Aucun dépôt disponible';
                                    } else {
                                      return 'Dépôt disponible : ${depotDisponible.toStringAsFixed(2)} HTG';
                                    }
                                  })()
                                      : 'Sélectionnez un client',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 1),

                  // 🎨 Barre de recherche bien intégrée
                  Row(
                    children: [
                      Expanded(
                        child: CustomSearchBar(
                          searchController: _searchController,
                          selectedFilter: _selectedFilter,
                          filters: _filters,
                          onSearchChanged: (_) {
                            setState(() {});
                          },
                          onFilterChanged: (newFilter) {
                            setState(() {
                              _selectedFilter = newFilter;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  // 🧠 Préparer un Map des quantités du panier (clé = produitId, valeur = quantité)
                  final Map<String, int> quantiteMap = {
                    for (var item in panierProvider.items) item.produitId: item.quantite
                  };

                  return ListView.builder(
                    itemCount: filteredProduits.length,
                    itemBuilder: (context, index) {
                      final p = filteredProduits[index];
                      final stockTemp = panierProvider.stockTemp[p.id] ?? p.stock;
                      final quantiteBadge = quantiteMap[p.id] ?? 0;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: p.imagePath != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(p.imagePath!),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          )
                              : const Icon(Icons.shopping_bag_outlined, size: 40),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  p.codeProduit,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
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
