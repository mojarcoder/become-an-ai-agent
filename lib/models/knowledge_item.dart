import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class KnowledgeItem extends Equatable {
  final String id;
  final String title;
  final String category;
  final String details;
  final List<String> tags;
  final String skillLevel;
  final bool isMastered;
  final DateTime createdAt;
  final DateTime updatedAt;

  const KnowledgeItem({
    required this.id,
    required this.title,
    required this.category,
    required this.details,
    required this.tags,
    required this.skillLevel,
    required this.isMastered,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for creating a new KnowledgeItem
  factory KnowledgeItem.create({
    required String title,
    required String category,
    required String details,
    required List<String> tags,
    required String skillLevel,
    bool isMastered = false,
  }) {
    final now = DateTime.now();
    return KnowledgeItem(
      id: const Uuid().v4(),
      title: title,
      category: category,
      details: details,
      tags: tags,
      skillLevel: skillLevel,
      isMastered: isMastered,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Create a copy with updated fields
  KnowledgeItem copyWith({
    String? title,
    String? category,
    String? details,
    List<String>? tags,
    String? skillLevel,
    bool? isMastered,
    DateTime? updatedAt,
  }) {
    return KnowledgeItem(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      details: details ?? this.details,
      tags: tags ?? this.tags,
      skillLevel: skillLevel ?? this.skillLevel,
      isMastered: isMastered ?? this.isMastered,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Toggle mastered status
  KnowledgeItem toggleMastered() {
    return copyWith(isMastered: !isMastered);
  }

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'details': details,
      'tags': tags,
      'skillLevel': skillLevel,
      'isMastered': isMastered,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create from map
  factory KnowledgeItem.fromMap(Map<String, dynamic> map) {
    return KnowledgeItem(
      id: map['id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      details: map['details'] as String,
      tags: List<String>.from(map['tags']),
      skillLevel: map['skillLevel'] as String,
      isMastered: map['isMastered'] as bool,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        details,
        tags,
        skillLevel,
        isMastered,
        createdAt,
        updatedAt,
      ];
} 