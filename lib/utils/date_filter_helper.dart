import 'package:flutter/material.dart';

class DateFilterHelper {
  String selectedFilter = 'Jour'; // Par défaut sur 'Jour'
  DateTimeRange? selectedDateRange;
  List<String> get filters => ['Jour', 'Mois', 'Année'];


  bool matchDate(DateTime txDate) {
    if (selectedDateRange != null) {
      return txDate.isAfter(selectedDateRange!.start.subtract(const Duration(days: 1))) &&
          txDate.isBefore(selectedDateRange!.end.add(const Duration(days: 1)));
    }

    final now = DateTime.now();
    if (selectedFilter == 'Jour') {
      return txDate.year == now.year && txDate.month == now.month && txDate.day == now.day;
    } else if (selectedFilter == 'Mois') {
      return txDate.year == now.year && txDate.month == now.month;
    } else if (selectedFilter == 'Année') {
      return txDate.year == now.year;
    }
    return true;
  }

  void updateFilter(String filter) {
    selectedFilter = filter;
    selectedDateRange = null;
  }

  void updateDateRange(DateTimeRange range) {
    selectedDateRange = range;
  }

  String getFilterLabel() {
    if (selectedDateRange != null) {
      return 'Filtré du ${_formatDate(selectedDateRange!.start)} au ${_formatDate(selectedDateRange!.end)}';
    } else {
      return 'Filtre actuel : $selectedFilter';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final initialRange = selectedDateRange ?? DateTimeRange(
      start: now.subtract(const Duration(days: 7)),
      end: now,
    );

    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: initialRange,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedDateRange = picked;
    }
  }

}
