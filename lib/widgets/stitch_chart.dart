import 'package:flutter/material.dart';
import '../models/pattern_row.dart';

/// Widget that renders a visual stitch-by-stitch chart
class StitchChart extends StatelessWidget {
  final List<PatternRow> rows;
  final int currentRowIndex;
  final Function(int) onRowTap;

  const StitchChart({
    super.key,
    required this.rows,
    required this.currentRowIndex,
    required this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if current row is WS - this affects how ALL rows display
    final currentRow = rows.isNotEmpty && currentRowIndex >= 0 && currentRowIndex < rows.length
        ? rows[currentRowIndex]
        : null;
    final currentIsWS = currentRow?.isWrongSide ?? false;

    // Reverse rows to build from bottom to top
    final reversedRows = rows.reversed.toList();
    
    return ListView.builder(
      reverse: false,
      itemCount: reversedRows.length,
      itemBuilder: (context, index) {
        // Calculate the actual row index in the original list
        final actualIndex = rows.length - 1 - index;
        final row = reversedRows[index];
        
        final isCurrentRow = actualIndex == currentRowIndex;
        final isCompleted = actualIndex < currentRowIndex;
        final isFuture = actualIndex > currentRowIndex;

        return GestureDetector(
          onTap: () => onRowTap(actualIndex),
          child: _StitchRow(
            row: row,
            isCurrentRow: isCurrentRow,
            isCompleted: isCompleted,
            isFuture: isFuture,
            currentIsWS: currentIsWS,
          ),
        );
      },
    );
  }
}

class _StitchRow extends StatelessWidget {
  final PatternRow row;
  final bool isCurrentRow;
  final bool isCompleted;
  final bool isFuture;
  final bool currentIsWS;

  const _StitchRow({
    required this.row,
    required this.isCurrentRow,
    required this.isCompleted,
    required this.isFuture,
    required this.currentIsWS,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Determine background color based on state
    Color? backgroundColor;
    if (isCurrentRow) {
      backgroundColor = colorScheme.primaryContainer;
    }
    
    // Determine opacity based on state
    double opacity = 1.0;
    if (isCompleted) {
      opacity = 0.5;
    } else if (isFuture) {
      opacity = 0.3;
    }

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Opacity(
        opacity: opacity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Row number - always normal
            SizedBox(
              width: 40,
              child: Text(
                '${row.rowNumber}',
                style: TextStyle(
                  fontWeight: isCurrentRow ? FontWeight.bold : FontWeight.normal,
                  fontSize: isCurrentRow ? 16 : 14,
                  color: isCurrentRow 
                      ? colorScheme.onPrimaryContainer
                      : null,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 12),
            
            // Stitch chart
            Expanded(
              child: row.chartSymbols != null && row.chartSymbols!.isNotEmpty
                  ? _buildStitchGrid(context)
                  : Text(
                      row.instruction,
                      style: TextStyle(
                        fontSize: isCurrentRow ? 16 : 14,
                        fontWeight: isCurrentRow ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
            ),
            
            // RS/WS indicator - always normal
            const SizedBox(width: 8),
            Chip(
              label: Text(
                row.isRightSide ? 'RS' : 'WS',
                style: const TextStyle(fontSize: 10),
              ),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStitchGrid(BuildContext context) {
    var stitches = row.chartSymbols!;
    
    // KNITTER'S EYE PERSPECTIVE:
    // When you're on a WS row, you've flipped your work
    // So ALL rows appear reversed from your perspective
    if (currentIsWS) {
      stitches = stitches.reversed.toList();
    }
    
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: stitches.map((stitch) => _StitchSymbol(
        symbol: stitch,
        isCurrentRow: isCurrentRow,
      )).toList(),
    );
  }
}

class _StitchSymbol extends StatelessWidget {
  final String symbol;
  final bool isCurrentRow;

  const _StitchSymbol({
    required this.symbol,
    required this.isCurrentRow,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Determine the display character and style
    String displayChar;
    Color? backgroundColor;
    Color? textColor;
    
    switch (symbol.toLowerCase()) {
      case 'k':
      case 'x':
        displayChar = '×'; // Knit stitch
        backgroundColor = colorScheme.surface;
        textColor = colorScheme.onSurface;
        break;
      case 'p':
      case 'o':
        displayChar = '•'; // Purl stitch
        backgroundColor = colorScheme.surfaceContainerHighest;
        textColor = colorScheme.onSurface;
        break;
      default:
        displayChar = symbol;
        backgroundColor = colorScheme.surface;
        textColor = colorScheme.onSurface;
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: isCurrentRow 
              ? colorScheme.primary.withValues(alpha: 0.5)
              : colorScheme.outline.withValues(alpha: 0.3),
          width: isCurrentRow ? 1.5 : 0.5,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Text(
          displayChar,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isCurrentRow ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
