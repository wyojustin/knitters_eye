import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/storage_service.dart';
import '../services/pattern_parser.dart';
import 'knitting_view.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  List<Project> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    final projects = await _storage.loadProjects();
    setState(() {
      _projects = projects;
      _isLoading = false;
    });
  }

  Future<void> _createNewProject() async {
    // Create a sample ribbing pattern with visual stitches
    final pattern = PatternParser.createSampleRibbingPattern();

    final project = Project(
      id: const Uuid().v4(),
      patternId: pattern.id,
      pattern: pattern,
      startDate: DateTime.now(),
    );

    await _storage.saveProject(project);
    await _loadProjects();
    
    // Show a message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Created new project with visual stitch chart!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteProject(Project project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Delete "${project.pattern.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.deleteProject(project.id);
      await _loadProjects();
    }
  }

  bool _hasVisualChart(Project project) {
    return project.pattern.rows.any((row) => 
      row.chartSymbols != null && row.chartSymbols!.isNotEmpty
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Knitter's Eye"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.gesture, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        "No projects yet",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text("Tap + to create a project with visual stitches"),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final project = _projects[index];
                    final hasVisual = _hasVisualChart(project);
                    
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        title: Row(
                          children: [
                            Expanded(child: Text(project.pattern.name)),
                            if (hasVisual)
                              const Chip(
                                label: Text('Visual', style: TextStyle(fontSize: 10)),
                                backgroundColor: Colors.green,
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.symmetric(horizontal: 4),
                              )
                            else
                              const Chip(
                                label: Text('Text Only', style: TextStyle(fontSize: 10)),
                                backgroundColor: Colors.orange,
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.symmetric(horizontal: 4),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          "Row ${project.currentRowNumber} of ${project.pattern.totalRows}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                value: project.progress,
                                backgroundColor: Colors.grey[200],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red,
                              onPressed: () => _deleteProject(project),
                              tooltip: 'Delete project',
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => KnittingView(project: project),
                            ),
                          ).then((_) => _loadProjects());
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewProject,
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
      ),
    );
  }
}
