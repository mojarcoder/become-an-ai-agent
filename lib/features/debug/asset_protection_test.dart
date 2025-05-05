import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/asset_protection.dart';
import '../../utils/secure_asset_provider.dart';

/// A test screen for validating asset protection
class AssetProtectionTestScreen extends StatefulWidget {
  const AssetProtectionTestScreen({super.key});

  @override
  State<AssetProtectionTestScreen> createState() =>
      _AssetProtectionTestScreenState();
}

class _AssetProtectionTestScreenState extends State<AssetProtectionTestScreen> {
  String _status = 'Ready';
  bool _isChecking = false;
  Map<String, bool> _assetStatuses = {};
  bool _testModeEnabled = false;

  @override
  void initState() {
    super.initState();
    // Check initial test mode status
    _testModeEnabled = false; // Default off
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asset Protection Test')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Test mode toggle
            Card(
              color:
                  _testModeEnabled
                      ? Colors.amber.shade100
                      : Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Force Validation Mode',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          value: _testModeEnabled,
                          activeColor: Colors.amber.shade800,
                          onChanged: _toggleTestMode,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _testModeEnabled
                          ? 'Asset validation enforced even in debug mode'
                          : 'Normal debug behavior (limited validation)',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color:
                            _testModeEnabled
                                ? Colors.amber.shade900
                                : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Status card
            Card(
              color:
                  _status.contains('Failed')
                      ? Colors.red.shade100
                      : _status.contains('Valid')
                      ? Colors.green.shade100
                      : Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Status: $_status',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_isChecking)
                      const Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _isChecking ? null : _runAssetCheck,
                  child: const Text('Run Asset Check'),
                ),
                ElevatedButton(
                  onPressed: _isChecking ? null : _resetChecksums,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reset Checksums'),
                ),
                ElevatedButton(
                  onPressed: _isChecking ? null : _forceValidation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Force Full Validation'),
                ),
                ElevatedButton(
                  onPressed:
                      _isChecking ? null : () => _clearSharedPrefs(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Clear SharedPrefs'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Quick test modification buttons
            Card(
              color: Colors.lime.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Modification Tests',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Use these buttons to quickly confirm modification detection',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickTestButton(
                          label: 'Check company-logo.png',
                          onPressed:
                              () => _checkSpecificAsset(
                                'assets/images/company-logo.png',
                              ),
                          color: Colors.blue,
                        ),
                        _buildQuickTestButton(
                          label: 'Check app_icon.png',
                          onPressed:
                              () => _checkSpecificAsset(
                                'assets/icons/app_icon.png',
                              ),
                          color: Colors.teal,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Test assets
            const Text(
              'Test Assets:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Display securely loaded image
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text('Secure Image Loading:'),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          SecureImage(
                            assetPath: 'assets/icons/app_icon.png',
                            width: 100,
                            height: 100,
                          ),
                          const Text(
                            'app_icon.png',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SecureImage(
                            assetPath: 'assets/images/company-logo.png',
                            width: 100,
                            height: 100,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 100,
                                color: Colors.red.shade100,
                                child: const Center(
                                  child: Icon(Icons.error, color: Colors.red),
                                ),
                              );
                            },
                          ),
                          const Text(
                            'company-logo.png',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Asset status list
            if (_assetStatuses.isNotEmpty) ...[
              const Text(
                'Asset Validation Results:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...buildAssetStatusList(),
            ],

            // Asset Management Section
            const SizedBox(height: 20),

            const Text(
              'Asset Management:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Remove Missing Assets',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Use this to remove deleted assets from protection list:',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Asset Path to Remove',
                        hintText: 'e.g., assets/images/Layer 0.png',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: _removeAssetFromProtection,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed:
                              _isChecking ? null : _showRemoveAssetDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Remove Assets'),
                        ),
                        ElevatedButton(
                          onPressed:
                              _isChecking
                                  ? null
                                  : () => _removeSpecificAsset(
                                    'assets/images/Layer 0.png',
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Remove Layer 0.png'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build a colored quick test button
  Widget _buildQuickTestButton({
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: _isChecking ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  // Builds a list of asset status items
  List<Widget> buildAssetStatusList() {
    return _assetStatuses.entries.map((entry) {
      return Card(
        color: entry.value ? Colors.green.shade50 : Colors.red.shade50,
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          title: Text(entry.key, style: const TextStyle(fontSize: 14)),
          trailing: Icon(
            entry.value ? Icons.check_circle : Icons.error,
            color: entry.value ? Colors.green : Colors.red,
          ),
          subtitle: FutureBuilder<String?>(
            future: _getAssetChecksum(entry.key),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('Loading checksum...');
              }
              return Text(
                'Checksum: ${snapshot.data?.substring(0, 16) ?? 'Unknown'}...',
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
      );
    }).toList();
  }

  // Toggle test mode
  void _toggleTestMode(bool value) {
    setState(() {
      _testModeEnabled = value;
      if (value) {
        AssetProtection.enableTestMode();
      } else {
        AssetProtection.disableTestMode();
      }
      _status =
          value
              ? 'Test mode enabled - validation enforced'
              : 'Test mode disabled - normal debug behavior';
    });
  }

  // Run a simple asset check
  Future<void> _runAssetCheck() async {
    setState(() {
      _isChecking = true;
      _status = 'Checking assets...';
    });

    try {
      final bool assetsValid = await AssetProtection.performSecurityCheck();

      setState(() {
        _status = assetsValid ? 'Assets Valid ✅' : 'Assets Check Failed ❌';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  // Reset all checksums
  Future<void> _resetChecksums() async {
    setState(() {
      _isChecking = true;
      _status = 'Resetting checksums...';
    });

    try {
      await AssetProtection.resetChecksums();

      // Re-initialize to generate new checksums
      await AssetProtection.initialize();

      setState(() {
        _status = 'Checksums reset and regenerated';
        _assetStatuses = {};
      });
    } catch (e) {
      setState(() {
        _status = 'Reset Error: $e';
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  // Check a specific asset for modifications
  Future<void> _checkSpecificAsset(String assetPath) async {
    setState(() {
      _isChecking = true;
      _status = 'Checking $assetPath...';
      _assetStatuses = {};
    });

    try {
      final isValid = await AssetProtection.validateAsset(assetPath);

      setState(() {
        _assetStatuses = {assetPath: isValid};
        _status =
            isValid
                ? 'Asset is valid and unmodified ✅'
                : 'Asset has been modified! ❌';
      });
    } catch (e) {
      setState(() {
        _status = 'Error checking asset: $e';
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  // Get the stored checksum for an asset
  Future<String?> _getAssetChecksum(String assetPath) async {
    return AssetProtection.getStoredChecksum(assetPath);
  }

  // Force a full validation with detailed results
  Future<void> _forceValidation() async {
    setState(() {
      _isChecking = true;
      _status = 'Running full validation...';
      _assetStatuses = {};
    });

    try {
      // Use a private method to get individual results
      await _validateAllAssetsIndividually();

      // Check if any failed
      final bool anyFailed = _assetStatuses.values.any((valid) => !valid);

      setState(() {
        _status =
            anyFailed
                ? 'Validation Failed: Some assets modified ❌'
                : 'All Assets Valid ✅';
      });
    } catch (e) {
      setState(() {
        _status = 'Validation Error: $e';
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  // Clear all shared preferences
  Future<void> _clearSharedPrefs(BuildContext context) async {
    setState(() {
      _isChecking = true;
      _status = 'Clearing SharedPreferences...';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      setState(() {
        _status = 'SharedPreferences cleared';
        _assetStatuses = {};
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SharedPreferences cleared. App restart recommended.'),
        ),
      );
    } catch (e) {
      setState(() {
        _status = 'SharedPrefs Error: $e';
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  // Helper to validate all assets individually
  Future<void> _validateAllAssetsIndividually() async {
    // Refresh checksums first to ensure we have latest
    await AssetProtection.initialize();

    // Get the list of all protected assets
    final assets = AssetProtection.getProtectedAssets();

    Map<String, bool> results = {};

    for (final assetPath in assets) {
      try {
        // Use direct validation method
        final isValid = await AssetProtection.validateAsset(assetPath);
        results[assetPath] = isValid;
      } catch (e) {
        results[assetPath] = false;
      }
    }

    setState(() {
      _assetStatuses = results;
    });
  }

  // Show dialog to remove an asset
  void _showRemoveAssetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final assets = AssetProtection.getProtectedAssets();
        return AlertDialog(
          title: const Text('Remove Assets'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: assets.length,
              itemBuilder: (context, index) {
                final asset = assets[index];
                return ListTile(
                  title: Text(asset, style: const TextStyle(fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _removeAssetFromProtection(asset);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Remove a specific asset (direct call)
  Future<void> _removeSpecificAsset(String assetPath) async {
    setState(() {
      _isChecking = true;
      _status = 'Removing asset: $assetPath...';
    });

    try {
      final success = await AssetProtection.removeAssetFromProtection(
        assetPath,
      );

      setState(() {
        _status =
            success
                ? 'Asset removed from protection: $assetPath'
                : 'Asset not found: $assetPath';
      });

      // Refresh the validation
      await _forceValidation();
    } catch (e) {
      setState(() {
        _status = 'Error removing asset: $e';
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  // Remove asset from submitted text
  Future<void> _removeAssetFromProtection(String assetPath) async {
    setState(() {
      _isChecking = true;
      _status = 'Removing asset: $assetPath...';
    });

    try {
      final success = await AssetProtection.removeAssetFromProtection(
        assetPath,
      );

      setState(() {
        _status =
            success
                ? 'Asset removed from protection: $assetPath'
                : 'Asset not found: $assetPath';
      });

      // Refresh the validation
      await _forceValidation();
    } catch (e) {
      setState(() {
        _status = 'Error removing asset: $e';
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }
}
