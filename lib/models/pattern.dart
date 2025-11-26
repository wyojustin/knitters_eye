import 'pattern_row.dart';

/// Represents a complete knitting pattern
class KnittingPattern {
  final String id;
  final String name;
  final String? designer;
  final String? yarnInfo;
  final String? gauge;
  final List<PatternRow> rows;
  final PatternFormat format;
  final String? pdfPath;
  final Map<String, String>? chartLegend;  // Symbol to stitch name mapping
  final int? repeatStart;
  final int? repeatEnd;

  KnittingPattern({
    required this.id,
    required this.name,
    this.designer,
    this.yarnInfo,
    this.gauge,
    required this.rows,
    required this.format,
    this.pdfPath,
    this.chartLegend,
    this.repeatStart,
    this.repeatEnd,
  });

  int get totalRows => rows.length;

  PatternRow? getRow(int rowNumber) {
    try {
      return rows.firstWhere((row) => row.rowNumber == rowNumber);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'designer': designer,
      'yarnInfo': yarnInfo,
      'gauge': gauge,
      'rows': rows.map((r) => r.toJson()).toList(),
      'format': format.toString(),
      'pdfPath': pdfPath,
      'chartLegend': chartLegend,
      'repeatStart': repeatStart,
      'repeatEnd': repeatEnd,
    };
  }

  factory KnittingPattern.fromJson(Map<String, dynamic> json) {
    return KnittingPattern(
      id: json['id'] as String,
      name: json['name'] as String,
      designer: json['designer'] as String?,
      yarnInfo: json['yarnInfo'] as String?,
      gauge: json['gauge'] as String?,
      rows: (json['rows'] as List<dynamic>)
          .map((r) => PatternRow.fromJson(r as Map<String, dynamic>))
          .toList(),
      format: PatternFormat.values.firstWhere(
        (e) => e.toString() == json['format'],
        orElse: () => PatternFormat.text,
      ),
      pdfPath: json['pdfPath'] as String?,
      chartLegend: (json['chartLegend'] as Map<String, dynamic>?)?.cast<String, String>(),
      repeatStart: json['repeatStart'] as int?,
      repeatEnd: json['repeatEnd'] as int?,
    );
  }
}

enum PatternFormat {
  text,     // Row-by-row text instructions
  chart,    // Grid-based chart
  pdf,      // PDF file reference
}
