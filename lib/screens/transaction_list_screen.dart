import 'package:flutter/material.dart';
import 'package:lea_store_office/screens/transaction_supprimee_screen.dart';
import 'transaction_list_vente.dart';
import 'transaction_list_achat.dart';
import '../widgets/custom_search_bar.dart';

class TransactionListScreen extends StatefulWidget {
  final String initialTab; // Peut être 'vente' ou 'achat'

  const TransactionListScreen({super.key, this.initialTab = 'vente'});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  late bool _isVente;
  bool _isSearching = false;
  String _selectedFilter = 'Nom';
  final List<String> _filters = ['Nom', 'Numéro', 'Montant'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isVente = widget.initialTab == 'vente';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? CustomSearchBar(
          searchController: _searchController,
          selectedFilter: _selectedFilter,
          onSearchChanged: (_) => setState(() {}),
          onFilterChanged: (value) {
            setState(() {
              _selectedFilter = value;
            });
          },
          filters: _filters,
        )
            : const Text('Transactions'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          if (!_isSearching) // ✅ On montre le menu seulement hors mode recherche
            PopupMenuButton<String>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'historique',
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: const [
                      Icon(Icons.history, size: 20),
                      SizedBox(width: 8),
                      Text('Historique des suppressions', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'historique') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransactionSupprimeeScreen()),
                  );
                }
              },
              icon: const Icon(Icons.more_vert, size: 20),
            ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Ventes'),
                selected: _isVente,
                onSelected: (val) {
                  setState(() {
                    _isVente = true;
                  });
                },
                selectedColor: Colors.blue.shade100,
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('Achats'),
                selected: !_isVente,
                onSelected: (val) {
                  setState(() {
                    _isVente = false;
                  });
                },
                selectedColor: Colors.green.shade100,
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: _isVente
                ? TransactionListVente(
              searchQuery: _searchController.text,
              selectedFilter: _selectedFilter,
            )
                : TransactionListAchat(
              searchQuery: _searchController.text,
              selectedFilter: _selectedFilter,
            ),
          ),
        ],
      ),
    );
  }
}
