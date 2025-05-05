import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum DSACategory {
  array,
  linkedList,
  stack,
  queue,
  tree,
  graph,
  heap,
  hash,
  dynamic,
  greedy,
  sorting,
  searching,
  recursion,
  backtracking,
  bitManipulation,
  other
}

class DSAItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final DSACategory category;
  final String codeExample;
  final String complexity;
  final DateTime dateAdded;
  final DateTime lastReviewed;
  final int proficiencyLevel; // 1-5
  final bool isFavorite;
  final List<String> tags;
  final List<String> relatedProblems;
  final String notes;

  const DSAItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.codeExample,
    required this.complexity,
    required this.dateAdded,
    required this.lastReviewed,
    required this.proficiencyLevel,
    this.isFavorite = false,
    this.tags = const [],
    this.relatedProblems = const [],
    this.notes = '',
  });

  factory DSAItem.create({
    required String name,
    required String description,
    required DSACategory category,
    required String codeExample,
    required String complexity,
    int proficiencyLevel = 1,
    bool isFavorite = false,
    List<String> tags = const [],
    List<String> relatedProblems = const [],
    String notes = '',
  }) {
    return DSAItem(
      id: const Uuid().v4(),
      name: name,
      description: description,
      category: category,
      codeExample: codeExample,
      complexity: complexity,
      dateAdded: DateTime.now(),
      lastReviewed: DateTime.now(),
      proficiencyLevel: proficiencyLevel,
      isFavorite: isFavorite,
      tags: tags,
      relatedProblems: relatedProblems,
      notes: notes,
    );
  }

  DSAItem copyWith({
    String? name,
    String? description,
    DSACategory? category,
    String? codeExample,
    String? complexity,
    DateTime? lastReviewed,
    int? proficiencyLevel,
    bool? isFavorite,
    List<String>? tags,
    List<String>? relatedProblems,
    String? notes,
  }) {
    return DSAItem(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      codeExample: codeExample ?? this.codeExample,
      complexity: complexity ?? this.complexity,
      dateAdded: dateAdded,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      proficiencyLevel: proficiencyLevel ?? this.proficiencyLevel,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      relatedProblems: relatedProblems ?? this.relatedProblems,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.toString(),
      'codeExample': codeExample,
      'complexity': complexity,
      'dateAdded': dateAdded.toIso8601String(),
      'lastReviewed': lastReviewed.toIso8601String(),
      'proficiencyLevel': proficiencyLevel,
      'isFavorite': isFavorite,
      'tags': tags,
      'relatedProblems': relatedProblems,
      'notes': notes,
    };
  }

  factory DSAItem.fromJson(Map<String, dynamic> json) {
    return DSAItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: DSACategory.values.firstWhere(
        (c) => c.toString() == json['category'],
        orElse: () => DSACategory.other,
      ),
      codeExample: json['codeExample'],
      complexity: json['complexity'],
      dateAdded: DateTime.parse(json['dateAdded']),
      lastReviewed: DateTime.parse(json['lastReviewed']),
      proficiencyLevel: json['proficiencyLevel'],
      isFavorite: json['isFavorite'],
      tags: List<String>.from(json['tags']),
      relatedProblems: List<String>.from(json['relatedProblems']),
      notes: json['notes'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        codeExample,
        complexity,
        dateAdded,
        lastReviewed,
        proficiencyLevel,
        isFavorite,
        tags,
        relatedProblems,
        notes,
      ];

  static String getCategoryName(DSACategory category) {
    switch (category) {
      case DSACategory.array:
        return 'Array';
      case DSACategory.linkedList:
        return 'Linked List';
      case DSACategory.stack:
        return 'Stack';
      case DSACategory.queue:
        return 'Queue';
      case DSACategory.tree:
        return 'Tree';
      case DSACategory.graph:
        return 'Graph';
      case DSACategory.heap:
        return 'Heap';
      case DSACategory.hash:
        return 'Hash Table';
      case DSACategory.dynamic:
        return 'Dynamic Programming';
      case DSACategory.greedy:
        return 'Greedy Algorithm';
      case DSACategory.sorting:
        return 'Sorting';
      case DSACategory.searching:
        return 'Searching';
      case DSACategory.recursion:
        return 'Recursion';
      case DSACategory.backtracking:
        return 'Backtracking';
      case DSACategory.bitManipulation:
        return 'Bit Manipulation';
      case DSACategory.other:
        return 'Other';
    }
  }

  static IconData getCategoryIcon(DSACategory category) {
    switch (category) {
      case DSACategory.array:
        return Icons.grid_on;
      case DSACategory.linkedList:
        return Icons.link;
      case DSACategory.stack:
        return Icons.layers;
      case DSACategory.queue:
        return Icons.linear_scale;
      case DSACategory.tree:
        return Icons.account_tree;
      case DSACategory.graph:
        return Icons.hub;
      case DSACategory.heap:
        return Icons.landscape;
      case DSACategory.hash:
        return Icons.tag;
      case DSACategory.dynamic:
        return Icons.auto_awesome;
      case DSACategory.greedy:
        return Icons.flash_on;
      case DSACategory.sorting:
        return Icons.sort;
      case DSACategory.searching:
        return Icons.search;
      case DSACategory.recursion:
        return Icons.loop;
      case DSACategory.backtracking:
        return Icons.undo;
      case DSACategory.bitManipulation:
        return Icons.memory;
      case DSACategory.other:
        return Icons.category;
    }
  }
}

