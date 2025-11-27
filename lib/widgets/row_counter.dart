import 'package:flutter/material.dart';

class RowCounter extends StatelessWidget {
  final int currentRow;
  final int totalRows;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const RowCounter({
    super.key,
    required this.currentRow,
    required this.totalRows,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(vertical: 4, horizontal: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton.filledTonal(
            onPressed: currentRow > 1 ? onDecrement : null,
            icon: const Icon(Icons.remove),
            iconSize: 24,
          ),
          const SizedBox(width: 16),
          Text(
            '$currentRow/$totalRows',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          IconButton.filled(
            onPressed: currentRow < totalRows ? onIncrement : null,
            icon: const Icon(Icons.add),
            iconSize: 24,
          ),
        ],
      ),
    );
  }
}
