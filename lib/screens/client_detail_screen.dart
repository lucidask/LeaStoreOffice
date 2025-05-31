import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/client_provider.dart';
import '../providers/versement_provider.dart';
import '../utils/pdf_client_solde.dart';
import '../utils/pdf_versement_detail.dart';
import '../utils/pdf_versements.dart';

class ClientDetailScreen extends StatefulWidget {
  final String clientId;

  const ClientDetailScreen({super.key, required this.clientId});

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);
    final client = clientProvider.clients.firstWhere((c) => c.id == widget.clientId);


    if (client == null) {
      return const Scaffold(
        body: Center(child: Text('Client non trouvé')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(client.nom),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_balance_wallet),
              tooltip: 'Exporter PDF du solde',
              onPressed: () {
                PDFClientSolde.generateSoldePdf(client);
              },
            ),

          ],
      ),
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
                            final clientProvider = Provider.of<ClientProvider>(context, listen: false);
                            final versementProvider = Provider.of<VersementProvider>(context, listen: false);

                            // ✅ On réduit le solde du client
                            clientProvider.reduireSolde(client.id, montant);
                            // ✅ On ajoute un versement dans l’historique
                            versementProvider.ajouterVersement(clientId: client.id, montant: montant);

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
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Historique des versements :',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  tooltip: 'Exporter PDF',
                  onPressed: () {
                    final versements = Provider.of<VersementProvider>(context, listen: false)
                        .getVersementsParClient(client.id);
                    if (versements.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Aucun versement à exporter')),
                      );
                      return;
                    }

                    PDFVersements.generateVersementsPdf(
                      clientNom: client.nom,
                      versements: versements,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Consumer<VersementProvider>(
                builder: (context, versementProvider, child) {
                  final versements = versementProvider.getVersementsParClient(client.id);
                  if (versements.isEmpty) {
                    return const Text('Aucun versement enregistré.');
                  }
                  return ListView.separated(
                    itemCount: versements.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final v = versements[index];
                      return ListTile(
                        leading: const Icon(Icons.attach_money),
                        title: Text('${v.montant.toStringAsFixed(2)} HTG'),
                        subtitle: Text('Date : ${DateFormat.yMd().add_Hm().format(v.date)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.picture_as_pdf, color: Colors.blue),
                              onPressed: () {
                                final clientNom = client.nom; // ✅ Tu récupères le nom du client
                                PDFVersementDetail.generateVersementPdf(v, clientNom);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Supprimer ce versement ?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Annuler'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          final clientProvider = Provider.of<ClientProvider>(context, listen: false);
                                          final versementProvider = Provider.of<VersementProvider>(context, listen: false);

                                          // ✅ Réajuste le solde du client
                                          clientProvider.augmenterSolde(v.clientId, v.montant);
                                          // ✅ Supprime le versement dans l’historique
                                          versementProvider.supprimerVersement(v.id);

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
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
