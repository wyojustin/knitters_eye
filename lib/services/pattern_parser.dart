import '../models/pattern.dart';
import '../models/pattern_row.dart';
import 'package:uuid/uuid.dart';

class PatternParser {
  static const _uuid = Uuid();

  /// Parses a simple text block into a KnittingPattern
  /// Assumes each line is a row instruction
  static KnittingPattern parseTextPattern(String title, String textContent) {
    final lines = textContent.split('\n');
    final rows = <PatternRow>[];
    
    int rowNum = 1;
    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Basic detection of RS/WS based on row number (odd=RS, even=WS is common)
      final isOdd = rowNum % 2 != 0;
      
      // Try to parse stitch symbols from the instruction
      final stitches = _parseStitchesFromText(trimmed);
      
      rows.add(PatternRow(
        rowNumber: rowNum,
        instruction: trimmed,
        chartSymbols: stitches.isNotEmpty ? stitches : null,
        rowType: isOdd ? RowType.rightSide : RowType.wrongSide,
      ));
      rowNum++;
    }

    return KnittingPattern(
      id: _uuid.v4(),
      name: title,
      rows: rows,
      format: PatternFormat.text,
    );
  }

  /// Parse stitches from text instruction
  /// Looks for patterns like "k10, p2, k10" or direct symbols
  static List<String> _parseStitchesFromText(String instruction) {
    final stitches = <String>[];
    final lowerInstruction = instruction.toLowerCase();
    
    // Pattern: k10, p2, etc.
    final pattern = RegExp(r'([kp])(\d+)');
    final matches = pattern.allMatches(lowerInstruction);
    
    if (matches.isNotEmpty) {
      for (final match in matches) {
        final stitchType = match.group(1)!;
        final count = int.parse(match.group(2)!);
        stitches.addAll(List.filled(count, stitchType));
      }
    } else {
      // Try to parse as direct symbols (e.g., "kkkppkkk" or "xxxooxxx")
      for (var char in lowerInstruction.split('')) {
        if (char == 'k' || char == 'x' || char == 'p' || char == 'o') {
          stitches.add(char);
        }
      }
    }
    
    return stitches;
  }

  /// Creates a sample ribbing pattern for testing
  /// All rows show how they appear from the RS (Right Side)
  static KnittingPattern createSampleRibbingPattern() {
    // For 2x2 ribbing, the pattern looks the same from RS on all rows
    // This is the visual appearance, not the instructions
    final visualPattern = ['p', 'p', 'k', 'k', 'p', 'p', 'k', 'k'];
    
    final rows = <PatternRow>[
      PatternRow(
        rowNumber: 1,
        instruction: 'Cast on 8 stitches',
        rowType: RowType.setup,
      ),
      PatternRow(
        rowNumber: 2,
        instruction: 'k2, p2 (repeat to end)',
        chartSymbols: List.from(visualPattern),
        rowType: RowType.rightSide,
      ),
      PatternRow(
        rowNumber: 3,
        instruction: 'p2, k2 (repeat to end)',
        chartSymbols: List.from(visualPattern), // Same visual from RS
        rowType: RowType.wrongSide,
      ),
      PatternRow(
        rowNumber: 4,
        instruction: 'k2, p2 (repeat to end)',
        chartSymbols: List.from(visualPattern),
        rowType: RowType.rightSide,
      ),
      PatternRow(
        rowNumber: 5,
        instruction: 'p2, k2 (repeat to end)',
        chartSymbols: List.from(visualPattern),
        rowType: RowType.wrongSide,
      ),
      PatternRow(
        rowNumber: 6,
        instruction: 'k2, p2 (repeat to end)',
        chartSymbols: List.from(visualPattern),
        rowType: RowType.rightSide,
      ),
      PatternRow(
        rowNumber: 7,
        instruction: 'p2, k2 (repeat to end)',
        chartSymbols: List.from(visualPattern),
        rowType: RowType.wrongSide,
      ),
      PatternRow(
        rowNumber: 8,
        instruction: 'k2, p2 (repeat to end)',
        chartSymbols: List.from(visualPattern),
        rowType: RowType.rightSide,
      ),
      PatternRow(
        rowNumber: 9,
        instruction: 'Bind off',
        rowType: RowType.setup,
      ),
    ];

    return KnittingPattern(
      id: _uuid.v4(),
      name: '2x2 Ribbing Sample',
      rows: rows,
      format: PatternFormat.chart,
    );
  }

  // Placeholder for future JSON chart parsing
  static KnittingPattern parseJsonChart(Map<String, dynamic> json) {
    // TODO: Implement JSON chart parsing
    throw UnimplementedError();
  }
}
