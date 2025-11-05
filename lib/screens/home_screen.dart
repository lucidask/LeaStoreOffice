
import 'package:flutter/material.dart';
import 'package:lea_store_office/screens/settings_screen.dart';
import 'add_product_screen.dart';
import 'add_client_screen.dart';
import 'add_transaction_screen.dart';
import 'inventaire_screen.dart';
import 'transaction_list_screen.dart';
import 'product_list_screen.dart';
import 'client_list_screen.dart';
import 'comptabilite_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lea Store Office')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildSectionTitle('Produits'),
            _buildWrap(context, [
              _buildTile(context, 'Ajouter Produit', Icons.add_box, const AddProductScreen()),
              _buildTile(context, 'Liste Produits', Icons.inventory, const ProductListScreen()),
            ]),
            const SizedBox(height: 16),

            _buildSectionTitle('Clients'),
            _buildWrap(context, [
              _buildTile(context, 'Ajouter Client', Icons.person_add, const AddClientScreen()),
              _buildTile(context, 'Liste Clients', Icons.people, const ClientListScreen()),
            ]),
            const SizedBox(height: 16),

            _buildSectionTitle('Transactions'),
            _buildWrap(context, [
              _buildTile(context, 'Créer Vente', Icons.sell, const AddTransactionScreen(type: 'vente')),
              _buildTile(context, 'Créer Achat', Icons.shopping_cart, const AddTransactionScreen(type: 'achat')),
              _buildTile(context, 'Liste Transactions', Icons.list, const TransactionListScreen()),
            ]),
            const SizedBox(height: 16),

            _buildSectionTitle('Utilitaires'),
            _buildWrap(context, [
              _buildTile(context, 'Inventaire', Icons.analytics, const InventaireScreen()),
              _buildTile(context, 'Comptabilité', Icons.account_balance_wallet, const ComptabiliteScreen()),
              _buildTile(context, 'Réglages', Icons.settings, const SettingsScreen()),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildWrap(BuildContext context, List<Widget> children) {
    return Center(
        child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: children,
    )
    );
  }

  Widget _buildTile(BuildContext context, String label, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        width: 140,
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha((0.2 * 255).round()),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.blue),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
