import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Note extends Equatable {
  final String id;
  final String title;
  final String content;
  final String type;
  final List<String> tags;
  final List<String> imagePaths; // Paths to stored images
  final bool isMarkdown; // Flag to indicate markdown content
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.tags,
    required this.imagePaths,
    required this.isMarkdown,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for creating a new Note
  factory Note.create({
    required String title,
    required String content,
    required String type,
    List<String> tags = const [],
    List<String> imagePaths = const [],
    bool isMarkdown = false,
  }) {
    final now = DateTime.now();
    return Note(
      id: const Uuid().v4(),
      title: title,
      content: content,
      type: type,
      tags: tags,
      imagePaths: imagePaths,
      isMarkdown: isMarkdown,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Create a copy with updated fields
  Note copyWith({
    String? title,
    String? content,
    String? type,
    List<String>? tags,
    List<String>? imagePaths,
    bool? isMarkdown,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      imagePaths: imagePaths ?? this.imagePaths,
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
      'content': content,
      'type': type,
      'tags': tags,
      'imagePaths': imagePaths,
      'isMarkdown': isMarkdown,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create from map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      type: map['type'] as String,
      tags: List<String>.from(map['tags']),
      imagePaths: map.containsKey('imagePaths') 
          ? List<String>.from(map['imagePaths']) 
          : <String>[],
      isMarkdown: map.containsKey('isMarkdown') 
          ? map['isMarkdown'] as bool 
          : false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        type,
        tags,
        imagePaths,
        isMarkdown,
        createdAt,
        updatedAt,
      ];
}

// Helper function to create Note from map
Note noteFromMap(Map<String, dynamic> map) {
  return Note.fromMap(map);
} 