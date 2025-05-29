import 'package:flutter/material.dart';
import 'transaction_list_vente.dart';
import 'transaction_list_achat.dart';
import '../widgets/custom_search_bar.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  bool _isVente = true;
  bool _isSearching = false;
  String _selectedFilter = 'Nom';
  final List<String> _filters = ['Nom', 'Numéro', 'Montant'];
  final TextEditingController _searchController = TextEditingController();

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
