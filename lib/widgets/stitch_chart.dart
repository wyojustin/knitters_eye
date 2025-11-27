import 'package:flutter/material.dart';
import '../models/pattern_row.dart';

/// Widget that renders a visual stitch-by-stitch chart
class StitchChart extends StatefulWidget {
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
  State<StitchChart> createState() => _StitchChartState();
}

class _StitchChartState extends State<StitchChart> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  final Map<int, GlobalKey> _rowKeys = {};

  @override
  void initState() {
    super.initState();
    // Create keys for each row
    for (int i = 0; i < widget.rows.length; i++) {
      _rowKeys[i] = GlobalKey();
    }
    // Scroll to current row after build, with a longer delay to ensure layout is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _scrollToCurrentRow();
        }
      });
    });
  }

  @override
  void didUpdateWidget(StitchChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRowIndex != widget.currentRowIndex) {
      _scrollToCurrentRow();
    }
  }

  void _scrollToCurrentRow() {
    final currentKey = _rowKeys[widget.currentRowIndex];
    if (currentKey?.currentContext != null) {
      // Always position current row at 30% from top for good visibility
      // This works for first row and all other rows
      Scrollable.ensureVisible(
        currentKey!.currentContext!,
        alignment: 0.3, // Position current row at 30% from top
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if current row is WS - this affects how ALL rows display
    final currentRow = widget.rows.isNotEmpty && widget.currentRowIndex >= 0 && widget.currentRowIndex < widget.rows.length
        ? widget.rows[widget.currentRowIndex]
        : null;
    final currentIsWS = currentRow?.isWrongSide ?? false;

    // Reverse rows to build from bottom to top
    final reversedRows = widget.rows.reversed.toList();

    // Wrap entire ListView in horizontal scroll so all rows move together
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _horizontalScrollController,
      child: SizedBox(
        width: 2000, // Wide enough for large patterns
        child: ListView.builder(
          controller: _scrollController,
          shrinkWrap: true, // Let outer scroll view control the size
          physics: const NeverScrollableScrollPhysics(), // Disable vertical scrolling here
          reverse: false,
          itemCount: reversedRows.length,
          itemBuilder: (context, index) {
            // Calculate the actual row index in the original list
            final actualIndex = widget.rows.length - 1 - index;
            final row = reversedRows[index];

            final isCurrentRow = actualIndex == widget.currentRowIndex;
            final isCompleted = actualIndex < widget.currentRowIndex;
            final isFuture = actualIndex > widget.currentRowIndex;

            return GestureDetector(
              key: _rowKeys[actualIndex],
              onTap: () => widget.onRowTap(actualIndex),
              child: _StitchRow(
                row: row,
                isCurrentRow: isCurrentRow,
                isCompleted: isCompleted,
                isFuture: isFuture,
                currentIsWS: currentIsWS,
              ),
            );
          },
        ),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 0.5, horizontal: 8),
      child: Opacity(
        opacity: opacity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Row number - always normal
            SizedBox(
              width: 32,
              child: Text(
                '${row.rowNumber}',
                style: TextStyle(
                  fontWeight: isCurrentRow ? FontWeight.bold : FontWeight.normal,
                  fontSize: isCurrentRow ? 13 : 11,
                  color: isCurrentRow
                      ? colorScheme.onPrimaryContainer
                      : null,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 8),

            // Stitch chart
            row.chartSymbols != null && row.chartSymbols!.isNotEmpty
                ? _buildStitchGrid(context)
                : Text(
                    row.instruction,
                    style: TextStyle(
                      fontSize: isCurrentRow ? 12 : 11,
                      fontWeight: isCurrentRow ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),

            // RS/WS indicator - always normal
            const SizedBox(width: 6),
            Chip(
              label: Text(
                row.isRightSide ? 'RS' : 'WS',
                style: const TextStyle(fontSize: 9),
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
      spacing: 2,
      runSpacing: 2,
      children: stitches.map((stitch) => _StitchSymbol(
        symbol: stitch,
        isCurrentRow: isCurrentRow,
        swapKP: currentIsWS,
      )).toList(),
    );
  }
}

class _StitchSymbol extends StatelessWidget {
  final String symbol;
  final bool isCurrentRow;
  final bool swapKP;

  const _StitchSymbol({
    required this.symbol,
    required this.isCurrentRow,
    required this.swapKP,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Determine the display character and style
    String displayChar;
    Color? backgroundColor;
    Color? textColor;

    // When viewing from WS, knits appear as purls and vice versa
    var displaySymbol = symbol.toLowerCase();
    if (swapKP) {
      if (displaySymbol == 'k' || displaySymbol == 'x') {
        displaySymbol = 'p';
      } else if (displaySymbol == 'p' || displaySymbol == 'o') {
        displaySymbol = 'k';
      }
    }

    switch (displaySymbol) {
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
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: isCurrentRow
              ? colorScheme.primary.withValues(alpha: 0.5)
              : colorScheme.outline.withValues(alpha: 0.3),
          width: isCurrentRow ? 1.0 : 0.5,
        ),
        borderRadius: BorderRadius.circular(1),
      ),
      child: Center(
        child: Text(
          displayChar,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrentRow ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
