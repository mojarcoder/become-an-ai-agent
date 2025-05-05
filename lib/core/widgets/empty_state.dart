import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double? height;
  final String? lottieAsset;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.height,
    this.lottieAsset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: height,
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (lottieAsset != null) ...[
              Lottie.asset(
                lottieAsset!,
                width: 200,
                height: 200,
                repeat: true,
              ),
            ] else ...[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextOnColor(colorScheme.surface, highEmphasis: true),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.getTextOnColor(colorScheme.surface, highEmphasis: false),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: AppTheme.getBestForegroundColor(colorScheme.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Pre-defined empty states for common scenarios
class NoItemsEmptyState extends StatelessWidget {
  final String itemName;
  final String? message;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const NoItemsEmptyState({
    super.key,
    required this.itemName,
    this.message,
    this.actionText = 'Add New',
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.add_circle_outline,
      title: 'No $itemName Yet',
      message: message ?? 'Tap the button below to add your first $itemName.',
      actionLabel: actionText,
      onAction: onActionPressed,
    );
  }
}

class NoSearchResultsEmptyState extends StatelessWidget {
  final String searchTerm;
  final String? message;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const NoSearchResultsEmptyState({
    super.key,
    required this.searchTerm,
    this.message,
    this.actionText = 'Clear Search',
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No Results Found',
      message: message ?? 'We couldn\'t find any matches for "$searchTerm".',
      actionLabel: actionText,
      onAction: onActionPressed,
    );
  }
}

class ErrorEmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const ErrorEmptyState({
    super.key,
    this.title = 'Something Went Wrong',
    this.message,
    this.actionText = 'Retry',
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline,
      title: title,
      message: message ?? 'An error occurred while loading data.',
      actionLabel: actionText,
      onAction: onActionPressed,
    );
  }
} 