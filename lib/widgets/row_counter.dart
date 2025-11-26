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
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ROW',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: currentRow > 1 ? onDecrement : null,
                icon: const Icon(Icons.remove),
                iconSize: 32,
              ),
              const SizedBox(width: 24),
              Text(
                '$currentRow',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 24),
              IconButton.filled(
                onPressed: currentRow < totalRows ? onIncrement : null,
                icon: const Icon(Icons.add),
                iconSize: 32,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'of $totalRows',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
