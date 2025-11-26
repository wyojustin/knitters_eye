import 'pattern.dart';
import 'pattern_row.dart';

/// Represents a user's knitting project tracking progress
class Project {
  final String id;
  final String patternId;
  final KnittingPattern pattern;
  int currentRowIndex;
  final DateTime startDate;
  DateTime? lastUpdated;
  double progress; // 0.0 to 1.0
  String? notes;

  Project({
    required this.id,
    required this.patternId,
    required this.pattern,
    this.currentRowIndex = 0,
    required this.startDate,
    this.lastUpdated,
    this.progress = 0.0,
    this.notes,
  });

  int get currentRowNumber => pattern.rows.isNotEmpty 
      ? pattern.rows[currentRowIndex].rowNumber 
      : 0;

  PatternRow? get currentRow => pattern.rows.isNotEmpty && 
      currentRowIndex >= 0 && currentRowIndex < pattern.rows.length
      ? pattern.rows[currentRowIndex]
      : null;

  void updateProgress(int newRowIndex) {
    if (newRowIndex >= 0 && newRowIndex < pattern.rows.length) {
      currentRowIndex = newRowIndex;
      progress = (currentRowIndex + 1) / pattern.totalRows;
      lastUpdated = DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patternId': patternId,
      'pattern': pattern.toJson(),
      'currentRowIndex': currentRowIndex,
      'startDate': startDate.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'progress': progress,
      'notes': notes,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      patternId: json['patternId'] as String,
      pattern: KnittingPattern.fromJson(json['pattern'] as Map<String, dynamic>),
      currentRowIndex: json['currentRowIndex'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'] as String) 
          : null,
      progress: (json['progress'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }
}
