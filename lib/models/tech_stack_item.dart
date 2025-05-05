import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class TechStackItem extends Equatable {
  final String id;
  final String name;
  final String category;
  final String description;
  final List<String> tags;
  final int proficiency;
  final double skillLevel; // 1-5 rating
  final String notes;
  final double targetSkillLevel; // Goal level
  final DateTime targetDate; // When to achieve the goal
  final List<String> relatedResources; // Links to projects, tutorials, etc.
  final DateTime createdAt;
  final DateTime updatedAt;

  const TechStackItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.tags,
    required this.proficiency,
    required this.skillLevel,
    required this.notes,
    required this.targetSkillLevel,
    required this.targetDate,
    required this.relatedResources,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for creating a new TechStackItem
  factory TechStackItem.create({
    required String name,
    required String category,
    required String description,
    required List<String> tags,
    required int proficiency,
    double skillLevel = 0.0,
    String notes = '',
    double targetSkillLevel = 5.0,
    DateTime? targetDate,
    List<String> relatedResources = const [],
  }) {
    final now = DateTime.now();
    return TechStackItem(
      id: const Uuid().v4(),
      name: name,
      category: category,
      description: description,
      tags: tags,
      proficiency: proficiency,
      skillLevel: skillLevel,
      notes: notes,
      targetSkillLevel: targetSkillLevel,
      targetDate: targetDate ?? now.add(const Duration(days: 90)), // Default target 3 months from now
      relatedResources: relatedResources,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Create a copy with updated fields
  TechStackItem copyWith({
    String? name,
    String? category,
    String? description,
    List<String>? tags,
    int? proficiency,
    double? skillLevel,
    String? notes,
    double? targetSkillLevel,
    DateTime? targetDate,
    List<String>? relatedResources,
    DateTime? updatedAt,
  }) {
    return TechStackItem(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      proficiency: proficiency ?? this.proficiency,
      skillLevel: skillLevel ?? this.skillLevel,
      notes: notes ?? this.notes,
      targetSkillLevel: targetSkillLevel ?? this.targetSkillLevel,
      targetDate: targetDate ?? this.targetDate,
      relatedResources: relatedResources ?? this.relatedResources,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Calculate progress as percentage
  double get progressPercentage {
    return (skillLevel / targetSkillLevel) * 100.0;
  }

  // Check if target is achieved
  bool get isTargetAchieved {
    return skillLevel >= targetSkillLevel;
  }

  // Days remaining to target date
  int get daysRemaining {
    final now = DateTime.now();
    return targetDate.difference(now).inDays;
  }

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'tags': tags,
      'proficiency': proficiency,
      'skillLevel': skillLevel,
      'notes': notes,
      'targetSkillLevel': targetSkillLevel,
      'targetDate': targetDate.millisecondsSinceEpoch,
      'relatedResources': relatedResources,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create from map
  factory TechStackItem.fromMap(Map<String, dynamic> map) {
    return TechStackItem(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      description: map['description'] as String,
      tags: List<String>.from(map['tags']),
      proficiency: map['proficiency'] as int,
      skillLevel: map['skillLevel'] as double,
      notes: map['notes'] as String,
      targetSkillLevel: map['targetSkillLevel'] as double,
      targetDate: DateTime.fromMillisecondsSinceEpoch(map['targetDate']),
      relatedResources: List<String>.from(map['relatedResources']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        description,
        tags,
        proficiency,
        skillLevel,
        notes,
        targetSkillLevel,
        targetDate,
        relatedResources,
        createdAt,
        updatedAt,
      ];
} 