import 'package:flutter/material.dart';
import 'package:lea_store_office/screens/transaction_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../utils/date_filter_helper.dart'; // ✅ Import correct

class ComptabiliteScreen extends StatefulWidget {
  const ComptabiliteScreen({super.key});

  @override
  State<ComptabiliteScreen> createState() => _ComptabiliteScreenState();
}

class _ComptabiliteScreenState extends State<ComptabiliteScreen> {
  final DateFilterHelper _dateFilterHelper = DateFilterHelper();

  @override
  Widget build(BuildContext context) {
    final transactions = Provider.of<TransactionProvider>(context).transactions;
    final achats = transactions.where((t) => t.type == 'achat' && _dateFilterHelper.matchDate(t.date)).toList();
    final ventes = transactions.where((t) => t.type == 'vente' && _dateFilterHelper.matchDate(t.date)).toList();

    final totalAchats = achats.fold(0.0, (sum, t) => sum + t.total);
    final totalVentes = ventes.fold(0.0, (sum, t) => sum + t.total);
    final solde = totalVentes - totalAchats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comptabilité'),
        actions: [
          DropdownButton<String>(
            value: _dateFilterHelper.selectedFilter,
            onChanged: (val) {
              setState(() {
                _dateFilterHelper.updateFilter(val!);
              });
            },
            items: _dateFilterHelper.filters
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              await _dateFilterHelper.pickDateRange(context);
              setState(() {}); // Rafraîchit après sélection
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_dateFilterHelper.selectedDateRange != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Filtré du ${DateFormat('dd/MM/yyyy').format(_dateFilterHelper.selectedDateRange!.start)} au ${DateFormat('dd/MM/yyyy').format(_dateFilterHelper.selectedDateRange!.end)}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            Card(
              child: ListTile(
                title: const Text('Total Achats'),
                trailing: Text('${totalAchats.toStringAsFixed(2)} HTG'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TransactionListScreen(initialTab: 'achat'),
                    ),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Total Ventes'),
                trailing: Text('${totalVentes.toStringAsFixed(2)} HTG'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TransactionListScreen(initialTab: 'vente'),
                    ),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Solde Actuel'),
                trailing: Text(
                  '${solde.toStringAsFixed(2)} HTG',
                  style: TextStyle(
                    color: solde >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Graphique (Achats & Ventes)'),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: totalAchats, color: Colors.orange)]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: totalVentes, color: Colors.blue)]),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Achats');
                            case 1:
                              return const Text('Ventes');
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Détails des Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: (achats + ventes).length,
                itemBuilder: (context, index) {
                  final tx = (achats + ventes)[index];
                  final formattedDate = DateFormat('dd/MM/yyyy – HH:mm').format(tx.date);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: tx.type == 'achat' ? Colors.orange : Colors.blue,
                      child: Icon(tx.type == 'achat' ? Icons.shopping_cart : Icons.sell, color: Colors.white),
                    ),
                    title: Text('${tx.type.toUpperCase()} - ${tx.type == 'achat' ? (tx.fournisseur ?? 'Inconnu') : (tx.clientNom ?? 'Inconnu')}'),
                    subtitle: Text('Montant: ${tx.total.toStringAsFixed(2)} HTG\n$formattedDate'),
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
