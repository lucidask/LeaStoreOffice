import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/client_provider.dart';
import 'edit_client_screen.dart';
import 'client_detail_screen.dart'; // ✅ Ajoute l'import

class ClientListScreen extends StatelessWidget {
  const ClientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clients = Provider.of<ClientProvider>(context).clients;

    return Scaffold(
      appBar: AppBar(title: const Text('Liste des Clients')),
      body: clients.isEmpty
          ? const Center(child: Text('Aucun client trouvé.'))
          : ListView.builder(
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final c = clients[index];
          return ListTile(
            leading: c.imagePath != null
                ? CircleAvatar(backgroundImage: FileImage(File(c.imagePath!)))
                : const CircleAvatar(child: Icon(Icons.person)),
            title: Text(c.nom),
            subtitle: Text(
              'Solde : ${c.solde.toStringAsFixed(2)} HTG\n${c.telephone ?? 'Pas de téléphone'}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
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
                              Provider.of<ClientProvider>(context, listen: false).supprimerClient(c.id);
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
          );
        },
      ),
    );
  }
}
