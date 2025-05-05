import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:become_an_ai_agent/core/constants/app_constants.dart';
import 'package:become_an_ai_agent/core/widgets/custom_app_bar.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ContactItem> _contactItems = [
    ContactItem(
      icon: Icons.whatshot,
      title: 'WhatsApp',
      value: '+8801640641524',
      url: 'https://wa.me/8801640641524',
      backgroundColor: const Color(0xFF25D366), // WhatsApp green
      foregroundColor: Colors.white,
    ),
    ContactItem(
      icon: Icons.facebook_rounded,
      title: 'Facebook',
      value: 'mojarcoder',
      url: 'https://facebook.com/mojarcoder',
      backgroundColor: const Color(0xFF1877F2), // Facebook blue
      foregroundColor: Colors.white,
    ),
    ContactItem(
      icon: Icons.smart_display_rounded,
      title: 'YouTube',
      value: '@mojarcoder',
      url: 'https://youtube.com/@mojarcoder',
      backgroundColor: const Color(0xFFFF0000), // YouTube red
      foregroundColor: Colors.white,
    ),
    ContactItem(
      icon: Icons.public,
      title: 'Website',
      value: 'mojarcoder.com',
      url: 'https://mojarcoder.com',
      backgroundColor: const Color(0xFF0077B5), // Professional blue
      foregroundColor: Colors.white,
    ),
    ContactItem(
      icon: Icons.code_rounded,
      title: 'GitHub',
      value: 'github.com/mojarcoder',
      url: 'https://github.com/mojarcoder',
      backgroundColor: const Color(0xFF333333), // GitHub dark
      foregroundColor: Colors.white,
    ),
    ContactItem(
      icon: Icons.email_rounded,
      title: 'Email',
      value: 'mojarcoder@gmail.com',
      url: 'mailto:mojarcoder@gmail.com',
      backgroundColor: const Color(0xFFEA4335), // Gmail red
      foregroundColor: Colors.white,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await canLaunchUrl(uri)) {
        throw 'Could not launch $url';
      }
      
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      );
      
      if (!launched) {
        throw 'Failed to launch $url';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            floating: false,
            pinned: true,
            backgroundColor: colorScheme.primary,
            stretch: true,
            title: const Text('About'),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Fancy gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                          colorScheme.tertiary,
                        ],
                      ),
                    ),
                  ),
                  // Decorative patterns
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: CustomPaint(
                        painter: GridPatternPainter(),
                      ),
                    ),
                  ),
                  // App logo and name
                  Positioned(
                    bottom: 48,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated logo
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _controller.value * 2 * math.pi,
                              child: Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/company-logo.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade300,
                                        child: Icon(
                                          Icons.business,
                                          color: colorScheme.primary,
                                          size: 40,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppConstants.appName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 2,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'v${AppConstants.appVersion}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App description with fancy card
                  Card(
                    elevation: 8,
                    shadowColor: colorScheme.shadow.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'About This App',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: colorScheme.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Become An AI Agent is a comprehensive Flutter application designed to help developers track their skills, projects, and learning materials in one place.',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: colorScheme.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'The app serves as your personal developer assistant, helping you manage coding knowledge, analyze progress, and enhance your learning journey with beautifully designed features.',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Features section
                  Row(
                    children: [
                      Icon(
                        Icons.stars,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Key Features',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Feature cards in a horizontal scrollable list
                  SizedBox(
                    height: 160,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildFeatureCard(
                          context,
                          Icons.psychology,
                          'Knowledge Base',
                          'Track your programming concepts',
                          colorScheme.primaryContainer,
                        ),
                        _buildFeatureCard(
                          context,
                          Icons.code,
                          'Projects',
                          'Manage development projects',
                          colorScheme.secondaryContainer,
                        ),
                        _buildFeatureCard(
                          context,
                          Icons.architecture,
                          'Design Patterns',
                          'Learn software design patterns',
                          colorScheme.tertiaryContainer,
                        ),
                        _buildFeatureCard(
                          context,
                          Icons.note_alt,
                          'Notes',
                          'Take and organize coding notes',
                          colorScheme.errorContainer,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Developer section
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Developer',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Card(
                    elevation: 4,
                    shadowColor: colorScheme.shadow.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: colorScheme.surface,
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/company-logo.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    size: 40,
                                    color: colorScheme.primary,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Mojar Coder',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Flutter Developer',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Passionate about creating beautiful and functional Flutter applications that help developers improve their skills.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Where Coding Meets Joy!',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Contact section
                  Row(
                    children: [
                      Icon(
                        Icons.contact_page,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Contact & Connect',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          // Contact items in a list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = _contactItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    elevation: 2,
                    shadowColor: colorScheme.shadow.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () => _launchUrl(item.url),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: item.backgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                item.icon,
                                color: item.foregroundColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    item.value,
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: _contactItems.length,
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceVariant.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.copyright,
                                color: colorScheme.onSurfaceVariant,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${DateTime.now().year} Mojar Coder.',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'All rights reserved.',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to App'),
                    elevation: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, 
    IconData icon, 
    String title, 
    String description, 
    Color backgroundColor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 4,
        shadowColor: colorScheme.shadow.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: colorScheme.onSurfaceVariant,
                size: 32,
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactItem {
  final IconData icon;
  final String title;
  final String value;
  final String url;
  final Color backgroundColor;
  final Color foregroundColor;

  ContactItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.url,
    required this.backgroundColor,
    required this.foregroundColor,
  });
}

class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
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
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 20 + 5;
      
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