// Sample DSA items for demonstration
List<DSAItem> getSampleDSAItems() {
  return [
    DSAItem.create(
      name: 'Binary Search',
      description: 'A search algorithm that finds the position of a target value within a sorted array.',
      category: DSACategory.searching,
      codeExample: '''
int binarySearch(List<int> arr, int target) {
  int left = 0;
  int right = arr.length - 1;
  
  while (left <= right) {
    int mid = left + (right - left) ~/ 2;
    
    if (arr[mid] == target) {
      return mid;
    }
    
    if (arr[mid] < target) {
      left = mid + 1;
    } else {
      right = mid - 1;
    }
  }
  
  return -1; // Not found
}
''',
      complexity: 'Time: O(log n), Space: O(1)',
      proficiencyLevel: 4,
      tags: ['Search', 'Divide and Conquer', 'Sorted Array'],
      relatedProblems: ['Find First and Last Position', 'Search in Rotated Sorted Array'],
    ),
    DSAItem.create(
      name: 'Quick Sort',
      description: 'An efficient, in-place sorting algorithm that uses divide and conquer strategy.',
      category: DSACategory.sorting,
      codeExample: '''
void quickSort(List<int> arr, int low, int high) {
  if (low < high) {
    int pivot = partition(arr, low, high);
    quickSort(arr, low, pivot - 1);
    quickSort(arr, pivot + 1, high);
  }
}

int partition(List<int> arr, int low, int high) {
  int pivot = arr[high];
  int i = low - 1;
  
  for (int j = low; j < high; j++) {
    if (arr[j] <= pivot) {
      i++;
      swap(arr, i, j);
    }
  }
  
  swap(arr, i + 1, high);
  return i + 1;
}

void swap(List<int> arr, int i, int j) {
  int temp = arr[i];
  arr[i] = arr[j];
  arr[j] = temp;
}
''',
      complexity: 'Time: O(n log n) average, O(n²) worst, Space: O(log n)',
      proficiencyLevel: 3,
      tags: ['Sorting', 'Divide and Conquer', 'In-place'],
      relatedProblems: ['Kth Largest Element', 'Sort Colors'],
    ),
    DSAItem.create(
      name: 'Breadth-First Search',
      description: 'An algorithm for traversing or searching tree or graph data structures.',
      category: DSACategory.graph,
      codeExample: '''
void bfs(Graph graph, int startVertex) {
  List<bool> visited = List.filled(graph.vertices, false);
  Queue<int> queue = Queue<int>();
  
  visited[startVertex] = true;
  queue.add(startVertex);
  
  while (queue.isNotEmpty) {
    int vertex = queue.removeFirst();
    print(vertex);
    
    for (int adjacent in graph.adjacencyList[vertex]) {
      if (!visited[adjacent]) {
        visited[adjacent] = true;
        queue.add(adjacent);
      }
    }
  }
}
''',
      complexity: 'Time: O(V + E), Space: O(V)',
      proficiencyLevel: 3,
      tags: ['Graph', 'Traversal', 'Queue'],
      relatedProblems: ['Shortest Path in Binary Matrix', 'Word Ladder'],
    ),
  ];
} 