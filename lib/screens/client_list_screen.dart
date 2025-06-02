import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/client_provider.dart';
import 'add_client_screen.dart';
import 'edit_client_screen.dart';
import 'client_detail_screen.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/paginated_list.dart'; // ✅ N'oublie pas d'importer

class ClientListScreen extends StatefulWidget {
  final String? highlightedClientId;

  const ClientListScreen({super.key, this.highlightedClientId});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Nom';
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clients = Provider.of<ClientProvider>(context).clients;

    // 🔍 Filtrage des clients
    final filteredClients = clients.where((c) {
      final search = _searchText.toLowerCase();
      if (_selectedFilter == 'Nom') {
        return c.nom.toLowerCase().contains(search);
      } else if (_selectedFilter == 'Téléphone') {
        return (c.telephone ?? '').toLowerCase().contains(search);
      }
      return true;
    }).toList();

    // Calcul des totaux
    final totalSolde = clients.fold(0.0, (sum, c) => sum + c.solde);
    final totalClients = clients.length;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? CustomSearchBar(
          searchController: _searchController,
          selectedFilter: _selectedFilter,
          filters: const ['Nom', 'Téléphone'],
          onSearchChanged: (value) {
            setState(() {
              _searchText = value;
            });
          },
          onFilterChanged: (value) {
            setState(() {
              _selectedFilter = value;
            });
          },
          hintText: 'Rechercher par nom ou téléphone...',
        )
            : const Text('Liste des Clients'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchText = '';
                  _selectedFilter = 'Nom';
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
                  MaterialPageRoute(builder: (_) => const AddClientScreen()),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // ✅ PaginatedList ici
          Expanded(
            child: PaginatedList(
              items: filteredClients,
              itemsPerPage: 50, // ✅ Maximum 50 clients par page
              itemBuilder: (context, c) {
                final isHighlighted = c.id == widget.highlightedClientId;

                return Card(
                  color: isHighlighted ? Colors.lightBlueAccent.withOpacity(0.3) : null,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: c.imagePath != null
                        ? CircleAvatar(backgroundImage: FileImage(File(c.imagePath!)))
                        : const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(
                      c.nom,
                      style: isHighlighted
                          ? const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)
                          : const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Balance : ${c.solde.toStringAsFixed(2)} HTG\n'
                          'Dépôt d\'avance : ${(c.depot ?? 0.0).toStringAsFixed(2)} HTG\n'
                          '${c.telephone ?? 'Pas de téléphone'}',
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
                                builder: (_) => EditClientScreen(client: c),
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
                                content: const Text('Voulez-vous vraiment supprimer ce client ?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Provider.of<ClientProvider>(context, listen: false)
                                          .supprimerClient(c.id);
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClientDetailScreen(clientId: c.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // ✅ Totaux en bas
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Total clients : $totalClients',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Total Balance : ${totalSolde.toStringAsFixed(2)} HTG',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
