/// Represents a single row in a knitting pattern
class PatternRow {
  final int rowNumber;
  final String instruction;
  final List<String>? chartSymbols;
  final int? stitchCount;
  final RowType rowType;
  final String? notes;

  PatternRow({
    required this.rowNumber,
    required this.instruction,
    this.chartSymbols,
    this.stitchCount,
    required this.rowType,
    this.notes,
  });

  bool get isRightSide => rowType == RowType.rightSide;
  bool get isWrongSide => rowType == RowType.wrongSide;

  Map<String, dynamic> toJson() {
    return {
      'rowNumber': rowNumber,
      'instruction': instruction,
      'chartSymbols': chartSymbols,
      'stitchCount': stitchCount,
      'rowType': rowType.toString(),
      'notes': notes,
    };
  }

  factory PatternRow.fromJson(Map<String, dynamic> json) {
    return PatternRow(
      rowNumber: json['rowNumber'] as int,
      instruction: json['instruction'] as String,
      chartSymbols: (json['chartSymbols'] as List<dynamic>?)?.cast<String>(),
      stitchCount: json['stitchCount'] as int?,
      rowType: RowType.values.firstWhere(
        (e) => e.toString() == json['rowType'],
        orElse: () => RowType.rightSide,
      ),
      notes: json['notes'] as String?,
    );
  }
}

enum RowType {
  rightSide,  // RS rows
  wrongSide,  // WS rows
  setup,      // Setup rows
  repeat,     // Repeat markers
}
