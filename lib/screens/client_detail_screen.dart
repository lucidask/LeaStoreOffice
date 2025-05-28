import 'dart:io';
import 'package:flutter/material.dart';
import '../database/hive_service.dart';

class ClientDetailScreen extends StatefulWidget {
  final String clientId;

  const ClientDetailScreen({super.key, required this.clientId});

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final client = HiveService.clientsBox.get(widget.clientId);

    if (client == null) {
      return const Scaffold(
        body: Center(child: Text('Client non trouvé')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(client.nom)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                client.imagePath != null
                    ? Image.file(File(client.imagePath!), width: 80, height: 80, fit: BoxFit.cover)
                    : const Icon(Icons.person, size: 80),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Téléphone : ${client.telephone ?? 'N/A'}'),
                    Text('Solde : ${client.solde.toStringAsFixed(2)} HTG'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final controller = TextEditingController();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Ajouter un versement'),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(labelText: 'Montant (HTG)'),
                      keyboardType: TextInputType.number,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          final montant = double.tryParse(controller.text);
                          if (montant != null && montant > 0) {
                            setState(() {
                              client.solde -= montant;
                              client.save();
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Versement enregistré.')),
                            );
                          }
                        },
                        child: const Text('Enregistrer'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Ajouter un versement'),
            ),
          ],
        ),
      ),
    );
  }
}
