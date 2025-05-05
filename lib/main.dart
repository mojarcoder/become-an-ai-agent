import 'package:become_an_ai_agent/core/constants/app_constants.dart';
import 'package:become_an_ai_agent/core/theme/app_theme.dart';
import 'package:become_an_ai_agent/core/theme/theme_provider.dart';
import 'package:become_an_ai_agent/services/database_service.dart';
import 'package:become_an_ai_agent/services/auth_service.dart';
import 'package:become_an_ai_agent/features/auth/auth_provider.dart';
import 'package:become_an_ai_agent/features/auth/auth_screen.dart';
import 'package:become_an_ai_agent/features/dashboard/dashboard_screen.dart';
import 'package:become_an_ai_agent/features/dsa/dsa_provider.dart';
import 'package:become_an_ai_agent/features/debug/asset_protection_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Import the AssetProtection class when fully implemented
import 'utils/asset_protection.dart';
import 'utils/secure_asset_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize services
  final prefs = await SharedPreferences.getInstance();
  final authService = AuthService(prefs);
  await DatabaseService().initialize();

  // In debug mode, add an option to reset checksums (testing purposes)
  if (kDebugMode) {
    // Uncomment the line below to reset checksums during testing
    // await AssetProtection.resetChecksums();
    debugPrint('Debug mode: Asset protection will have limited enforcement');
  }

  // Initialize asset protection
  bool assetsValid = await AssetProtection.initialize();

  // Only enforce in release mode
  if (!assetsValid && !kDebugMode) {
    // Handle tampered assets
    await _showTamperingWarning();
    // Exit app after warning displayed
    SystemNavigator.pop();
    return;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(create: (_) => DSAProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// Show a warning dialog for tampered assets
Future<void> _showTamperingWarning() async {
  // Create a standalone MaterialApp just for showing the warning
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          // Show the dialog after the app renders
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Security Warning'),
                  content: const Text(
                    'This application has detected potential unauthorized modifications.\n\n'
                    'The application will now close.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                      child: const Text('Exit'),
                    ),
                  ],
                );
              },
            );
          });

          // Return an empty container as the base widget
          return const Scaffold(
            body: Center(
              child: Text(
                'Security Alert',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    ),
  );

  // Wait some time to ensure the dialog is shown
  await Future.delayed(const Duration(seconds: 5));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.getTheme(
        themeProvider.themeOption,
        false,
        themeProvider.isCustomTheme ? themeProvider.customThemeColors : null,
      ),
      darkTheme: AppTheme.getTheme(
        themeProvider.themeOption,
        true,
        themeProvider.isCustomTheme ? themeProvider.customThemeColors : null,
      ),
      home:
          authProvider.isAuthenticated
              ? const SecurityWrapper(child: DashboardScreen())
              : const SecurityWrapper(child: AuthScreen()),
      routes: {
        AppConstants.dashboardRoute:
            (context) => const SecurityWrapper(child: DashboardScreen()),
        // Debug routes only available in debug mode
        '/debug/asset_protection':
            (context) =>
                kDebugMode
                    ? const AssetProtectionTestScreen()
                    : const SecurityWrapper(child: DashboardScreen()),
        // Other routes will be added as we implement the screens
      },
    );
  }
}

/// Security wrapper to check assets periodically
class SecurityWrapper extends StatefulWidget {
  final Widget child;

  const SecurityWrapper({super.key, required this.child});

  @override
  State<SecurityWrapper> createState() => _SecurityWrapperState();
}

class _SecurityWrapperState extends State<SecurityWrapper>
    with WidgetsBindingObserver {
  bool _securityInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Schedule an initial check when the app first loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verifyAssets();
      _securityInitialized = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Perform asset verification each time the app becomes active
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _securityInitialized) {
      _verifyAssets();
    }
    super.didChangeAppLifecycleState(state);
  }

  // Verify assets and show warning if modified
  Future<void> _verifyAssets() async {
    // Skip in debug mode
    if (kDebugMode) return;

    // Force an asset check
    final assetsValid = await AssetProtection.performSecurityCheck();
    if (!assetsValid) {
      if (!mounted) return;

      // Show warning and close app
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Security Warning'),
            content: const Text(
              'This application has detected potential unauthorized modifications.\n\n'
              'The application will now close.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: const Text('Exit'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      // In debug mode, add the security debug menu
      return Stack(
        children: [
          widget.child,
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'security_wrapper_fab',
              mini: true,
              backgroundColor: Colors.red.withOpacity(0.7),
              tooltip: 'Debug Security',
              onPressed: () {
                Navigator.pushNamed(context, '/debug/asset_protection');
              },
              child: const Icon(Icons.security, size: 20),
            ),
          ),
        ],
      );
    }

    // In release mode, just return the child
    return widget.child;
  }
}

/// Add a security check button in debug builds to test security
class DebugSecurityCheck extends StatelessWidget {
  const DebugSecurityCheck({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox();

    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        heroTag: 'debug_security_check_fab',
        mini: true,
        backgroundColor: Colors.red.withOpacity(0.7),
        onPressed: () async {
          final assetsValid = await AssetProtection.performSecurityCheck();

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Asset check: ${assetsValid ? "Valid" : "Modified"}',
              ),
              backgroundColor: assetsValid ? Colors.green : Colors.red,
            ),
          );
        },
        child: const Icon(Icons.security),
      ),
    );
  }
}

// Add this widget to any page you want to test security
class SecurityOverlay extends StatelessWidget {
  final Widget child;

  const SecurityOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [child, const DebugSecurityCheck()]);
  }
}

class AppBuildInfo extends StatelessWidget {
  final Widget child;

  const AppBuildInfo({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Banner(
      message: 'v${AppConstants.appVersion}',
      location: BannerLocation.topEnd,
      color: Colors.black.withOpacity(0.4),
      textStyle: const TextStyle(
        fontSize: 8,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      child: child,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return SecurityOverlay(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          actions: [
            if (kDebugMode)
              IconButton(
                icon: const Icon(Icons.security),
                tooltip: 'Asset Protection Test',
                onPressed: () {
                  Navigator.pushNamed(context, '/debug/asset_protection');
                },
              ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Secure way to load an image:
              SecureImage(
                assetPath: 'assets/icons/app_icon.png',
                width: 100,
                height: 100,
              ),

              const SizedBox(height: 20),

              const Text(
                'Protected App Assets',
                style: TextStyle(fontSize: 20),
              ),

              if (kDebugMode) ...[
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    await AssetProtection.resetChecksums();
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Asset checksums have been reset'),
                      ),
                    );
                  },
                  child: const Text('Reset Asset Checksums'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/debug/asset_protection');
                  },
                  child: const Text('Asset Protection Test Screen'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
