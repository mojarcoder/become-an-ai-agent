import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'asset_protection.dart';

/// A secure image widget that validates assets before displaying them
class SecureImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const SecureImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.loadingBuilder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Image(
      image: SecureAssetProvider(assetPath),
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder ?? _defaultErrorBuilder,
    );
  }

  Widget _defaultErrorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    // Show a security warning for asset validation failures
    final isSecurityError = error.toString().contains(
      'Asset validation failed',
    );

    if (isSecurityError && !kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: const Text('Security Warning'),
                content: const Text(
                  'This application has detected potential unauthorized modifications.'
                  '\n\nThe application will now close.',
                ),
                actions: [
                  TextButton(
                    child: const Text('Exit'),
                    onPressed: () {
                      // Force app exit
                      SystemNavigator.pop();
                    },
                  ),
                ],
              ),
        );
      });
    }

    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          isSecurityError ? Icons.security : Icons.broken_image,
          color: isSecurityError ? Colors.red : Colors.grey,
          size: 40,
        ),
      ),
    );
  }
}

/// A secure asset image provider that validates images before loading
class SecureAssetProvider extends ImageProvider<SecureAssetProvider> {
  final String assetPath;

  const SecureAssetProvider(this.assetPath);

  @override
  Future<SecureAssetProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<SecureAssetProvider>(this);
  }

  @override
  ImageStreamCompleter loadBuffer(
    SecureAssetProvider key,
    DecoderBufferCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      debugLabel: assetPath,
    );
  }

  Future<ui.Codec> _loadAsync(
    SecureAssetProvider key,
    DecoderBufferCallback decode,
  ) async {
    try {
      // Get the asset securely with validation
      final ByteData data = await AssetProtection.getSecureAsset(assetPath);

      // Create image from bytes
      final buffer = await ui.ImmutableBuffer.fromUint8List(
        data.buffer.asUint8List(),
      );

      // Decode the image
      return await decode(buffer);
    } catch (e) {
      // Rethrow to be caught by error builder
      throw Exception('Asset validation failed: $assetPath');
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is SecureAssetProvider && other.assetPath == assetPath;
  }

  @override
  int get hashCode => assetPath.hashCode;

  @override
  String toString() =>
      '${objectRuntimeType(this, 'SecureAssetProvider')}("$assetPath")';
}
