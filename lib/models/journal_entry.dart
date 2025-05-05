import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class JournalEntry extends Equatable {
  final String id;
  final DateTime date;
  final String title;
  final String content;
  final List<String> learningPoints;
  final List<String> challenges;
  final List<String> nextGoals;
  final double productivityRating; // 1-5
  final int hoursSpent;
  final List<String> tags;
  final List<String> relatedProjects;
  final List<String> resources; // URLs, book names, etc.
  final DateTime createdAt;
  final DateTime updatedAt;

  const JournalEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    required this.learningPoints,
    required this.challenges,
    required this.nextGoals,
    required this.productivityRating,
    required this.hoursSpent,
    required this.tags,
    required this.relatedProjects,
    required this.resources,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for creating a new JournalEntry
  factory JournalEntry.create({
    DateTime? date,
    required String title,
    required String content,
    List<String> learningPoints = const [],
    List<String> challenges = const [],
    List<String> nextGoals = const [],
    double productivityRating = 3.0,
    int hoursSpent = 0,
    List<String> tags = const [],
    List<String> relatedProjects = const [],
    List<String> resources = const [],
  }) {
    final now = DateTime.now();
    return JournalEntry(
      id: const Uuid().v4(),
      date: date ?? DateTime(now.year, now.month, now.day),
      title: title,
      content: content,
      learningPoints: learningPoints,
      challenges: challenges,
      nextGoals: nextGoals,
      productivityRating: productivityRating,
      hoursSpent: hoursSpent,
      tags: tags,
      relatedProjects: relatedProjects,
      resources: resources,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Create a copy with updated fields
  JournalEntry copyWith({
    DateTime? date,
    String? title,
    String? content,
    List<String>? learningPoints,
    List<String>? challenges,
    List<String>? nextGoals,
    double? productivityRating,
    int? hoursSpent,
    List<String>? tags,
    List<String>? relatedProjects,
    List<String>? resources,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id,
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
      learningPoints: learningPoints ?? this.learningPoints,
      challenges: challenges ?? this.challenges,
      nextGoals: nextGoals ?? this.nextGoals,
      productivityRating: productivityRating ?? this.productivityRating,
      hoursSpent: hoursSpent ?? this.hoursSpent,
      tags: tags ?? this.tags,
      relatedProjects: relatedProjects ?? this.relatedProjects,
      resources: resources ?? this.resources,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Check if entry is for today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Check if entry is for this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'title': title,
      'content': content,
      'learningPoints': learningPoints,
      'challenges': challenges,
      'nextGoals': nextGoals,
      'productivityRating': productivityRating,
      'hoursSpent': hoursSpent,
      'tags': tags,
      'relatedProjects': relatedProjects,
      'resources': resources,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create from map
  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      title: map['title'] as String,
      content: map['content'] as String,
      learningPoints: List<String>.from(map['learningPoints']),
      challenges: List<String>.from(map['challenges']),
      nextGoals: List<String>.from(map['nextGoals']),
      productivityRating: map['productivityRating'] as double,
      hoursSpent: map['hoursSpent'] as int,
      tags: List<String>.from(map['tags']),
      relatedProjects: List<String>.from(map['relatedProjects']),
      resources: List<String>.from(map['resources']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        title,
        content,
        learningPoints,
        challenges,
        nextGoals,
        productivityRating,
        hoursSpent,
        tags,
        relatedProjects,
        resources,
        createdAt,
        updatedAt,
      ];
} 