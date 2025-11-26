import 'package:flutter/material.dart';
import '../models/pattern.dart';
// import '../models/pattern_row.dart'; // Analyzer said this was unused

class PatternChart extends StatelessWidget {
  final KnittingPattern pattern;
  final int currentRowIndex;
  final Function(int) onRowTap;

  const PatternChart({
    super.key,
    required this.pattern,
    required this.currentRowIndex,
    required this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    // Scroll to keep current row in middle
    // This is a simplified implementation; a ScrollController would be better
    
    return ListView.builder(
      itemCount: pattern.rows.length,
      itemBuilder: (context, index) {
        // Invert index so row 1 is at bottom if we want bottom-up, 
        // but standard lists are top-down. 
        // Let's stick to standard top-down list for text patterns for now,
        // but highlight the current row.
        
        final row = pattern.rows[index];
        final isCurrentRow = index == currentRowIndex;
        final isCompleted = index < currentRowIndex;
        final isFuture = index > currentRowIndex;

        return GestureDetector(
          onTap: () => onRowTap(index),
          child: Container(
            color: isCurrentRow 
                ? Theme.of(context).colorScheme.primaryContainer 
                : null,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Opacity(
              opacity: isFuture ? 0.5 : (isCompleted ? 0.7 : 1.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${row.rowNumber}',
                      style: TextStyle(
                        fontWeight: isCurrentRow ? FontWeight.bold : FontWeight.normal,
                        color: isCurrentRow 
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.instruction,
                          style: TextStyle(
                            fontSize: isCurrentRow ? 18 : 16,
                            fontWeight: isCurrentRow ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (row.notes != null)
                          Text(
                            row.notes!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (row.isRightSide)
                    const Chip(label: Text('RS'), visualDensity: VisualDensity.compact)
                  else
                    const Chip(label: Text('WS'), visualDensity: VisualDensity.compact),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
