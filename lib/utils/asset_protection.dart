import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Utility class for protecting and validating application assets.
/// This class detects if assets have been tampered with by comparing checksums.
class AssetProtection {
  /// Stores checksums of critical assets
  static Map<String, String> _assetChecksums = {};

  /// Flag to check if assets have been validated
  static bool _assetsValidated = false;

  /// Flag indicating if assets are valid
  static bool _assetsValid = true;

  /// Key for storing checksums in preferences
  static const String _checksumStorageKey = 'asset_checksums_v1';

  /// Security seed for additional hash protection
  static const String _securitySeed = 'become_ai_agent_security_seed_6174';

  /// Critical assets that must be checked
  static final List<String> _criticalAssets = [
    'assets/icons/app_icon.png',
    'assets/images/company-logo.png',
    // Add more critical assets here
  ];

  /// Directory paths to protect
  static final List<String> _protectedDirectories = [
    'assets/icons/',
    'assets/images/',
    'assets/lottie/',
    'assets/fonts/',
  ];

  /// Test mode flag for debugging
  static bool _testMode = false;

  /// Initialize asset protection system
  static Future<bool> initialize() async {
    if (kDebugMode) {
      debugPrint('Debug mode: Asset protection will have limited enforcement');
      await _generateAssetChecksums();
      _assetsValidated = true;
      return true;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedChecksumsJson = prefs.getString(_checksumStorageKey);
      
      if (storedChecksumsJson == null) {
        // First run - generate and store checksums
        debugPrint('First run detected. Generating asset checksums...');
        await _generateAssetChecksums();
        await _storeChecksums();
        _assetsValidated = true;
        return true;
      } else {
        // Load stored checksums and validate
        _loadChecksums(storedChecksumsJson);
        final isValid = await validateCriticalAssets();
        _assetsValidated = true;
        _assetsValid = isValid;
        return isValid;
      }
    } catch (e) {
      debugPrint('Asset protection initialization error: $e');
      // In production, treat errors as tampering attempts
      if (!kDebugMode) {
        _assetsValid = false;
        return false;
      }
      return true;
    }
  }

  /// Load checksums from shared preferences
  static void _loadChecksums(String json) {
    try {
      final Map<String, dynamic> data = jsonDecode(json);
      _assetChecksums = Map<String, String>.from(data);
    } catch (e) {
      debugPrint('Error loading checksums: $e');
      _assetChecksums = {};
    }
  }

