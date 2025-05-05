import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Project extends Equatable {
  final String id;
  final String name;
  final String description;
  final String status;
  final List<String> technologies;
  final String notes;
  final double progress;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.technologies,
    required this.notes,
    required this.progress,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for creating a new Project
  factory Project.create({
    required String name,
    required String description,
    required String status,
    required List<String> technologies,
    String notes = '',
    double progress = 0.0,
    DateTime? dueDate,
  }) {
    final now = DateTime.now();
    return Project(
      id: const Uuid().v4(),
      name: name,
      description: description,
      status: status,
      technologies: technologies,
      notes: notes,
      progress: progress,
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Create a copy with updated fields
  Project copyWith({
    String? name,
    String? description,
    String? status,
    List<String>? technologies,
    String? notes,
    double? progress,
    DateTime? dueDate,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      technologies: technologies ?? this.technologies,
      notes: notes ?? this.notes,
      progress: progress ?? this.progress,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'technologies': technologies,
      'notes': notes,
      'progress': progress,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create from map
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      status: map['status'] as String,
      technologies: List<String>.from(map['technologies']),
      notes: map['notes'] as String,
      progress: map['progress'] as double,
      dueDate: map['dueDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['dueDate']) : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        status,
        technologies,
        notes,
        progress,
        dueDate,
        createdAt,
        updatedAt,
      ];
} 