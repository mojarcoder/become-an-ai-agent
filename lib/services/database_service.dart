import 'dart:convert';
import 'package:become_an_ai_agent/core/constants/app_constants.dart';
import 'package:become_an_ai_agent/models/code_comparison.dart';
import 'package:become_an_ai_agent/models/design_pattern.dart';
import 'package:become_an_ai_agent/models/dsa_item.dart';
import 'package:become_an_ai_agent/models/journal_entry.dart';
import 'package:become_an_ai_agent/models/knowledge_item.dart';
import 'package:become_an_ai_agent/models/note.dart';
import 'package:become_an_ai_agent/models/project.dart';
import 'package:become_an_ai_agent/models/tech_stack_item.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  bool _isInitialized = false;

  // Boxes
  late Box<Map> _knowledgeBox;
  late Box<Map> _techStackBox;
  late Box<Map> _projectsBox;
  late Box<Map> _codeCompareBox;
  late Box<Map> _notesBox;
  late Box<Map> _designPatternsBox;
  late Box<Map> _dsaItemsBox;
  late Box<Map> _journalBox;

  // Getters
  Box<Map> get knowledgeBox => _knowledgeBox;
  Box<Map> get techStackBox => _techStackBox;
  Box<Map> get projectsBox => _projectsBox;
  Box<Map> get codeCompareBox => _codeCompareBox;
  Box<Map> get notesBox => _notesBox;
  Box<Map> get designPatternsBox => _designPatternsBox;
  Box<Map> get dsaItemsBox => _dsaItemsBox;
  Box<Map> get journalBox => _journalBox;

  // Initialize the database
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Initialize Hive for desktop/mobile only
    final appDocDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocDir.path);
    
    // Open boxes
    _knowledgeBox = await Hive.openBox<Map>(AppConstants.knowledgeBaseBox);
    _techStackBox = await Hive.openBox<Map>(AppConstants.techStackBox);
    _projectsBox = await Hive.openBox<Map>(AppConstants.projectsBox);
    _codeCompareBox = await Hive.openBox<Map>(AppConstants.codeCompareBox);
    _notesBox = await Hive.openBox<Map>(AppConstants.notesBox);
    _designPatternsBox = await Hive.openBox<Map>(AppConstants.designPatternsBox);
    _dsaItemsBox = await Hive.openBox<Map>('dsa_items');
    _journalBox = await Hive.openBox<Map>(AppConstants.journalBox);
    
    _isInitialized = true;
  }

  // Clear all data (for debugging/testing)
  Future<void> clearAllData() async {
    await _knowledgeBox.clear();
    await _techStackBox.clear();
    await _projectsBox.clear();
    await _codeCompareBox.clear();
    await _notesBox.clear();
    await _designPatternsBox.clear();
    await _dsaItemsBox.clear();
    await _journalBox.clear();
  }

  // Generic methods to handle CRUD operations
  // Convert maps to JSON-compatible types
  Map<String, dynamic> _convertMapForStorage(Map<dynamic, dynamic> map) {
    return map.map((key, value) {
      if (value is DateTime) {
        return MapEntry(key.toString(), value.millisecondsSinceEpoch);
      } else if (value is List) {
        return MapEntry(key.toString(), jsonEncode(value));
      } else if (value is Map) {
        return MapEntry(key.toString(), jsonEncode(_convertMapForStorage(value)));
      } else {
        return MapEntry(key.toString(), value);
      }
    });
  }

  // KnowledgeItem CRUD operations
  Future<void> saveKnowledgeItem(KnowledgeItem item) async {
    await _knowledgeBox.put(item.id, item.toMap());
  }

  Future<void> deleteKnowledgeItem(String id) async {
    await _knowledgeBox.delete(id);
  }

  Future<List<KnowledgeItem>> getAllKnowledgeItems() async {
    return _knowledgeBox.values
        .map((map) => KnowledgeItem.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<KnowledgeItem?> getKnowledgeItem(String id) async {
    final map = _knowledgeBox.get(id);
    if (map == null) return null;
    return KnowledgeItem.fromMap(Map<String, dynamic>.from(map));
  }

  // TechStackItem CRUD operations
  Future<void> saveTechStackItem(TechStackItem item) async {
    await _techStackBox.put(item.id, item.toMap());
  }

  Future<void> deleteTechStackItem(String id) async {
    await _techStackBox.delete(id);
  }

  Future<List<TechStackItem>> getAllTechStackItems() async {
    return _techStackBox.values
        .map((map) => TechStackItem.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<TechStackItem?> getTechStackItem(String id) async {
    final map = _techStackBox.get(id);
    if (map == null) return null;
    return TechStackItem.fromMap(Map<String, dynamic>.from(map));
  }

  // Project CRUD operations
  Future<void> saveProject(Project project) async {
    await _projectsBox.put(project.id, project.toMap());
  }

  Future<void> deleteProject(String id) async {
    await _projectsBox.delete(id);
  }

  Future<List<Project>> getAllProjects() async {
    return _projectsBox.values
        .map((map) => Project.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<Project?> getProject(String id) async {
    final map = _projectsBox.get(id);
    if (map == null) return null;
    return Project.fromMap(Map<String, dynamic>.from(map));
  }

  // CodeComparison CRUD operations
  Future<void> saveCodeComparison(CodeComparison item) async {
    await _codeCompareBox.put(item.id, item.toMap());
  }

  Future<void> deleteCodeComparison(String id) async {
    await _codeCompareBox.delete(id);
  }

  Future<List<CodeComparison>> getAllCodeComparisons() async {
    return _codeCompareBox.values
        .map((map) => CodeComparison.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<CodeComparison?> getCodeComparison(String id) async {
    final map = _codeCompareBox.get(id);
    if (map == null) return null;
    return CodeComparison.fromMap(Map<String, dynamic>.from(map));
  }

  // Note CRUD operations
  Future<void> saveNote(Note note) async {
    final Map<String, dynamic> noteMap = note.toMap();
    await _notesBox.put(note.id, noteMap);
  }

  Future<void> deleteNote(String id) async {
    // Get the note first to handle image cleanup if needed
    final note = await getNote(id);
    if (note != null && note.imagePaths.isNotEmpty) {
      // TODO: Consider cleaning up image files here if needed
    }
    await _notesBox.delete(id);
  }

  Future<List<Note>> getAllNotes() async {
    return _notesBox.values
        .map((map) => Note.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<Note?> getNote(String id) async {
    final map = _notesBox.get(id);
    if (map == null) return null;
    return Note.fromMap(Map<String, dynamic>.from(map));
  }

  // DesignPattern CRUD operations
  Future<void> saveDesignPattern(DesignPattern item) async {
    await _designPatternsBox.put(item.id, item.toMap());
  }

  Future<void> deleteDesignPattern(String id) async {
    await _designPatternsBox.delete(id);
  }

  Future<List<DesignPattern>> getAllDesignPatterns() async {
    return _designPatternsBox.values
        .map((map) => DesignPattern.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<DesignPattern?> getDesignPattern(String id) async {
    final map = _designPatternsBox.get(id);
    if (map == null) return null;
    return DesignPattern.fromMap(Map<String, dynamic>.from(map));
  }

  // DSAItem CRUD operations
  Future<void> saveDSAItem(DSAItem item) async {
    await _dsaItemsBox.put(item.id, item.toMap());
  }

  Future<void> deleteDSAItem(String id) async {
    await _dsaItemsBox.delete(id);
  }

  Future<List<DSAItem>> getAllDSAItems() async {
    return _dsaItemsBox.values
        .map((map) => DSAItem.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<DSAItem?> getDSAItem(String id) async {
    final map = _dsaItemsBox.get(id);
    if (map == null) return null;
    return DSAItem.fromMap(Map<String, dynamic>.from(map));
  }

  // JournalEntry CRUD operations
  Future<void> saveJournalEntry(JournalEntry entry) async {
    await _journalBox.put(entry.id, entry.toMap());
  }

  Future<void> deleteJournalEntry(String id) async {
    await _journalBox.delete(id);
  }

  Future<List<JournalEntry>> getAllJournalEntries() async {
    return _journalBox.values
        .map((map) => JournalEntry.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<JournalEntry?> getJournalEntry(String id) async {
    final map = _journalBox.get(id);
    if (map == null) return null;
    return JournalEntry.fromMap(Map<String, dynamic>.from(map));
  }

  // Search operations
  Future<List<JournalEntry>> searchJournalEntries(String query) async {
    query = query.toLowerCase();
    final entries = await getAllJournalEntries();
    return entries.where((entry) {
      return entry.title.toLowerCase().contains(query) || 
             entry.content.toLowerCase().contains(query) ||
             entry.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }

  Future<List<KnowledgeItem>> searchKnowledgeItems(String query) async {
    query = query.toLowerCase();
    final items = await getAllKnowledgeItems();
    return items.where((item) {
      return item.title.toLowerCase().contains(query) || 
             item.details.toLowerCase().contains(query) ||
             item.category.toLowerCase().contains(query) ||
             item.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }

  // Close database
  Future<void> close() async {
    await _knowledgeBox.close();
    await _techStackBox.close();
    await _projectsBox.close();
    await _codeCompareBox.close();
    await _notesBox.close();
    await _designPatternsBox.close();
    await _dsaItemsBox.close();
    await _journalBox.close();
  }
} 