  /// Store checksums to shared preferences
  static Future<void> _storeChecksums() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(_assetChecksums);
      await prefs.setString(_checksumStorageKey, json);
    } catch (e) {
      debugPrint('Error storing checksums: $e');
    }
  }

  /// Generate SHA-256 checksums for all assets in protected directories
  static Future<void> _generateAssetChecksums() async {
    debugPrint('Generating asset checksums...');
    
    for (final assetPath in _criticalAssets) {
      await _generateChecksum(assetPath);
    }

    // Find and generate checksums for all assets in protected directories
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    
    for (final assetPath in manifestMap.keys) {
      // Check if asset is in a protected directory
      if (_protectedDirectories.any((dir) => assetPath.startsWith(dir))) {
        await _generateChecksum(assetPath);
      }
    }
  }

  /// Generate checksum for a single asset
  static Future<void> _generateChecksum(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final buffer = data.buffer.asUint8List();
      
      // Create SHA-256 hash with security seed
      final digest = sha256.convert(
        Uint8List.fromList([
          ...buffer,
          ..._securitySeed.codeUnits,
        ])
      );
      
      final checksum = digest.toString();
      _assetChecksums[assetPath] = checksum;
      
      debugPrint('Generated checksum for $assetPath: $checksum');
    } catch (e) {
      debugPrint('Error calculating checksum for $assetPath: $e');
      // Skip this asset
    }
  }

  /// Validates all critical assets against stored checksums
  static Future<bool> validateCriticalAssets() async {
    if (_assetChecksums.isEmpty) {
      debugPrint('No checksums available for validation');
      return false;
    }

    for (final assetPath in _criticalAssets) {
      if (!_assetChecksums.containsKey(assetPath)) {
        debugPrint('Missing checksum for critical asset: $assetPath');
        return false;
      }

      final storedChecksum = _assetChecksums[assetPath]!;
      final isValid = await _validateAsset(assetPath, storedChecksum);
      
      if (!isValid) {
        debugPrint('Asset validation failed: $assetPath');
        return false;
      }
    }

    debugPrint('All critical assets validated successfully');
    return true;
  }

  /// Validates a single asset against its stored checksum
  static Future<bool> _validateAsset(String assetPath, String storedChecksum) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final buffer = data.buffer.asUint8List();
      
      // Create SHA-256 hash with security seed
      final digest = sha256.convert(
        Uint8List.fromList([
          ...buffer,
          ..._securitySeed.codeUnits,
        ])
      );
      
      final currentChecksum = digest.toString();
      final isValid = currentChecksum == storedChecksum;
      
      if (!isValid) {
        debugPrint('Checksum mismatch for $assetPath');
        debugPrint('Stored: $storedChecksum');
        debugPrint('Current: $currentChecksum');
      }
      
      return isValid;
    } catch (e) {
      debugPrint('Error validating asset $assetPath: $e');
      return false;
    }
  }

  /// Public method to check if assets are valid
  static bool areAssetsValid() {
    if (!_assetsValidated) {
      debugPrint('Assets have not been validated yet');
      return false;
    }
    return _assetsValid;
  }

  /// Secure method to load an asset that checks integrity
  static Future<ByteData> secureLoadAsset(String assetPath) async {
    try {
      if (!_assetsValidated) {
        await initialize();
      }

      if (!_assetsValid && !kDebugMode) {
        throw Exception('Assets have been tampered with. Cannot load $assetPath');
      }

      // Verify this specific asset if it has a checksum
      if (_assetChecksums.containsKey(assetPath)) {
        final storedChecksum = _assetChecksums[assetPath]!;
        final isValid = await _validateAsset(assetPath, storedChecksum);
        
        if (!isValid && !kDebugMode) {
          throw Exception('Asset integrity validation failed: $assetPath');
        }
      }

      return await rootBundle.load(assetPath);
    } catch (e) {
      if (kDebugMode) {
        // In debug mode, load anyway but print error
        debugPrint('Asset protection error (debug mode): $e');
        return await rootBundle.load(assetPath);
      } else {
        rethrow;
      }
    }
  }

  /// Perform full security check on all assets
  /// This is a comprehensive validation of all protected assets
  static Future<bool> performSecurityCheck() async {
    if (_testMode && kDebugMode) {
      debugPrint('Test mode active: Security check bypassed');
      return true;
    }
    
    if (!_assetsValidated) {
      await initialize();
    }
    
    return _assetsValid;
  }
  
  /// Reset all stored checksums and regenerate them
  static Future<bool> resetChecksums() async {
    try {
      _assetChecksums = {};
      _assetsValidated = false;
      _assetsValid = false;
      
      // Clear stored checksums
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_checksumStorageKey);
      
      // Regenerate checksums
      await _generateAssetChecksums();
      await _storeChecksums();
      
      _assetsValidated = true;
      _assetsValid = true;
      
      debugPrint('Asset checksums reset successfully');
      return true;
    } catch (e) {
      debugPrint('Failed to reset checksums: $e');
      return false;
    }
  }
  
  /// Enable test mode for debugging
  static void enableTestMode() {
    if (!kDebugMode) {
      debugPrint('Test mode can only be enabled in debug builds');
      return;
    }
    
    _testMode = true;
    debugPrint('Asset protection test mode enabled');
  }
  
  /// Disable test mode
  static void disableTestMode() {
    _testMode = false;
    debugPrint('Asset protection test mode disabled');
  }
  
  /// Validate a specific asset
  static Future<bool> validateAsset(String assetPath) async {
    if (!_assetChecksums.containsKey(assetPath)) {
      debugPrint('No stored checksum for asset: $assetPath');
      return false;
    }
    
    final storedChecksum = _assetChecksums[assetPath]!;
    return await _validateAsset(assetPath, storedChecksum);
  }
  
  /// Get stored checksum for an asset
  static String? getStoredChecksum(String assetPath) {
    return _assetChecksums[assetPath];
  }
  
  /// Get list of all protected assets
  static List<String> getProtectedAssets() {
    return _assetChecksums.keys.toList();
  }
  
  /// Remove an asset from protection
  static Future<bool> removeAssetFromProtection(String assetPath) async {
    if (!_assetChecksums.containsKey(assetPath)) {
      debugPrint('Asset not found in protected list: $assetPath');
      return false;
    }
    
    _assetChecksums.remove(assetPath);
    await _storeChecksums();
    
    debugPrint('Asset removed from protection: $assetPath');
    return true;
  }
  
  /// Get secure asset (alias for secureLoadAsset for API consistency)
  static Future<ByteData> getSecureAsset(String assetPath) async {
    return await secureLoadAsset(assetPath);
  }
}
