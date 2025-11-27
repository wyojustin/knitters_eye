import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/project.dart';
import '../services/storage_service.dart';
import '../widgets/row_counter.dart';
import '../widgets/stitch_chart.dart';

class KnittingView extends StatefulWidget {
  final Project project;

  const KnittingView({super.key, required this.project});

  @override
  State<KnittingView> createState() => _KnittingViewState();
}

class _KnittingViewState extends State<KnittingView> {
  late Project _project;
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _project = widget.project;
  }

  void _updateRow(int newIndex) {
    setState(() {
      _project.updateProgress(newIndex);
    });
    _storage.saveProject(_project);
  }

  void _incrementRow() {
    if (_project.currentRowIndex < _project.pattern.totalRows - 1) {
      _updateRow(_project.currentRowIndex + 1);
    }
  }

  void _decrementRow() {
    if (_project.currentRowIndex > 0) {
      _updateRow(_project.currentRowIndex - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
          _incrementRow();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_project.pattern.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                // Show pattern details
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(_project.pattern.name),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Rows: ${_project.pattern.totalRows}'),
                        Text('Format: ${_project.pattern.format.name}'),
                        if (_project.pattern.designer != null)
                          Text('Designer: ${_project.pattern.designer}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Row Counter Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RowCounter(
                currentRow: _project.currentRowNumber,
                totalRows: _project.pattern.totalRows,
                onIncrement: _incrementRow,
                onDecrement: _decrementRow,
              ),
            ),

            // Pattern Display with Stitch Chart
            Expanded(
              child: Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 2,
                child: StitchChart(
                  rows: _project.pattern.rows,
                  currentRowIndex: _project.currentRowIndex,
                  onRowTap: _updateRow,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _incrementRow,
          label: const Text('Next Row'),
          icon: const Icon(Icons.arrow_downward),
        ),
      ),
    );
  }
}
