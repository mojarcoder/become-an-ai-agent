import 'package:flutter/material.dart';
import 'package:become_an_ai_agent/core/widgets/custom_app_bar.dart';
import 'package:become_an_ai_agent/core/widgets/custom_card.dart';
import 'package:become_an_ai_agent/core/widgets/empty_state.dart';
import 'package:become_an_ai_agent/models/journal_entry.dart';
import 'package:become_an_ai_agent/services/database_service.dart';
import 'package:intl/intl.dart';
import 'package:become_an_ai_agent/features/journal/journal_editor.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<JournalEntry> _entries = [];
  bool _isLoading = true;
  String _filterMode = 'All';
  final List<String> _filterOptions = ['All', 'Today', 'This Week', 'This Month'];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final entries = await DatabaseService().getAllJournalEntries();
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading entries: $e')),
        );
      }
    }
  }

  List<JournalEntry> get _filteredEntries {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    List<JournalEntry> filtered = [];
    
    // Apply date filter
    switch (_filterMode) {
      case 'Today':
        filtered = _entries.where((entry) => entry.isToday).toList();
        break;
      case 'This Week':
        filtered = _entries.where((entry) => entry.isThisWeek).toList();
        break;
      case 'This Month':
        filtered = _entries.where((entry) {
          return entry.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
                 entry.date.isBefore(DateTime(now.year, now.month + 1, 1));
        }).toList();
        break;
      case 'All':
      default:
        filtered = _entries;
    }
    
    // Apply search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((entry) {
        return entry.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            entry.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            entry.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }
    
    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));
    
    return filtered;
  }

  void _openJournalEditor({JournalEntry? entry}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalEditor(entry: entry),
      ),
    );

    if (result == true) {
      _loadEntries();
    }
  }

  Future<void> _deleteEntry(JournalEntry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Are you sure you want to delete "${entry.title}"?'),
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
        await DatabaseService().deleteJournalEntry(entry.id);
        _loadEntries();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entry deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting entry: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Developer Journal',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _JournalSearchDelegate(
                  entries: _entries,
                  onSelect: (entry) {
                    _openJournalEditor(entry: entry);
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
                // Filter options
                Container(
                  height: 50,
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
                    itemCount: _filterOptions.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final filter = _filterOptions[index];
                      final isSelected = filter == _filterMode;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Center(
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _filterMode = filter;
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
                
                // Search field
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search journal entries...',
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
                
                // Entries list
                Expanded(
                  child: _filteredEntries.isEmpty
                      ? EmptyState(
                          icon: Icons.calendar_today,
                          title: 'No Journal Entries',
                          message: 'Add your first journal entry by tapping the + button',
                          actionLabel: 'Add Entry',
                          onAction: () => _openJournalEditor(),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredEntries.length,
                          itemBuilder: (context, index) {
                            final entry = _filteredEntries[index];
                            return CustomCard(
                              marginBottom: 16,
                              child: ExpansionTile(
                                title: Text(
                                  entry.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: theme.textTheme.bodySmall?.color,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          DateFormat.yMMMd().format(entry.date),
                                          style: TextStyle(
                                            color: theme.textTheme.bodySmall?.color,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: theme.textTheme.bodySmall?.color,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${entry.hoursSpent} hrs',
                                          style: TextStyle(
                                            color: theme.textTheme.bodySmall?.color,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    RatingBarIndicator(
                                      rating: entry.productivityRating,
                                      itemBuilder: (context, index) => Icon(
                                        Icons.star,
                                        color: theme.colorScheme.primary,
                                      ),
                                      itemCount: 5,
                                      itemSize: 16.0,
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
                                      _openJournalEditor(entry: entry);
                                    } else if (value == 'delete') {
                                      _deleteEntry(entry);
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
                                          'Journal Entry:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(entry.content),
                                        
                                        if (entry.learningPoints.isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Learning Points:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ...entry.learningPoints.map((point) => Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('• '),
                                                Expanded(child: Text(point)),
                                              ],
                                            ),
                                          )),
                                        ],
                                        
                                        if (entry.challenges.isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Challenges:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ...entry.challenges.map((challenge) => Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('• '),
                                                Expanded(child: Text(challenge)),
                                              ],
                                            ),
                                          )),
                                        ],
                                        
                                        if (entry.nextGoals.isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Next Goals:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ...entry.nextGoals.map((goal) => Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('• '),
                                                Expanded(child: Text(goal)),
                                              ],
                                            ),
                                          )),
                                        ],
                                        
                                        if (entry.relatedProjects.isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Related Projects:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 8,
                                            children: entry.relatedProjects.map((project) {
                                              return Chip(
                                                label: Text(project),
                                                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                                labelStyle: TextStyle(
                                                  color: theme.colorScheme.primary,
                                                  fontSize: 12,
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                        
                                        if (entry.tags.isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          Wrap(
                                            spacing: 8,
                                            children: entry.tags.map((tag) {
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
        onPressed: () => _openJournalEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _JournalSearchDelegate extends SearchDelegate<JournalEntry?> {
  final List<JournalEntry> entries;
  final Function(JournalEntry) onSelect;

  _JournalSearchDelegate({
    required this.entries,
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
    final results = entries.where((entry) {
      return entry.title.toLowerCase().contains(query.toLowerCase()) ||
          entry.content.toLowerCase().contains(query.toLowerCase()) ||
          entry.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final entry = results[index];
        return ListTile(
          title: Text(entry.title),
          subtitle: Text(
            DateFormat.yMMMd().format(entry.date),
          ),
          leading: const Icon(Icons.calendar_today),
          onTap: () {
            onSelect(entry);
            close(context, entry);
          },
        );
      },
    );
  }
} 