import 'package:flutter/material.dart';
import 'package:become_an_ai_agent/core/widgets/custom_app_bar.dart';
import 'package:become_an_ai_agent/core/widgets/custom_card.dart';
import 'package:become_an_ai_agent/core/widgets/empty_state.dart';
import 'package:become_an_ai_agent/models/design_pattern.dart';
import 'package:become_an_ai_agent/services/database_service.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:become_an_ai_agent/features/design_patterns/design_pattern_editor.dart';

class DesignPatternsScreen extends StatefulWidget {
  const DesignPatternsScreen({super.key});

  @override
  State<DesignPatternsScreen> createState() => _DesignPatternsScreenState();
}

class _DesignPatternsScreenState extends State<DesignPatternsScreen> {
  List<DesignPattern> _patterns = [];
  bool _isLoading = true;
  String _selectedType = 'All';
  String _selectedLanguage = 'All';
  String _searchQuery = '';
  final List<String> _patternTypes = ['All', 'Creational', 'Structural', 'Behavioral'];
  final List<String> _languages = ['All', 'dart', 'kotlin', 'swift', 'javascript', 'typescript', 
                              'python', 'java', 'cpp', 'c', 'rust', 'lua', 'yaml'];

  @override
  void initState() {
    super.initState();
    _loadPatterns();
  }

