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

  /// Creates a 20 row by 40 stitch pattern with diamond texture
  /// All rows show how they appear from the RS (Right Side)
  static KnittingPattern create20x40DiamondPattern() {
    final rows = <PatternRow>[];

    // Helper function to create a row pattern
    List<String> createRowPattern(int rowNum) {
      final pattern = <String>[];

      // Create a diamond pattern with seed stitch borders
      // 4 stitch borders + 32 stitch center = 40 stitches total

      if (rowNum == 1 || rowNum == 20) {
        // Top and bottom: alternating seed stitch across all
        for (int i = 0; i < 40; i++) {
          pattern.add(i % 2 == 0 ? 'p' : 'k');
        }
      } else {
        // Seed stitch border (4 stitches each side)
        for (int i = 0; i < 4; i++) {
          pattern.add(i % 2 == 0 ? 'p' : 'k');
        }

        // Center 32 stitches - diamond pattern
        final centerRow = rowNum - 1; // 0-indexed for calculation

        if (centerRow >= 2 && centerRow <= 9) {
          // Expanding diamond (rows 2-9)
          final purlWidth = centerRow - 1;
          final knitSide = (32 - purlWidth * 2) ~/ 2;

          for (int i = 0; i < knitSide; i++) pattern.add('k');
          for (int i = 0; i < purlWidth; i++) pattern.add('p');
          for (int i = 0; i < purlWidth; i++) pattern.add('p');
          for (int i = 0; i < knitSide; i++) pattern.add('k');
        } else if (centerRow >= 10 && centerRow <= 18) {
          // Contracting diamond (rows 10-18)
          final purlWidth = 18 - centerRow;
          final knitSide = (32 - purlWidth * 2) ~/ 2;

          for (int i = 0; i < knitSide; i++) pattern.add('k');
          for (int i = 0; i < purlWidth; i++) pattern.add('p');
          for (int i = 0; i < purlWidth; i++) pattern.add('p');
          for (int i = 0; i < knitSide; i++) pattern.add('k');
        } else {
          // Fill with stockinette
          for (int i = 0; i < 32; i++) pattern.add('k');
        }

        // Right border (4 stitches)
        for (int i = 0; i < 4; i++) {
          pattern.add(i % 2 == 0 ? 'p' : 'k');
        }
      }

      return pattern;
    }

    // Create all 20 rows
    for (int rowNum = 1; rowNum <= 20; rowNum++) {
      final visualPattern = createRowPattern(rowNum);
      final isOdd = rowNum % 2 != 0;

      String instruction;
      if (rowNum == 1 || rowNum == 20) {
        instruction = '(p1, k1) repeat to end';
      } else if (rowNum >= 3 && rowNum <= 10) {
        instruction = isOdd
            ? 'Seed st border, increasing purl diamond'
            : 'Work stitches as they appear';
      } else if (rowNum >= 11 && rowNum <= 19) {
        instruction = isOdd
            ? 'Seed st border, decreasing purl diamond'
            : 'Work stitches as they appear';
      } else {
        instruction = 'Seed stitch border, stockinette center';
      }

      rows.add(PatternRow(
        rowNumber: rowNum,
        instruction: instruction,
        chartSymbols: visualPattern,
        stitchCount: 40,
        rowType: isOdd ? RowType.rightSide : RowType.wrongSide,
      ));
    }

    return KnittingPattern(
      id: _uuid.v4(),
      name: 'Diamond Texture (20×40)',
      rows: rows,
      format: PatternFormat.chart,
      designer: 'Knitter\'s Eye',
    );
  }

  // Placeholder for future JSON chart parsing
  static KnittingPattern parseJsonChart(Map<String, dynamic> json) {
    // TODO: Implement JSON chart parsing
    throw UnimplementedError();
  }
}
