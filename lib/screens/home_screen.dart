import 'package:flutter/material.dart';
import 'add_product_screen.dart';
import 'add_client_screen.dart';
import 'add_transaction_screen.dart';
import 'transaction_list_screen.dart';
import 'product_list_screen.dart';
import 'client_list_screen.dart';
import 'comptabilite_screen.dart';  // 👉 N'oublie pas d'importer le fichier une fois créé

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lea Store Office')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildTile(context, 'Ajouter Produit', Icons.add_box, const AddProductScreen()),
            _buildTile(context, 'Ajouter Client', Icons.person_add, const AddClientScreen()),
            _buildTile(context, 'Créer Vente', Icons.sell, const AddTransactionScreen(type: 'vente')),
            _buildTile(context, 'Créer Achat', Icons.shopping_cart, const AddTransactionScreen(type: 'achat')),
            _buildTile(context, 'Liste Transactions', Icons.list, const TransactionListScreen()),
            _buildTile(context, 'Liste Produits', Icons.inventory, const ProductListScreen()),
            _buildTile(context, 'Liste Clients', Icons.people, const ClientListScreen()),
            _buildTile(context, 'Comptabilité', Icons.account_balance_wallet, const ComptabiliteScreen()), // 🎯 Bouton ajouté
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, String label, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
