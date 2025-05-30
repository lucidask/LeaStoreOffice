import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import '../widgets/custom_search_bar.dart';

class ProductListScreen extends StatefulWidget {
  final String? highlightProductId;
  const ProductListScreen({super.key, this.highlightProductId});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  int _currentPage = 1;
  static const int _itemsPerPage = 10;

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Code';
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final produits = Provider.of<ProductProvider>(context).produits;

    // Appliquer la recherche et le filtre
    final filteredProduits = produits.where((p) {
      final search = _searchText.toLowerCase();
      if (_selectedFilter == 'Code') {
        return p.codeProduit.toLowerCase().contains(search);
      } else if (_selectedFilter == 'Prix') {
        return p.prixUnitaire.toString().contains(search);
      } else if (_selectedFilter == 'Catégorie') {
        return p.categorie.toLowerCase().contains(search);
      }
      return true;
    }).toList();

    final totalPages = (filteredProduits.length / _itemsPerPage).ceil();
    final paginatedProduits = filteredProduits
        .skip((_currentPage - 1) * _itemsPerPage)
        .take(_itemsPerPage)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? CustomSearchBar(
          searchController: _searchController,
          selectedFilter: _selectedFilter,
          filters: const ['Code', 'Prix', 'Catégorie'],
          onSearchChanged: (value) {
            setState(() {
              _searchText = value;
              _currentPage = 1;
            });
          },
          onFilterChanged: (value) {
            setState(() {
              _selectedFilter = value;
              _currentPage = 1;
            });
          },
          hintText: 'Rechercher...',
        )
            : const Text('Liste des Produits'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchText = '';
                }
              });
            },
          ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddProductScreen()),
                );
              },
            ),
        ],
      ),
      body: filteredProduits.isEmpty
          ? const Center(child: Text('Aucun produit trouvé.'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: paginatedProduits.length,
              itemBuilder: (context, index) {
                final p = paginatedProduits[index];
                final isHighlighted = p.id == widget.highlightProductId;

                return Card(
                  color: isHighlighted ? Colors.lightBlueAccent.withOpacity(0.3) : null,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: p.imagePath != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.file(File(p.imagePath!), width: 50, height: 50, fit: BoxFit.cover),
                    )
                        : const Icon(Icons.inventory_2, size: 40, color: Colors.grey),
                    title: Text(
                      p.codeProduit,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Prix : ${p.prixUnitaire.toStringAsFixed(2)} HTG • Stock : ${p.stock}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProductScreen(produit: p),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirmer la suppression'),
                                content: const Text('Voulez-vous vraiment supprimer ce produit ?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Provider.of<ProductProvider>(context, listen: false)
                                          .supprimerProduit(p.id);
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
                  ),
                );
              },
            ),
          ),
          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 1
                        ? () {
                      setState(() {
                        _currentPage--;
                      });
                    }
                        : null,
                  ),
                  ...List.generate(totalPages, (index) {
                    final page = index + 1;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentPage == page ? Colors.blue : Colors.grey[300],
                          foregroundColor: _currentPage == page ? Colors.white : Colors.black,
                          minimumSize: const Size(36, 36),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        child: Text('$page'),
                      ),
                    );
                  }),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage < totalPages
                        ? () {
                      setState(() {
                        _currentPage++;
                      });
                    }
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
