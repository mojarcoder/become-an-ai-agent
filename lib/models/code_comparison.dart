import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class CodeComparison extends Equatable {
  final String id;
  final String title;
  final String description;
  final String leftCode;
  final String rightCode;
  final String leftLanguage;
  final String rightLanguage;
  final String notes;
  final List<String> tags;
  final List<String> keyDifferences;
  final List<String> similaritiesNotes;
  final List<String> screenshotPaths;
  final bool isMarkdown;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CodeComparison({
    required this.id,
    required this.title,
    required this.description,
    required this.leftCode,
    required this.rightCode,
    required this.leftLanguage,
    required this.rightLanguage,
    required this.notes,
    required this.tags,
    required this.keyDifferences,
    required this.similaritiesNotes,
    required this.screenshotPaths,
    required this.isMarkdown,
    required this.createdAt,
    required this.updatedAt,
  });

  // For backward compatibility
  String get flutterCode => leftCode;
  String get kotlinCode => rightCode;

  // Factory constructor for creating a new CodeComparison
  factory CodeComparison.create({
    required String title,
    required String description,
    required String leftCode,
    required String rightCode,
    required String leftLanguage,
    required String rightLanguage,
    String notes = '',
    List<String> tags = const [],
    List<String> keyDifferences = const [],
    List<String> similaritiesNotes = const [],
    List<String> screenshotPaths = const [],
    bool isMarkdown = false,
  }) {
    final now = DateTime.now();
    return CodeComparison(
      id: const Uuid().v4(),
      title: title,
      description: description,
      leftCode: leftCode,
      rightCode: rightCode,
      leftLanguage: leftLanguage,
      rightLanguage: rightLanguage,
      notes: notes,
      tags: tags,
      keyDifferences: keyDifferences,
      similaritiesNotes: similaritiesNotes,
      screenshotPaths: screenshotPaths,
      isMarkdown: isMarkdown,
      createdAt: now,
      updatedAt: now,
    );
  }

  // For migrating old data
  factory CodeComparison.fromLegacy({
    required String id,
    required String title,
    required String description,
    required String flutterCode,
    required String kotlinCode,
    required String notes,
    required List<String> tags,
    required List<String> keyDifferences,
    required List<String> similaritiesNotes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return CodeComparison(
      id: id,
      title: title,
      description: description,
      leftCode: flutterCode,
      rightCode: kotlinCode,
      leftLanguage: 'dart',
      rightLanguage: 'kotlin',
      notes: notes,
      tags: tags,
      keyDifferences: keyDifferences,
      similaritiesNotes: similaritiesNotes,
      screenshotPaths: const [],
      isMarkdown: false,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Create a copy with updated fields
  CodeComparison copyWith({
    String? title,
    String? description,
    String? leftCode,
    String? rightCode,
    String? leftLanguage,
    String? rightLanguage,
    String? notes,
    List<String>? tags,
    List<String>? keyDifferences,
    List<String>? similaritiesNotes,
    List<String>? screenshotPaths,
    bool? isMarkdown,
    DateTime? updatedAt,
  }) {
    return CodeComparison(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      leftCode: leftCode ?? this.leftCode,
      rightCode: rightCode ?? this.rightCode,
      leftLanguage: leftLanguage ?? this.leftLanguage,
      rightLanguage: rightLanguage ?? this.rightLanguage,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      keyDifferences: keyDifferences ?? this.keyDifferences,
      similaritiesNotes: similaritiesNotes ?? this.similaritiesNotes,
      screenshotPaths: screenshotPaths ?? this.screenshotPaths,
      isMarkdown: isMarkdown ?? this.isMarkdown,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'leftCode': leftCode,
      'rightCode': rightCode,
      'leftLanguage': leftLanguage,
      'rightLanguage': rightLanguage,
      'notes': notes,
      'tags': tags,
      'keyDifferences': keyDifferences,
      'similaritiesNotes': similaritiesNotes,
      'screenshotPaths': screenshotPaths,
      'isMarkdown': isMarkdown,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create from map
  factory CodeComparison.fromMap(Map<String, dynamic> map) {
    // Handle legacy data conversion
    if (map.containsKey('flutterCode') && !map.containsKey('leftCode')) {
      return CodeComparison(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        leftCode: map['flutterCode'] as String,
        rightCode: map['kotlinCode'] as String,
        leftLanguage: 'dart',
        rightLanguage: 'kotlin',
        notes: map['notes'] as String,
        tags: List<String>.from(map['tags']),
        keyDifferences: List<String>.from(map['keyDifferences']),
        similaritiesNotes: List<String>.from(map['similaritiesNotes']),
        screenshotPaths: map.containsKey('screenshotPaths') 
            ? List<String>.from(map['screenshotPaths']) 
            : [],
        isMarkdown: map.containsKey('isMarkdown') 
            ? map['isMarkdown'] as bool 
            : false,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      );
    }
    
    // Handle new data format
    return CodeComparison(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      leftCode: map['leftCode'] as String,
      rightCode: map['rightCode'] as String,
      leftLanguage: map['leftLanguage'] as String,
      rightLanguage: map['rightLanguage'] as String,
      notes: map['notes'] as String,
      tags: List<String>.from(map['tags']),
      keyDifferences: List<String>.from(map['keyDifferences']),
      similaritiesNotes: List<String>.from(map['similaritiesNotes']),
      screenshotPaths: List<String>.from(map['screenshotPaths']),
      isMarkdown: map['isMarkdown'] as bool,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        leftCode,
        rightCode,
        leftLanguage,
        rightLanguage,
        notes,
        tags,
        keyDifferences,
        similaritiesNotes,
        screenshotPaths,
        isMarkdown,
        createdAt,
        updatedAt,
      ];
} 