  Future<void> _loadPatterns() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final patterns = await DatabaseService().getAllDesignPatterns();
      setState(() {
        _patterns = patterns;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading patterns: $e')),
        );
      }
    }
  }

  List<DesignPattern> get _filteredPatterns {
    return _patterns.where((pattern) {
      final matchesType = _selectedType == 'All' || 
                          pattern.type == _selectedType;
      
      final matchesLanguage = _selectedLanguage == 'All' ||
                             pattern.language == _selectedLanguage;
      
      final matchesSearch = _searchQuery.isEmpty ||
          pattern.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pattern.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pattern.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      
      return matchesType && matchesLanguage && matchesSearch;
    }).toList();
  }

  void _openPatternEditor({DesignPattern? pattern}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DesignPatternEditor(pattern: pattern),
      ),
    );

    if (result == true) {
      _loadPatterns();
    }
  }

  Future<void> _deletePattern(DesignPattern pattern) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pattern'),
        content: Text('Are you sure you want to delete "${pattern.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DatabaseService().deleteDesignPattern(pattern.id);
        _loadPatterns();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Design pattern deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting pattern: $e')),
          );
        }
      }
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Creational':
        return Colors.blue;
      case 'Structural':
        return Colors.green;
      case 'Behavioral':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getLanguageColor(String language) {
    switch (language) {
      case 'dart':
        return Colors.teal;
      case 'kotlin':
        return Colors.orange;
      case 'swift':
        return Colors.red;
      case 'javascript':
      case 'typescript':
        return Colors.yellow.shade800;
      case 'python':
        return Colors.blue.shade800;
      case 'java':
        return Colors.brown;
      case 'cpp':
      case 'c':
        return Colors.indigo;
      case 'rust':
        return Colors.deepOrange;
      case 'lua':
        return Colors.blue.shade300;
      case 'yaml':
        return Colors.purple.shade300;
      default:
        return Colors.grey;
    }
  }

  IconData _getLanguageIcon(String language) {
    switch (language) {
      case 'dart':
        return Icons.flutter_dash;
      case 'kotlin':
      case 'java':
        return Icons.android;
      case 'swift':
        return Icons.apple;
      case 'javascript':
      case 'typescript':
        return Icons.javascript;
      case 'python':
        return Icons.code;
      case 'cpp':
      case 'c':
        return Icons.terminal;
      case 'rust':
        return Icons.settings;
      case 'lua':
        return Icons.architecture;
      case 'yaml':
        return Icons.data_object;
      default:
        return Icons.code;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hrs ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Syntax _getSyntaxForLanguage(String language) {
    switch (language) {
      case 'dart':
        return Syntax.DART;
      case 'kotlin':
        return Syntax.KOTLIN;
      case 'java':
        return Syntax.JAVA;
      case 'javascript':
      case 'typescript':
        return Syntax.JAVASCRIPT;
      case 'python':
        return Syntax.PYTHON;
      case 'swift':
        return Syntax.SWIFT;
      case 'cpp':
        return Syntax.CPP;
      case 'c':
        return Syntax.C;
      case 'yaml':
        return Syntax.YAML;
      case 'rust':
        return Syntax.RUST;
      case 'lua':
        return Syntax.LUA;
      default:
        return Syntax.JAVA; // Default fallback
    }
  }

  String _getLanguageDisplayName(String langCode) {
    switch(langCode) {
      case 'dart': return 'Dart (Flutter)';
      case 'kotlin': return 'Kotlin (Android)';
      case 'swift': return 'Swift (iOS)';
      case 'javascript': return 'JavaScript';
      case 'typescript': return 'TypeScript';
      case 'python': return 'Python';
      case 'java': return 'Java';
      case 'csharp': return 'C# (.NET)';
      case 'rust': return 'Rust';
      case 'go': return 'Go';
      case 'ruby': return 'Ruby';
      case 'php': return 'PHP';
      case 'cpp': return 'C++';
      case 'c': return 'C';
      case 'lua': return 'Lua';
      case 'yaml': return 'YAML';
      default: return langCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Design Patterns',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _PatternSearchDelegate(
                  patterns: _patterns,
                  onSelect: (pattern) {
                    _openPatternEditor(pattern: pattern);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Type and Language Filters
                Container(
                  constraints: const BoxConstraints(minHeight: 100),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    border: Border(
                      bottom: BorderSide(
                        color: theme.dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 8),
                        child: Text(
                          'Pattern Type:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _patternTypes.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final type = _patternTypes[index];
                            final isSelected = type == _selectedType;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Center(
                                child: ChoiceChip(
                                  label: Text(type),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedType = type;
                                      });
                                    }
                                  },
                                  backgroundColor: theme.colorScheme.surface,
                                  selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.textTheme.bodyMedium?.color,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : theme.dividerColor,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 4),
                        child: Text(
                          'Language:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _languages.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final language = _languages[index];
                            final isSelected = language == _selectedLanguage;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Center(
                                child: ChoiceChip(
                                  label: Text(
                                    language == 'All' ? language : _getLanguageDisplayName(language),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedLanguage = language;
                                      });
                                    }
                                  },
                                  backgroundColor: theme.colorScheme.surface,
                                  selectedColor: theme.colorScheme.secondary.withOpacity(0.2),
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? theme.colorScheme.secondary
                                        : theme.textTheme.bodyMedium?.color,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: isSelected
                                          ? theme.colorScheme.secondary
                                          : theme.dividerColor,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Search field
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search design patterns...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                
                // Patterns list
                Expanded(
                  child: _filteredPatterns.isEmpty
                      ? EmptyState(
                          icon: Icons.architecture,
                          title: 'No Design Patterns',
                          message: 'Add your first design pattern by tapping the + button',
                          actionLabel: 'Add Pattern',
                          onAction: () => _openPatternEditor(),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredPatterns.length,
                          itemBuilder: (context, index) {
                            final pattern = _filteredPatterns[index];
                            return CustomCard(
                              marginBottom: 16,
                              onTap: () => _openPatternEditor(pattern: pattern),
                              child: ExpansionTile(
                                title: Text(
                                  pattern.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getTypeColor(pattern.type).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            pattern.type,
                                            style: TextStyle(
                                              color: _getTypeColor(pattern.type),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: List.generate(5, (i) {
                                              return Icon(
                                                i < pattern.difficulty 
                                                  ? Icons.star 
                                                  : Icons.star_border,
                                                size: 14,
                                                color: i < pattern.difficulty
                                                  ? Colors.amber
                                                  : Colors.grey,
                                              );
                                            }),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getLanguageColor(pattern.language).withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  _getLanguageIcon(pattern.language),
                                                  size: 12,
                                                  color: _getLanguageColor(pattern.language),
                                                ),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    _getLanguageDisplayName(pattern.language),
                                                    style: TextStyle(
                                                      color: _getLanguageColor(pattern.language),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Updated: ${_formatDate(pattern.updatedAt)}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: theme.textTheme.bodySmall?.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      pattern.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _openPatternEditor(pattern: pattern);
                                    } else if (value == 'delete') {
                                      _deletePattern(pattern);
                                    }
                                  },
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Problem Solved:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(pattern.problemSolved),
                                        
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Code Example:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: double.infinity,
                                          child: SyntaxView(
                                            code: pattern.codeExample,
                                            syntax: pattern.language == 'dart' 
                                                ? Syntax.DART 
                                                : pattern.language == 'kotlin'
                                                    ? Syntax.KOTLIN
                                                    : _getSyntaxForLanguage(pattern.language),
                                            syntaxTheme: SyntaxTheme.dracula(),
                                            withZoom: true,
                                            withLinesCount: true,
                                          ),
                                        ),
                                        
                                        if (pattern.implementation.isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Implementation Notes:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(pattern.implementation),
                                        ],
                                        
                                        if (pattern.realWorldUsage.isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Real World Usage:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(pattern.realWorldUsage),
                                        ],
                                        
                                        if (pattern.additionalNotes.isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Additional Notes:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(pattern.additionalNotes),
                                        ],
                                        
                                        if (pattern.relatedPatterns.isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Related Patterns:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 8,
                                            children: pattern.relatedPatterns.map((related) {
                                              return Chip(
                                                label: Text(related),
                                                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                                labelStyle: TextStyle(
                                                  color: theme.colorScheme.primary,
                                                  fontSize: 12,
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                        
                                        if (pattern.tags.isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          Wrap(
                                            spacing: 8,
                                            children: pattern.tags.map((tag) {
                                              return Chip(
                                                label: Text('#$tag'),
                                                backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                                                labelStyle: TextStyle(
                                                  color: theme.colorScheme.secondary,
                                                  fontSize: 12,
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openPatternEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PatternSearchDelegate extends SearchDelegate<DesignPattern?> {
  final List<DesignPattern> patterns;
  final Function(DesignPattern) onSelect;

  _PatternSearchDelegate({
    required this.patterns,
    required this.onSelect,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = patterns.where((pattern) {
      return pattern.name.toLowerCase().contains(query.toLowerCase()) ||
          pattern.description.toLowerCase().contains(query.toLowerCase()) ||
          pattern.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final pattern = results[index];
        return ListTile(
          title: Text(pattern.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pattern.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getTypeColor(pattern.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      pattern.type,
                      style: TextStyle(
                        fontSize: 10,
                        color: _getTypeColor(pattern.type),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getLanguageColor(pattern.language).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getLanguageIcon(pattern.language),
                            size: 10,
                            color: _getLanguageColor(pattern.language),
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              _getLanguageDisplayName(pattern.language),
                              style: TextStyle(
                                fontSize: 10,
                                color: _getLanguageColor(pattern.language),
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getTypeColor(pattern.type).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTypeIcon(pattern.type),
              size: 24,
              color: _getTypeColor(pattern.type),
            ),
          ),
          onTap: () {
            onSelect(pattern);
            close(context, pattern);
          },
        );
      },
    );
  }

  String _getLanguageDisplayName(String langCode) {
    switch(langCode) {
      case 'dart': return 'Dart (Flutter)';
      case 'kotlin': return 'Kotlin (Android)';
      case 'swift': return 'Swift (iOS)';
      case 'javascript': return 'JavaScript';
      case 'typescript': return 'TypeScript';
      case 'python': return 'Python';
      case 'java': return 'Java';
      case 'cpp': return 'C++';
      case 'c': return 'C';
      case 'rust': return 'Rust';
      case 'lua': return 'Lua';
      case 'yaml': return 'YAML';
      default: return langCode;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Creational':
        return Icons.create_new_folder;
      case 'Structural':
        return Icons.account_tree;
      case 'Behavioral':
        return Icons.psychology;
      default:
        return Icons.architecture;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Creational':
        return Colors.blue;
      case 'Structural':
        return Colors.green;
      case 'Behavioral':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getLanguageIcon(String language) {
    switch (language) {
      case 'dart':
        return Icons.flutter_dash;
      case 'kotlin':
      case 'java':
        return Icons.android;
      case 'swift':
        return Icons.apple;
      case 'javascript':
      case 'typescript':
        return Icons.javascript;
      case 'python':
        return Icons.code;
      case 'cpp':
      case 'c':
        return Icons.terminal;
      case 'rust':
        return Icons.settings;
      case 'lua':
        return Icons.architecture;
      case 'yaml':
        return Icons.data_object;
      default:
        return Icons.code;
    }
  }

  Color _getLanguageColor(String language) {
    switch (language) {
      case 'dart':
        return Colors.teal;
      case 'kotlin':
        return Colors.orange;
      case 'swift':
        return Colors.red;
      case 'javascript':
      case 'typescript':
        return Colors.yellow.shade800;
      case 'python':
        return Colors.blue.shade800;
      case 'java':
        return Colors.brown;
      case 'cpp':
      case 'c':
        return Colors.indigo;
      case 'rust':
        return Colors.deepOrange;
      case 'lua':
        return Colors.blue.shade300;
      case 'yaml':
        return Colors.purple.shade300;
      default:
        return Colors.grey;
    }
  }
} 