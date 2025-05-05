import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class DesignPattern extends Equatable {
  final String id;
  final String name;
  final String type; // Creational, Structural, Behavioral
  final String description;
  final String problemSolved;
  final String codeExample;
  final String language; // dart, kotlin, etc.
  final String implementation;
  final String realWorldUsage;
  final String additionalNotes;
  final List<String> relatedPatterns;
  final List<String> tags;
  final int difficulty; // 1-5
  final DateTime createdAt;
  final DateTime updatedAt;

  const DesignPattern({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.problemSolved,
    required this.codeExample,
    required this.language,
    required this.implementation,
    required this.realWorldUsage,
    required this.additionalNotes,
    required this.relatedPatterns,
    required this.tags,
    required this.difficulty,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for creating a new DesignPattern
  factory DesignPattern.create({
    required String name,
    required String type,
    required String description,
    required String problemSolved,
    required String codeExample,
    required String language,
    String implementation = '',
    String realWorldUsage = '',
    String additionalNotes = '',
    List<String> relatedPatterns = const [],
    List<String> tags = const [],
    int difficulty = 3,
  }) {
    final now = DateTime.now();
    return DesignPattern(
      id: const Uuid().v4(),
      name: name,
      type: type,
      description: description,
      problemSolved: problemSolved,
      codeExample: codeExample,
      language: language,
      implementation: implementation,
      realWorldUsage: realWorldUsage,
      additionalNotes: additionalNotes,
      relatedPatterns: relatedPatterns,
      tags: tags,
      difficulty: difficulty,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Create a copy with updated fields
  DesignPattern copyWith({
    String? name,
    String? type,
    String? description,
    String? problemSolved,
    String? codeExample,
    String? language,
    String? implementation,
    String? realWorldUsage,
    String? additionalNotes,
    List<String>? relatedPatterns,
    List<String>? tags,
    int? difficulty,
    DateTime? updatedAt,
  }) {
    return DesignPattern(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      problemSolved: problemSolved ?? this.problemSolved,
      codeExample: codeExample ?? this.codeExample,
      language: language ?? this.language,
      implementation: implementation ?? this.implementation,
      realWorldUsage: realWorldUsage ?? this.realWorldUsage,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      relatedPatterns: relatedPatterns ?? this.relatedPatterns,
      tags: tags ?? this.tags,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'problemSolved': problemSolved,
      'codeExample': codeExample,
      'language': language,
      'implementation': implementation,
      'realWorldUsage': realWorldUsage,
      'additionalNotes': additionalNotes,
      'relatedPatterns': relatedPatterns,
      'tags': tags,
      'difficulty': difficulty,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create from map
  factory DesignPattern.fromMap(Map<String, dynamic> map) {
    return DesignPattern(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      description: map['description'] as String,
      problemSolved: map['problemSolved'] as String,
      codeExample: map['codeExample'] as String,
      language: map['language'] as String,
      implementation: map['implementation'] as String,
      realWorldUsage: map['realWorldUsage'] as String,
      additionalNotes: map['additionalNotes'] as String,
      relatedPatterns: List<String>.from(map['relatedPatterns']),
      tags: List<String>.from(map['tags']),
      difficulty: map['difficulty'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        description,
        problemSolved,
        codeExample,
        language,
        implementation,
        realWorldUsage,
        additionalNotes,
        relatedPatterns,
        tags,
        difficulty,
        createdAt,
        updatedAt,
      ];
} 