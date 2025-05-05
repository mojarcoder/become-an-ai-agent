import 'dart:io';
import 'package:flutter/material.dart';
import 'package:become_an_ai_agent/core/widgets/custom_app_bar.dart';
import 'package:become_an_ai_agent/core/widgets/custom_card.dart';
import 'package:become_an_ai_agent/core/widgets/empty_state.dart';
import 'package:become_an_ai_agent/models/code_comparison.dart';
import 'package:become_an_ai_agent/services/database_service.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:become_an_ai_agent/features/code_compare/code_compare_editor.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class CodeCompareScreen extends StatefulWidget {
  const CodeCompareScreen({super.key});

  @override
  State<CodeCompareScreen> createState() => _CodeCompareScreenState();
}

class _CodeCompareScreenState extends State<CodeCompareScreen> {
  List<CodeComparison> _comparisons = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedLanguage = 'All';
  
  final List<String> _languages = ['All', 'dart', 'kotlin', 'swift', 'javascript', 'typescript', 
                              'python', 'java', 'cpp', 'c', 'rust', 'lua', 'yaml',
                              'html', 'css', 'json', 'xml', 'sql', 'shell', 'go', 'php', 'ruby'];

  @override
  void initState() {
    super.initState();
    _loadComparisons();
  }

  Future<void> _loadComparisons() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final comparisons = await DatabaseService().getAllCodeComparisons();
      setState(() {
        _comparisons = comparisons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading comparisons: $e')),
        );
      }
    }
  }

  List<CodeComparison> get _filteredComparisons {
    if (_searchQuery.isEmpty && _selectedLanguage == 'All') {
      return _comparisons;
    }
    
    return _comparisons.where((comparison) {
      final matchesSearch = _searchQuery.isEmpty ||
          comparison.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          comparison.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          comparison.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
          
      final matchesLanguage = _selectedLanguage == 'All' ||
          comparison.leftLanguage == _selectedLanguage ||
          comparison.rightLanguage == _selectedLanguage;
          
      return matchesSearch && matchesLanguage;
    }).toList();
  }

  void _openCodeCompareEditor({CodeComparison? comparison}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CodeCompareEditor(comparison: comparison),
      ),
    );

    if (result == true) {
      _loadComparisons();
    }
  }

  Future<void> _deleteComparison(CodeComparison comparison) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comparison'),
        content: Text('Are you sure you want to delete "${comparison.title}"?'),
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
        await DatabaseService().deleteCodeComparison(comparison.id);
        _loadComparisons();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Comparison deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting comparison: $e')),
          );
        }
      }
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
      case 'cpp': return 'C++';
      case 'c': return 'C';
      case 'rust': return 'Rust';
      case 'lua': return 'Lua';
      case 'yaml': return 'YAML';
      case 'html': return 'HTML';
      case 'css': return 'CSS';
      case 'json': return 'JSON';
      case 'xml': return 'XML';
      case 'sql': return 'SQL';
      case 'shell': return 'Shell/Bash';
      case 'go': return 'Go';
      case 'php': return 'PHP';
      case 'ruby': return 'Ruby';
      default: return langCode;
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
        return Syntax.JAVASCRIPT; // Default fallback
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
      case 'html':
        return Colors.orange.shade800;
      case 'css':
        return Colors.blue;
      case 'json':
        return Colors.green;
      case 'xml':
        return Colors.purple;
      case 'sql':
        return Colors.blueGrey;
      case 'shell':
        return Colors.grey.shade800;
      case 'go':
        return Colors.cyan;
      case 'php':
        return Colors.indigo.shade300;
      case 'ruby':
        return Colors.red.shade800;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Code Compare',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _CodeSearchDelegate(
                  comparisons: _comparisons,
                  onSelect: (comparison) {
                    _openCodeCompareEditor(comparison: comparison);
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
                // Language filter
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    border: Border(
                      bottom: BorderSide(
                        color: theme.dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _languages.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemBuilder: (context, index) {
                      final language = _languages[index];
                      final isSelected = language == _selectedLanguage;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            language == 'All' ? language : _getLanguageDisplayName(language),
                            style: TextStyle(
                              fontSize: 12,
                            ),
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
                          selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.textTheme.bodyMedium?.color,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Search field
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search code comparisons...',
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
                
                // Comparisons list
                Expanded(
                  child: _filteredComparisons.isEmpty
                      ? EmptyState(
                          icon: Icons.compare_arrows,
                          title: 'No Code Comparisons',
                          message: 'Add your first code comparison by tapping the + button',
                          actionLabel: 'Add Comparison',
                          onAction: () => _openCodeCompareEditor(),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredComparisons.length,
                          itemBuilder: (context, index) {
                            final comparison = _filteredComparisons[index];
                            return CustomCard(
                              marginBottom: 16,
                              child: ExpansionTile(
                                title: Text(
                                  comparison.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comparison.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getLanguageColor(comparison.leftLanguage).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _getLanguageDisplayName(comparison.leftLanguage),
                                            style: TextStyle(
                                              color: _getLanguageColor(comparison.leftLanguage),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.compare_arrows, size: 12),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getLanguageColor(comparison.rightLanguage).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _getLanguageDisplayName(comparison.rightLanguage),
                                            style: TextStyle(
                                              color: _getLanguageColor(comparison.rightLanguage),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
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
                                      _openCodeCompareEditor(comparison: comparison);
                                    } else if (value == 'delete') {
                                      _deleteComparison(comparison);
                                    }
                                  },
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _getLanguageDisplayName(comparison.leftLanguage),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: _getLanguageColor(comparison.leftLanguage),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                _getLanguageDisplayName(comparison.rightLanguage),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: _getLanguageColor(comparison.rightLanguage),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: SyntaxView(
                                                  code: comparison.leftCode,
                                                  syntax: _getSyntaxForLanguage(comparison.leftLanguage),
                                                  syntaxTheme: SyntaxTheme.dracula(),
                                                  withZoom: true,
                                                  withLinesCount: true,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: SyntaxView(
                                                  code: comparison.rightCode,
                                                  syntax: _getSyntaxForLanguage(comparison.rightLanguage),
                                                  syntaxTheme: SyntaxTheme.dracula(),
                                                  withZoom: true,
                                                  withLinesCount: true,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        if (comparison.keyDifferences.isNotEmpty) ...[
                                          const SizedBox(height: 24),
                                          const Text(
                                            'Key Differences:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ...comparison.keyDifferences.map((diff) => Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                                                Expanded(child: Text(diff)),
                                              ],
                                            ),
                                          )),
                                        ],
                                        
                                        if (comparison.similaritiesNotes.isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Similarities:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ...comparison.similaritiesNotes.map((similarity) => Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                                                Expanded(child: Text(similarity)),
                                              ],
                                            ),
                                          )),
                                        ],
                                        
                                        if (comparison.screenshotPaths.isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Screenshots:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            height: 150,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: comparison.screenshotPaths.length,
                                              itemBuilder: (context, index) {
                                                final screenshotPath = comparison.screenshotPaths[index];
                                                return Padding(
                                                  padding: const EdgeInsets.only(right: 8),
                                                  child: GestureDetector(
                                                    onTap: () => _showFullScreenImage(context, screenshotPath),
                                                    child: Container(
                                                      width: 150,
                                                      height: 150,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: theme.dividerColor),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(8),
                                                        child: _buildImageWithFallback(screenshotPath),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                        
                                        if (comparison.notes.isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Notes:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          if (comparison.isMarkdown)
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: theme.dividerColor,
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: const EdgeInsets.all(16),
                                              child: MarkdownBody(
                                                data: comparison.notes,
                                                extensionSet: md.ExtensionSet.gitHubWeb,
                                                selectable: true,
                                                styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                                                  codeblockDecoration: BoxDecoration(
                                                    color: theme.colorScheme.surfaceContainerHighest,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                ),
                                              ),
                                            )
                                          else
                                            Text(comparison.notes),
                                        ],
                                        
                                        if (comparison.tags.isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          Wrap(
                                            spacing: 8,
                                            children: comparison.tags.map((tag) {
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
        onPressed: () => _openCodeCompareEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _showFullScreenImage(BuildContext context, String imagePath) {
    final File imageFile = File(imagePath);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Container(
            color: Colors.black,
            child: Center(
              child: FutureBuilder<bool>(
                future: imageFile.exists(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  
                  final fileExists = snapshot.data == true;
                  
                  if (!fileExists) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'Image not found',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          imagePath,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }
                  
                  return InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.broken_image, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            const Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error.toString(),
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWithFallback(String imagePath) {
    final File imageFile = File(imagePath);
    
    return FutureBuilder<bool>(
      future: imageFile.exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        
        final fileExists = snapshot.data == true;
        
        if (!fileExists) {
          return Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          );
        }
        
        return Image.file(
          imageFile,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.red),
              ),
            );
          },
        );
      },
    );
  }
}

class _CodeSearchDelegate extends SearchDelegate<CodeComparison?> {
  final List<CodeComparison> comparisons;
  final Function(CodeComparison) onSelect;

  _CodeSearchDelegate({
    required this.comparisons,
    required this.onSelect,
  });
  
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
      case 'html': return 'HTML';
      case 'css': return 'CSS';
      case 'json': return 'JSON';
      case 'xml': return 'XML';
      case 'sql': return 'SQL';
      case 'shell': return 'Shell/Bash';
      case 'go': return 'Go';
      case 'php': return 'PHP';
      case 'ruby': return 'Ruby';
      default: return langCode;
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
    final results = comparisons.where((comparison) {
      return comparison.title.toLowerCase().contains(query.toLowerCase()) ||
          comparison.description.toLowerCase().contains(query.toLowerCase()) ||
          comparison.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final comparison = results[index];
        return ListTile(
          title: Text(comparison.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comparison.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getLanguageColor(comparison.leftLanguage).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getLanguageDisplayName(comparison.leftLanguage),
                      style: TextStyle(
                        fontSize: 10,
                        color: _getLanguageColor(comparison.leftLanguage),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.compare_arrows, size: 10),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getLanguageColor(comparison.rightLanguage).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getLanguageDisplayName(comparison.rightLanguage),
                      style: TextStyle(
                        fontSize: 10,
                        color: _getLanguageColor(comparison.rightLanguage),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.grey.withOpacity(0.2),
            child: const Icon(Icons.code),
          ),
          onTap: () {
            onSelect(comparison);
            close(context, comparison);
          },
        );
      },
    );
  }
} 