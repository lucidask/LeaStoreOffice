import 'package:flutter/material.dart';

class PaginatedList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final int itemsPerPage;
  final double? maxHeight;

  const PaginatedList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.itemsPerPage = 50,
    this.maxHeight,
  });

  @override
  State<PaginatedList<T>> createState() => _PaginatedListState<T>();
}

class _PaginatedListState<T> extends State<PaginatedList<T>> {
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final totalPages = (widget.items.length / widget.itemsPerPage).ceil();
    final paginatedItems = widget.items
        .skip(((_currentPage - 1) * widget.itemsPerPage))
        .take(widget.itemsPerPage)
        .toList();

    return Column(
      children: [
        if (paginatedItems.isEmpty)
          const Expanded(child: Center(child: Text('Aucun élément trouvé.')))
        else
          Expanded(
            child: ListView.builder(
              itemCount: paginatedItems.length,
              itemBuilder: (context, index) {
                return widget.itemBuilder(context, paginatedItems[index]);
              },
            ),
          ),
        if (totalPages > 1)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentPage > 1
                      ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                      : null,
                ),
                ...List.generate(totalPages, (index) {
                  final page = index + 1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        _currentPage == page ? Colors.blue : Colors.grey[300],
                        foregroundColor:
                        _currentPage == page ? Colors.white : Colors.black,
                        minimumSize: const Size(36, 36),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      child: Text('$page'),
                    ),
                  );
                }),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _currentPage < totalPages
                      ? () {
                    setState(() {
                      _currentPage++;
                    });
                  }
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
