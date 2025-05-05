import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class DSAItem extends Equatable {
  final String id;
  final String name;
  final String category; // Array, LinkedList, Graph, Sorting, etc.
  final String type; // Data Structure or Algorithm
  final String description;
  final String complexity; // Time & Space complexity
  final String implementation;
  final String language; // dart, kotlin, etc.
  final String visualExplanation; // Could be a link to an image or diagram
  final List<String> examples; // Real-world examples of usage
  final List<String> relatedProblems; // LeetCode/HackerRank problem examples
  final List<String> tags;
  final int difficulty; // 1-5
  final DateTime createdAt;
  final DateTime updatedAt;

  const DSAItem({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    required this.description,
    required this.complexity,
    required this.implementation,
    required this.language,
    required this.visualExplanation,
    required this.examples,
    required this.relatedProblems,
    required this.tags,
    required this.difficulty,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for creating a new DSAItem
  factory DSAItem.create({
    required String name,
    required String category,
    required String type,
    required String description,
    required String complexity,
    required String implementation,
    required String language,
    String visualExplanation = '',
    List<String> examples = const [],
    List<String> relatedProblems = const [],
    List<String> tags = const [],
    int difficulty = 3,
  }) {
    final now = DateTime.now();
    return DSAItem(
      id: const Uuid().v4(),
      name: name,
      category: category,
      type: type,
      description: description,
      complexity: complexity,
      implementation: implementation,
      language: language,
      visualExplanation: visualExplanation,
      examples: examples,
      relatedProblems: relatedProblems,
      tags: tags,
      difficulty: difficulty,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Create a copy with updated fields
  DSAItem copyWith({
    String? name,
    String? category,
    String? type,
    String? description,
    String? complexity,
    String? implementation,
    String? language,
    String? visualExplanation,
    List<String>? examples,
    List<String>? relatedProblems,
    List<String>? tags,
    int? difficulty,
    DateTime? updatedAt,
  }) {
    return DSAItem(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      type: type ?? this.type,
      description: description ?? this.description,
      complexity: complexity ?? this.complexity,
      implementation: implementation ?? this.implementation,
      language: language ?? this.language,
      visualExplanation: visualExplanation ?? this.visualExplanation,
      examples: examples ?? this.examples,
      relatedProblems: relatedProblems ?? this.relatedProblems,
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
      'category': category,
      'type': type,
      'description': description,
      'complexity': complexity,
      'implementation': implementation,
      'language': language,
      'visualExplanation': visualExplanation,
      'examples': examples,
      'relatedProblems': relatedProblems,
      'tags': tags,
      'difficulty': difficulty,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create from map
  factory DSAItem.fromMap(Map<String, dynamic> map) {
    return DSAItem(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      type: map['type'] as String,
      description: map['description'] as String,
      complexity: map['complexity'] as String,
      implementation: map['implementation'] as String,
      language: map['language'] as String,
      visualExplanation: map['visualExplanation'] as String,
      examples: List<String>.from(map['examples']),
      relatedProblems: List<String>.from(map['relatedProblems']),
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
        category,
        type,
        description,
        complexity,
        implementation,
        language,
        visualExplanation,
        examples,
        relatedProblems,
        tags,
        difficulty,
        createdAt,
        updatedAt,
      ];
} 