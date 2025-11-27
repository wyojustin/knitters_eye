import 'package:flutter/material.dart';

class RowCounter extends StatelessWidget {
  final int currentRow;
  final int totalRows;

  const RowCounter({
    super.key,
    required this.currentRow,
    required this.totalRows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$currentRow/$totalRows',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
