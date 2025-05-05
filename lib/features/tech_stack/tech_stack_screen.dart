import 'package:flutter/material.dart';
import 'package:become_an_ai_agent/core/constants/app_constants.dart';
import 'package:become_an_ai_agent/core/widgets/custom_app_bar.dart';
import 'package:become_an_ai_agent/core/widgets/custom_card.dart';
import 'package:become_an_ai_agent/core/widgets/empty_state.dart';
import 'package:become_an_ai_agent/models/tech_stack_item.dart';
import 'package:become_an_ai_agent/services/database_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:become_an_ai_agent/features/tech_stack/tech_stack_editor.dart';

class TechStackScreen extends StatefulWidget {
  const TechStackScreen({super.key});

  @override
  State<TechStackScreen> createState() => _TechStackScreenState();
}

class _TechStackScreenState extends State<TechStackScreen> {
  List<TechStackItem> _items = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final List<String> _categories = ['All', ...AppConstants.knowledgeCategories];

  @override
  void initState() {
    super.initState();
    _loadTechStackItems();
  }

  Future<void> _loadTechStackItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await DatabaseService().getAllTechStackItems();
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading items: $e')),
        );
      }
    }
  }

  List<TechStackItem> get _filteredItems {
    return _items.where((item) {
      final matchesCategory = _selectedCategory == 'All' || 
                              item.category == _selectedCategory;
      
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _openTechStackEditor({TechStackItem? item}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TechStackEditor(item: item),
      ),
    );

    if (result == true) {
      _loadTechStackItems();
    }
  }

  Future<void> _deleteItem(TechStackItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
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
        await DatabaseService().deleteTechStackItem(item.id);
        _loadTechStackItems();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting item: $e')),
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
        title: 'Tech Stack',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _TechStackSearchDelegate(
                  items: _items,
                  onSelect: (item) {
                    _openTechStackEditor(item: item);
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
                // Category filter
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
                    itemCount: _categories.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Center(
                          child: ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategory = category;
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
                      hintText: 'Search tech stack items...',
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
                
                // Skills overview chart
                if (_items.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Skills Overview',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sections: _getPieChartSections(_items),
                                centerSpaceRadius: 40,
                                sectionsSpace: 2,
                                centerSpaceColor: Colors.transparent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                
                // Items list
                Expanded(
                  child: _filteredItems.isEmpty
                      ? EmptyState(
                          icon: Icons.layers,
                          title: 'No Tech Stack Items',
                          message: 'Add your first tech stack item by tapping the + button',
                          actionLabel: 'Add Item',
                          onAction: () => _openTechStackEditor(),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            return CustomCard(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ListTile(
                                title: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(item.description),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      children: item.tags.map((tag) {
                                        return Chip(
                                          label: Text(tag),
                                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                          labelStyle: TextStyle(
                                            color: theme.colorScheme.primary,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: item.proficiency / 100,
                                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Proficiency: ${item.proficiency}%',
                                      style: TextStyle(
                                        color: theme.textTheme.bodySmall?.color,
                                      ),
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
                                      _openTechStackEditor(item: item);
                                    } else if (value == 'delete') {
                                      _deleteItem(item);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTechStackEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper method to create pie chart sections from tech stack items
  List<PieChartSectionData> _getPieChartSections(List<TechStackItem> items) {
    // Limit to top 5 items by proficiency to avoid cluttering the chart
    final sortedItems = [...items]..sort((a, b) => b.proficiency.compareTo(a.proficiency));
    final topItems = sortedItems.take(5).toList();
    
    // Use a fixed set of colors
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];
    
    return List.generate(topItems.length, (i) {
      final item = topItems[i];
      return PieChartSectionData(
        color: colors[i % colors.length],
        value: item.proficiency.toDouble(),
        title: item.proficiency >= 10 ? '${item.name}\n${item.proficiency}%' : '',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }
}

class _TechStackSearchDelegate extends SearchDelegate<TechStackItem?> {
  final List<TechStackItem> items;
  final Function(TechStackItem) onSelect;

  _TechStackSearchDelegate({
    required this.items,
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
    final results = items.where((item) {
      return item.name.toLowerCase().contains(query.toLowerCase()) ||
          item.description.toLowerCase().contains(query.toLowerCase()) ||
          item.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          title: Text(item.name),
          subtitle: Text(item.description),
          onTap: () {
            onSelect(item);
            close(context, item);
          },
        );
      },
    );
  }
} 