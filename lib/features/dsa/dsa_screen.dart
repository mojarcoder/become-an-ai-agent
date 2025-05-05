import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:become_an_ai_agent/models/dsa_model.dart';
import 'package:become_an_ai_agent/features/dsa/dsa_provider.dart';
import 'package:become_an_ai_agent/features/dsa/dsa_detail_screen.dart';
import 'package:become_an_ai_agent/features/dsa/dsa_form_screen.dart';
import 'package:become_an_ai_agent/core/widgets/custom_app_bar.dart';
import 'package:become_an_ai_agent/core/widgets/custom_card.dart';
import 'package:become_an_ai_agent/core/widgets/empty_state.dart';
import 'package:become_an_ai_agent/core/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class DSAScreen extends StatelessWidget {
  const DSAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DSAProvider(),
      child: const DSAScreenContent(),
    );
  }
}

class DSAScreenContent extends StatefulWidget {
  const DSAScreenContent({super.key});

  @override
  State<DSAScreenContent> createState() => _DSAScreenContentState();
}

class _DSAScreenContentState extends State<DSAScreenContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Data Structures & Algorithms',
      ),
      body: Column(
        children: [
          Container(
            color: colorScheme.primaryContainer.withOpacity(0.3),
            child: TabBar(
              controller: _tabController,
              indicatorColor: colorScheme.primary,
              labelColor: colorScheme.primary,
              unselectedLabelColor: AppTheme.getTextOnColor(colorScheme.surface, highEmphasis: false),
              tabs: const [
                Tab(
                  icon: Icon(Icons.list),
                  text: 'All Items',
                ),
                Tab(
                  icon: Icon(Icons.star),
                  text: 'Favorites',
                ),
                Tab(
                  icon: Icon(Icons.bar_chart),
                  text: 'Analytics',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                DSAListTab(),
                DSAFavoritesTab(),
                DSAAnalyticsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DSAFormScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add New'),
        backgroundColor: colorScheme.primary,
        foregroundColor: AppTheme.getBestForegroundColor(colorScheme.primary),
      ),
    );
  }
}

class DSAListTab extends StatefulWidget {
  const DSAListTab({super.key});

  @override
  State<DSAListTab> createState() => _DSAListTabState();
}

class _DSAListTabState extends State<DSAListTab> {
  @override
  Widget build(BuildContext context) {
    final dsaProvider = Provider.of<DSAProvider>(context);
    final filteredItems = dsaProvider.getFilteredItems();
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Field
              TextField(
                onChanged: (value) => dsaProvider.setSearchQuery(value),
                decoration: InputDecoration(
                  hintText: 'Search DSA items...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppTheme.getTextOnColor(colorScheme.surface, highEmphasis: false),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              
              // Category Filter
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: const Text('All'),
                        selected: dsaProvider.selectedCategory == null,
                        onSelected: (_) => dsaProvider.setSelectedCategory(null),
                        selectedColor: colorScheme.primaryContainer,
                        checkmarkColor: colorScheme.primary,
                        labelStyle: TextStyle(
                          color: dsaProvider.selectedCategory == null
                              ? colorScheme.primary
                              : null,
                        ),
                      ),
                    ),
                    ...DSACategory.values.map((category) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(
                          DSAItem.getCategoryName(category),
                          style: TextStyle(
                            color: dsaProvider.selectedCategory == category
                                ? colorScheme.primary
                                : null,
                          ),
                        ),
                        selected: dsaProvider.selectedCategory == category,
                        onSelected: (_) => dsaProvider.setSelectedCategory(category),
                        selectedColor: colorScheme.primaryContainer,
                        checkmarkColor: colorScheme.primary,
                        avatar: Icon(
                          DSAItem.getCategoryIcon(category),
                          size: 16,
                          color: dsaProvider.selectedCategory == category
                              ? colorScheme.primary
                              : AppTheme.getTextOnColor(colorScheme.surface, highEmphasis: false),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // DSA Item List
        Expanded(
          child: filteredItems.isEmpty
              ? const EmptyState(
                  icon: Icons.code,
                  title: 'No DSA items found',
                  message: 'Add your first DSA item using the button below',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return _buildDSAItemCard(context, item);
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildDSAItemCard(BuildContext context, DSAItem item) {
    final dsaProvider = Provider.of<DSAProvider>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;
    final containerColor = colorScheme.primaryContainer;
    final iconColor = colorScheme.primary;
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DSADetailScreen(dsaItem: item),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      DSAItem.getCategoryIcon(item.category),
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getTextOnColor(colorScheme.surface, highEmphasis: true),
                          ),
                        ),
                        Text(
                          DSAItem.getCategoryName(item.category),
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      item.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: item.isFavorite ? Colors.red : AppTheme.getTextOnColor(colorScheme.surface, highEmphasis: false),
                    ),
                    onPressed: () => dsaProvider.toggleFavorite(item.id),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.getTextOnColor(colorScheme.surface, highEmphasis: false),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time, 
                    size: 14,
                    color: AppTheme.getTextOnColor(colorScheme.surface, highEmphasis: false),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Last reviewed ${_formatDate(item.lastReviewed)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.getTextOnColor(colorScheme.surface, highEmphasis: false),
                    ),
                  ),
                  const Spacer(),
                  RatingBar.builder(
                    initialRating: item.proficiencyLevel.toDouble(),
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemSize: 18,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 1),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      dsaProvider.updateProficiencyLevel(
                        item.id,
                        rating.toInt(),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: item.tags.map((tag) {
                  return Chip(
                    label: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.getBestForegroundColor(colorScheme.primaryContainer),
                      ),
                    ),
                    backgroundColor: colorScheme.primaryContainer.withOpacity(0.5),
                    labelStyle: const TextStyle(fontSize: 10),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }
}

class DSAFavoritesTab extends StatelessWidget {
  const DSAFavoritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dsaProvider = Provider.of<DSAProvider>(context);
    final favoriteItems = dsaProvider.getFavoriteItems();
    final colorScheme = Theme.of(context).colorScheme;
    
    return favoriteItems.isEmpty
        ? const EmptyState(
            icon: Icons.favorite,
            title: 'No favorites yet',
            message: 'Mark items as favorite to see them here',
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteItems.length,
            itemBuilder: (context, index) {
              final item = favoriteItems[index];
              return CustomCard(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      DSAItem.getCategoryIcon(item.category),
                      color: colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    item.name,
                    style: TextStyle(
                      color: AppTheme.getTextOnColor(colorScheme.surface, highEmphasis: true),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    DSAItem.getCategoryName(item.category),
                    style: TextStyle(
                      color: AppTheme.getTextOnColor(colorScheme.surface, highEmphasis: false),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () => dsaProvider.toggleFavorite(item.id),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DSADetailScreen(dsaItem: item),
                      ),
                    );
                  },
                ),
              );
            },
          );
  }
}

class DSAAnalyticsTab extends StatelessWidget {
  const DSAAnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dsaProvider = Provider.of<DSAProvider>(context);
    final categoryDistribution = dsaProvider.getCategoryDistribution();
    final proficiencyDistribution = dsaProvider.getProficiencyDistribution();
    final avgProficiency = dsaProvider.getAverageProficiency();
    final colorScheme = Theme.of(context).colorScheme;
    
    // Only show analytics if there are DSA items
    if (dsaProvider.dsaItems.isEmpty) {
      return const EmptyState(
        icon: Icons.bar_chart,
        title: 'No data to analyze',
        message: 'Add DSA items to see analytics',
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: CustomCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Items',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextOnColor(colorScheme.surface, highEmphasis: true),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${dsaProvider.dsaItems.length}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Avg. Proficiency',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextOnColor(colorScheme.surface, highEmphasis: true),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${avgProficiency.toStringAsFixed(1)}/5',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Category Distribution
          CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category Distribution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextOnColor(colorScheme.surface, highEmphasis: true),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.center,
                      barGroups: _createCategoryBarGroups(
                        context, 
                        categoryDistribution
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.getTextOnColor(colorScheme.surface, highEmphasis: false),
                                ),
                              ),
                            ),
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Transform.rotate(
                              angle: 0.5,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  _getCategoryName(categoryDistribution, value.toInt()),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.getTextOnColor(colorScheme.surface, highEmphasis: false),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Proficiency Distribution
          CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Proficiency Distribution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextOnColor(colorScheme.surface, highEmphasis: true),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [1, 2, 3, 4, 5].map((level) {
                    final count = proficiencyDistribution[level] ?? 0;
                    final total = dsaProvider.dsaItems.length;
                    final percentage = total > 0 ? (count / total * 100).round() : 0;
                    
                    return Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: 120 * (count / (total > 0 ? total : 1)),
                            width: 20,
                            color: _getProficiencyColor(level),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            level.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getTextOnColor(colorScheme.surface, highEmphasis: true),
                            ),
                          ),
                          Text(
                            '$count ($percentage%)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.getTextOnColor(colorScheme.surface, highEmphasis: false),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  List<BarChartGroupData> _createCategoryBarGroups(
    BuildContext context, 
    Map<String, int> distribution,
  ) {
    final entries = distribution.entries.toList();
    final colorScheme = Theme.of(context).colorScheme;
    
    return List.generate(entries.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entries[index].value.toDouble(),
            color: colorScheme.primary,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }
  
  String _getCategoryName(Map<String, int> distribution, int index) {
    final entries = distribution.entries.toList();
    if (index >= 0 && index < entries.length) {
      return entries[index].key;
    }
    return '';
  }
  
  Color _getProficiencyColor(int level) {
    switch (level) {
      case 1:
        return Colors.red.shade300;
      case 2:
        return Colors.orange.shade300;
      case 3:
        return Colors.yellow.shade500;
      case 4:
        return Colors.lightGreen.shade400;
      case 5:
        return Colors.green.shade400;
      default:
        return Colors.grey;
    }
  }
} 