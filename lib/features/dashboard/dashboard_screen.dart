import 'package:become_an_ai_agent/core/constants/app_constants.dart';
import 'package:become_an_ai_agent/core/widgets/custom_app_bar.dart';
import 'package:become_an_ai_agent/core/widgets/custom_card.dart';
import 'package:become_an_ai_agent/core/widgets/profile_avatar.dart';
import 'package:become_an_ai_agent/features/auth/auth_provider.dart';
import 'package:become_an_ai_agent/features/auth/auth_screen.dart';
import 'package:become_an_ai_agent/features/knowledge_base/knowledge_base_screen.dart';
import 'package:become_an_ai_agent/features/settings/settings_screen.dart';
import 'package:become_an_ai_agent/features/tech_stack/tech_stack_screen.dart';
import 'package:become_an_ai_agent/features/project_tracker/project_screen.dart';
import 'package:become_an_ai_agent/features/notes/notes_screen.dart';
import 'package:become_an_ai_agent/features/code_compare/code_compare_screen.dart';
import 'package:become_an_ai_agent/features/design_patterns/design_patterns_screen.dart';
import 'package:become_an_ai_agent/features/journal/journal_screen.dart';
import 'package:become_an_ai_agent/features/profile/profile_screen.dart';
import 'package:become_an_ai_agent/features/dsa/dsa_screen.dart';
import 'package:become_an_ai_agent/features/about/about_screen.dart';
import 'package:become_an_ai_agent/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:ui';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['All', 'Learning', 'Projects', 'Tools'];
  int _selectedCategoryIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedCategoryIndex = _tabController.index;
      });
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: colorScheme.primary,
            stretch: true,
            title: Row(
              children: [
                Text(AppConstants.appName),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                        ],
                      ),
                    ),
                  ),
                  // Pattern overlay
                  CustomPaint(
                    painter: GridPatternPainter(),
                  ),
                  // Blurred avatar and welcome
                  Positioned(
                    top: 85,
                    left: 20,
                    child: Row(
                      children: [
                        const ProfileAvatar(
                          size: 60,
                          showAnimation: true,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Welcome,',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  authProvider.userName ?? 'User',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats card with more modern design
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Progress',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  size: 12,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '+12%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatItemWithAnimation(context, '12', 'Projects', Icons.code),
                            _buildStatItemWithAnimation(context, '24', 'Notes', Icons.note_alt),
                            _buildStatItemWithAnimation(context, '8', 'Skills', Icons.language),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Category tabs - more stylish
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  height: 36,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 14),
                    indicatorSize: TabBarIndicatorSize.label,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: colorScheme.primary,
                    ),
                    labelColor: colorScheme.onPrimary,
                    unselectedLabelColor: colorScheme.onSurface.withOpacity(0.7),
                    tabs: _categories.map((cat) => Tab(
                      height: 36,
                      child: Text(cat, style: const TextStyle(fontSize: 13)),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Feature tiles - using SliverGrid with beautiful cards
          SliverPadding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.2,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final features = _getFilteredFeatures(_selectedCategoryIndex);
                  if (index >= features.length) return null;
                  return _buildModernFeatureCard(
                    context,
                    features[index].title,
                    features[index].icon,
                    features[index].color,
                    features[index].description,
                    features[index].onTap,
                  );
                },
                childCount: _getFilteredFeatures(_selectedCategoryIndex).length,
              ),
            ),
          ),
          
          // Bottom padding 
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );

          if (confirmed == true && context.mounted) {
            await authProvider.logout();
            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const AuthScreen(),
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        elevation: 4,
      ),
    );
  }

  List<FeatureItem> _getFilteredFeatures(int categoryIndex) {
    final features = [
      FeatureItem(
        title: 'Knowledge Base',
        icon: Icons.psychology,
        color: Colors.lightBlue,
        description: 'Store programming concepts',
        category: 'Learning',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const KnowledgeBaseScreen()),
        ),
      ),
      FeatureItem(
        title: 'Projects',
        icon: Icons.code,
        color: Colors.orangeAccent,
        description: 'Manage development projects',
        category: 'Projects',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ProjectScreen()),
        ),
      ),
      FeatureItem(
        title: 'Tech Stack',
        icon: Icons.layers,
        color: Colors.green,
        description: 'Rate your skills',
        category: 'Learning',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const TechStackScreen()),
        ),
      ),
      FeatureItem(
        title: 'Notes',
        icon: Icons.note_alt,
        color: Colors.purple,
        description: 'Take coding notes',
        category: 'Tools',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const NotesScreen()),
        ),
      ),
      FeatureItem(
        title: 'Journal',
        icon: Icons.book,
        color: Colors.teal,
        description: 'Track learning progress',
        category: 'Learning',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const JournalScreen()),
        ),
      ),
      FeatureItem(
        title: 'DSA',
        icon: Icons.data_array,
        color: Colors.indigo,
        description: 'Learn algorithms',
        category: 'Learning',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const DSAScreen()),
        ),
      ),
      FeatureItem(
        title: 'Design Patterns',
        icon: Icons.architecture,
        color: Colors.amber,
        description: 'Learn design patterns',
        category: 'Learning',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const DesignPatternsScreen()),
        ),
      ),
      FeatureItem(
        title: 'Code Compare',
        icon: Icons.compare_arrows,
        color: Colors.redAccent,
        description: 'Compare code implementations',
        category: 'Tools',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const CodeCompareScreen()),
        ),
      ),
      FeatureItem(
        title: 'Profile',
        icon: Icons.person,
        color: Colors.blueGrey,
        description: 'View your profile',
        category: 'Tools',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        ),
      ),
    ];
    
    if (categoryIndex == 0) {
      return features; // All features
    } else {
      final category = _categories[categoryIndex];
      return features.where((f) => f.category == category).toList();
    }
  }

  Widget _buildStatItemWithAnimation(BuildContext context, String value, String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Use a row-based layout for better space efficiency
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon container
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 16,
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Text info column
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String description,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shadowColor: color.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: colorScheme.surface,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }
}

class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    final double cellSize = 30;
    
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += cellSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
    
    // Draw vertical lines
    for (double x = 0; x < size.width; x += cellSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Draw some random circles for a more interesting pattern
    final random = math.Random(42); // Fixed seed for consistency
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 10 + 5;
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        circlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FeatureItem {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final String category;
  final VoidCallback onTap;

  FeatureItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.category,
    required this.onTap,
  });
} 