import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/client_provider.dart';
import '../providers/versement_provider.dart';
import '../providers/depot_provider.dart';
import '../utils/pdf_client_solde.dart';
import '../utils/pdf_versements.dart';
import '../utils/pdf_versement_detail.dart';
import '../utils/pdf_depots.dart';
import '../utils/pdf_depot_detail.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(client.nom),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            tooltip: 'Exporter PDF des soldes ',
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
                    Text('Balance : ${client.solde.toStringAsFixed(2)} HTG'),
                    Text('Dépôt d\'avance : ${client.depot?.toStringAsFixed(2) ?? '0.00'} HTG'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final controller = TextEditingController();
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Réduire la Balance'),
                          content: TextField(
                            controller: controller,
                            decoration: const InputDecoration(labelText: 'Montant (HTG)'),
                            keyboardType: TextInputType.number,
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                            TextButton(
                              onPressed: () {
                                final montant = double.tryParse(controller.text);
                                if (montant == null || montant <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Veuillez entrer un montant positif.')),
                                  );
                                  return;
                                }

                                final clientProvider = Provider.of<ClientProvider>(context, listen: false);
                                final versementProvider = Provider.of<VersementProvider>(context, listen: false);
                                final soldeClient = client.solde;

                                if (montant > soldeClient) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Le montant du versement dépasse le solde disponible (${soldeClient.toStringAsFixed(2)} HTG).')),
                                  );
                                  return;
                                }

                                clientProvider.reduireSolde(client.id, montant);
                                versementProvider.ajouterVersement(clientId: client.id, montant: montant);

                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Versement enregistré.')),
                                );
                              },
                              child: const Text('Enregistrer'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Réduire la Balance'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final controller = TextEditingController();
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Ajouter un dépôt d\'avance'),
                          content: TextField(
                            controller: controller,
                            decoration: const InputDecoration(labelText: 'Montant (HTG)'),
                            keyboardType: TextInputType.number,
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                            TextButton(
                              onPressed: () {
                                final montant = double.tryParse(controller.text);
                                if (montant == null || montant <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Veuillez entrer un montant positif.')),
                                  );
                                  return;
                                }

                                final clientProvider = Provider.of<ClientProvider>(context, listen: false);
                                final depotProvider = Provider.of<DepotProvider>(context, listen: false);

                                // ✅ Tout est OK, on enregistre
                                clientProvider.ajouterDepot(client.id, montant); // ✅ Ajuster le solde dépôt du client
                                depotProvider.ajouterDepot(clientId: client.id, montant: montant);  // ✅ Ajouter dans l'historique

                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Dépôt enregistré.')),
                                );
                              },
                              child: const Text('Enregistrer'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Ajouter un dépôt d\'avance'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Onglets
            // 🔥 Ajoute le tri directement avant l'affichage des listes

            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Versements Balance'),
                        Tab(text: 'Dépôts d\'avance'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Onglet Versements
                          Column(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: const Icon(Icons.picture_as_pdf),
                                  tooltip: 'Exporter PDF',
                                  onPressed: () {
                                    final versements = Provider.of<VersementProvider>(context, listen: false)
                                        .getVersementsParClient(client.id)
                                      ..sort((a, b) => b.date.compareTo(a.date)); // ✅ Tri ici
                                    if (versements.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Aucun versement à exporter')),
                                      );
                                      return;
                                    }
                                    PDFVersements.generateVersementsPdf(clientNom: client.nom, versements: versements);
                                  },
                                ),
                              ),
                              Expanded(
                                child: Consumer<VersementProvider>(
                                  builder: (context, versementProvider, child) {
                                    final versements = versementProvider.getVersementsParClient(client.id)
                                      ..sort((a, b) => b.date.compareTo(a.date)); // ✅ Tri ici
                                    if (versements.isEmpty) {
                                      return const Center(child: Text('Aucun versement enregistré.'));
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
                                                  PDFVersementDetail.generateVersementPdf(v, client.nom, client.solde);
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
                                                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                                                        TextButton(
                                                          onPressed: () {
                                                            final clientProvider = Provider.of<ClientProvider>(context, listen: false);
                                                            final versementProvider = Provider.of<VersementProvider>(context, listen: false);

                                                            clientProvider.augmenterSolde(v.clientId, v.montant);
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

                          // Onglet Dépôts
                          Column(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: const Icon(Icons.picture_as_pdf),
                                  tooltip: 'Exporter PDF',
                                  onPressed: () {
                                    final depots = Provider.of<DepotProvider>(context, listen: false)
                                        .getDepotsParClient(client.id)
                                      ..sort((a, b) => b.date.compareTo(a.date)); // ✅ Tri ici
                                    if (depots.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Aucun dépôt à exporter')),
                                      );
                                      return;
                                    }
                                    PDFDepots.generateDepotsPdf(clientNom: client.nom, depots: depots);
                                  },
                                ),
                              ),
                              Expanded(
                                child: Consumer<DepotProvider>(
                                  builder: (context, depotProvider, child) {
                                    final depots = depotProvider.getDepotsParClient(client.id)
                                      ..sort((a, b) => b.date.compareTo(a.date)); // ✅ Tri ici
                                    if (depots.isEmpty) {
                                      return const Center(child: Text('Aucun dépôt enregistré.'));
                                    }
                                    return ListView.separated(
                                      itemCount: depots.length,
                                      separatorBuilder: (_, __) => const Divider(),
                                      itemBuilder: (context, index) {
                                        final d = depots[index];
                                        return ListTile(
                                          leading: const Icon(Icons.account_balance_wallet),
                                          title: Text('${d.montant.toStringAsFixed(2)} HTG'),
                                          subtitle: Text('Date : ${DateFormat.yMd().add_Hm().format(d.date)}'),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.picture_as_pdf, color: Colors.blue),
                                                onPressed: () {
                                                  PDFDepotDetail.generateDepotPdf(d, client.nom);
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.red),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: const Text('Supprimer ce dépôt ?'),
                                                      actions: [
                                                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                                                        TextButton(
                                                          onPressed: () {
                                                            final clientProvider = Provider.of<ClientProvider>(context, listen: false);
                                                            final depotProvider = Provider.of<DepotProvider>(context, listen: false);

                                                            clientProvider.ajouterDepot(client.id, -d.montant);
                                                            depotProvider.supprimerDepot(d.id);

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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
