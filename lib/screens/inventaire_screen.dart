import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achat_provider.dart';
import '../models/produit.dart';
import '../providers/product_provider.dart';
import 'package:intl/intl.dart';
import '../utils/pdf_inventaire.dart';
import '../widgets/paginated_list.dart';
import '../widgets/custom_search_bar.dart';

class InventaireScreen extends StatefulWidget {
  const InventaireScreen({super.key});

  @override
  State<InventaireScreen> createState() => _InventaireScreenState();
}

class _InventaireScreenState extends State<InventaireScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  String selectedFilter = 'Code produit';
  String sortBy = 'codeProduit';
  bool ascending = true;

  @override
  Widget build(BuildContext context) {
    final produits = Provider.of<ProductProvider>(context).produits;
    final achatProvider = Provider.of<AchatProvider>(context);
    final formatCurrency = NumberFormat.currency(locale: 'fr_FR', symbol: 'HTG ');

    List<Produit> filteredProduits = produits.where((p) {
      return p.codeProduit.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    filteredProduits.sort((a, b) {
      dynamic valA, valB;
      final dernierAchatA = achatProvider.dernierAchatPourProduit(a.id)?.prixAchat ?? 0.0;
      final dernierAchatB = achatProvider.dernierAchatPourProduit(b.id)?.prixAchat ?? 0.0;

      switch (sortBy) {
        case 'codeProduit':
          valA = a.codeProduit.toLowerCase();
          valB = b.codeProduit.toLowerCase();
          break;
        case 'categorie':
          valA = a.categorie.toLowerCase();
          valB = b.categorie.toLowerCase();
          break;
        case 'prixAchat':
          valA = dernierAchatA;
          valB = dernierAchatB;
          break;
        case 'prixVente':
          valA = a.prixUnitaire;
          valB = b.prixUnitaire;
          break;
        case 'quantite':
          valA = a.stock;
          valB = b.stock;
          break;
      }
      return ascending ? valA.compareTo(valB) : valB.compareTo(valA);
    });

    final totalAchat = filteredProduits.fold<double>(
      0.0,
          (sum, p) => sum + (achatProvider.dernierAchatPourProduit(p.id)?.prixAchat ?? 0.0) * p.stock,
    );

    final totalVente = filteredProduits.fold<double>(
      0.0,
          (sum, p) => sum + p.prixUnitaire * p.stock,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventaire et Évaluation de Stock'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Imprimer PDF',
            onPressed: () async {
              await PDFInventaire.generatePdf(
                produits: produits,
                achatProvider: achatProvider,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: CustomSearchBar(
              searchController: _searchController,
              selectedFilter: selectedFilter,
              onSearchChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              onFilterChanged: (value) {
                setState(() {
                  selectedFilter = value;
                  sortBy = _filterToSortKey(value);
                });
              },
              filters: const ['Code produit', 'Catégorie', 'Prix Achat', 'Prix Vente', 'Quantité'],
              hintText: 'Rechercher un produit...',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward),
                onPressed: () {
                  setState(() {
                    ascending = !ascending;
                  });
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Grand Total Achat : ${formatCurrency.format(totalAchat)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Grand Total Vente : ${formatCurrency.format(totalVente)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 960, // Largeur ajustée pour la nouvelle colonne
                child: Column(
                  children: [
                    Container(
                      color: Colors.grey.shade200,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: const [
                          _TableHeader('Image', 60),
                          _TableHeader('Code', 120),
                          _TableHeader('Catégorie', 120),
                          _TableHeader('Prix Achat', 100),
                          _TableHeader('Prix Vente', 100),
                          _TableHeader('Quantité', 80),
                          _TableHeader('Valeur Achat', 120),
                          _TableHeader('Valeur Vente', 120),
                          _TableHeader('Marge', 100),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PaginatedList<Produit>(
                        items: filteredProduits,
                        itemsPerPage: 15,
                        itemBuilder: (context, p) {
                          final dernierAchat = achatProvider.dernierAchatPourProduit(p.id);
                          final dernierPrixAchat = dernierAchat?.prixAchat ?? 0.0;
                          final valeurAchat = p.stock * dernierPrixAchat;
                          final valeurVente = p.stock * p.prixUnitaire;
                          final marge = (p.prixUnitaire - dernierPrixAchat) * p.stock;

                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  height: 50,
                                  child: p.imagePath != null
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.file(
                                      File(p.imagePath!),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                      : const Icon(Icons.image_not_supported),
                                ),
                                _TableCell(p.codeProduit, 120),
                                _TableCell(p.categorie, 120),
                                _TableCell(formatCurrency.format(dernierPrixAchat), 100),
                                _TableCell(formatCurrency.format(p.prixUnitaire), 100),
                                _TableCell('${p.stock}', 80),
                                _TableCell(formatCurrency.format(valeurAchat), 120),
                                _TableCell(formatCurrency.format(valeurVente), 120),
                                _TableCell(formatCurrency.format(marge), 100),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _filterToSortKey(String filter) {
    switch (filter) {
      case 'Code produit':
        return 'codeProduit';
      case 'Catégorie':
        return 'categorie';
      case 'Prix Achat':
        return 'prixAchat';
      case 'Prix Vente':
        return 'prixVente';
      case 'Quantité':
        return 'quantite';
      default:
        return 'codeProduit';
    }
  }
}

class _TableHeader extends StatelessWidget {
  final String title;
  final double width;
  const _TableHeader(this.title, this.width);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String content;
  final double width;
  const _TableCell(this.content, this.width);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      alignment: Alignment.center,
      child: Text(
        content,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}