import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../screens/transaction_detail_screen.dart';
import '../widgets/paginated_list.dart';
import '../utils/date_filter_helper.dart'; // ✅ Import du helper

class TransactionListAchat extends StatefulWidget {
  final String searchQuery;
  final String selectedFilter;

  const TransactionListAchat({
    super.key,
    required this.searchQuery,
    required this.selectedFilter,
  });

  @override
  State<TransactionListAchat> createState() => _TransactionListAchatState();
}

class _TransactionListAchatState extends State<TransactionListAchat> {
  final DateFilterHelper _dateFilterHelper = DateFilterHelper();

  @override
  Widget build(BuildContext context) {
    final transactions = Provider.of<TransactionProvider>(context)
        .transactions
        .where((tx) => tx.type == 'achat' && _dateFilterHelper.matchDate(tx.date))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // Filtrage
    final filteredTransactions = transactions.where((tx) {
      final numero = DateFormat('yyMMddHHmmssms').format(tx.date);
      final montant = tx.total.toStringAsFixed(2);
      final fournisseur = tx.fournisseur ?? 'Inconnu';

      if (widget.selectedFilter == 'Nom') {
        return fournisseur.toLowerCase().contains(widget.searchQuery.toLowerCase());
      } else if (widget.selectedFilter == 'Numéro') {
        return numero.contains(widget.searchQuery);
      } else if (widget.selectedFilter == 'Montant') {
        return montant.contains(widget.searchQuery);
      }
      return true;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
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
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  await _dateFilterHelper.pickDateRange(context);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
        if (_dateFilterHelper.selectedDateRange != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _dateFilterHelper.getFilterLabel(),
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        Expanded(
          child: filteredTransactions.isEmpty
              ? const Center(child: Text('Aucun achat correspondant.'))
              : PaginatedList(
            items: filteredTransactions,
            itemsPerPage: 50,
            itemBuilder: (context, tx) {
              final numeroTransaction = DateFormat('yyMMddHHmmssms').format(tx.date);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.shopping_cart, color: Colors.white),
                  ),
                  title: Text(
                    'ACHAT - ${tx.fournisseur ?? 'Inconnu'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Numéro : $numeroTransaction'),
                      Text('Montant : ${tx.total.toStringAsFixed(2)} HTG',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(DateFormat('dd/MM/yyyy – HH:mm').format(tx.date)),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionDetailScreen(transactionId: tx.id),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
