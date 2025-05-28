import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'edit_product_screen.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final produits = Provider.of<ProductProvider>(context).produits;

    return Scaffold(
      appBar: AppBar(title: const Text('Liste des Produits')),
      body: produits.isEmpty
          ? const Center(child: Text('Aucun produit trouvé.'))
          : ListView.builder(
        itemCount: produits.length,
        itemBuilder: (context, index) {
          final p = produits[index];
          return ListTile(
            leading: p.imagePath != null
                ? Image.file(File(p.imagePath!), width: 40, height: 40)
                : const Icon(Icons.image_not_supported),
            title: Text(p.codeProduit),
            subtitle: Text('Prix : ${p.prixUnitaire.toStringAsFixed(2)} HTG • Stock : ${p.stock}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
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
                              Provider.of<ProductProvider>(context, listen: false).supprimerProduit(p.id);
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
          );
        },
      ),
    );
  }
}
