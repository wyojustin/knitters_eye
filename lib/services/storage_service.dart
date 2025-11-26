import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';

class StorageService {
  static const String _projectsKey = 'knitting_projects';

  Future<List<Project>> loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final String? projectsJson = prefs.getString(_projectsKey);
    
    if (projectsJson == null) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(projectsJson);
      return decoded.map((item) => Project.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error loading projects: $e');
      return [];
    }
  }

  Future<void> saveProject(Project project) async {
    final projects = await loadProjects();
    final index = projects.indexWhere((p) => p.id == project.id);
    
    if (index >= 0) {
      projects[index] = project;
    } else {
      projects.add(project);
    }
    
    await _saveProjectsList(projects);
  }

  Future<void> deleteProject(String projectId) async {
    final projects = await loadProjects();
    projects.removeWhere((p) => p.id == projectId);
    await _saveProjectsList(projects);
  }

  Future<void> _saveProjectsList(List<Project> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(projects.map((p) => p.toJson()).toList());
    await prefs.setString(_projectsKey, encoded);
  }
}
