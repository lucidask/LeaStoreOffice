import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedFilter;
  final Function(String) onSearchChanged;
  final Function(String) onFilterChanged;
  final List<String> filters;
  final String hintText;

  const CustomSearchBar({
    super.key,
    required this.searchController,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.filters,
    this.hintText = 'Rechercher...',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: selectedFilter,
          items: filters.map((filter) {
            return DropdownMenuItem(
              value: filter,
              child: Text(filter),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onFilterChanged(value);
          },
        ),
      ],
    );
  }
}
