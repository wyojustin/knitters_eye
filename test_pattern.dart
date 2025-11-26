import 'lib/services/pattern_parser.dart';

void main() {
  final pattern = PatternParser.createSampleRibbingPattern();
  
  print('Pattern: ${pattern.name}');
  print('Total rows: ${pattern.totalRows}');
  print('\nRows:');
  
  for (var row in pattern.rows) {
    print('\nRow ${row.rowNumber}: ${row.instruction}');
    if (row.chartSymbols != null) {
      print('  Stitches: ${row.chartSymbols!.join(" ")}');
      print('  Count: ${row.chartSymbols!.length}');
    } else {
      print('  No chart symbols (setup/bind off row)');
    }
  }
}
