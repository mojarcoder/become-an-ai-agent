import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String? text;
  final Widget? icon;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isOutlined;
  final bool isFullWidth;
  final Widget? child;

  const CustomButton({
    super.key,
    this.text,
    this.icon,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
    this.isOutlined = false,
    this.isFullWidth = false,
    this.child,
  }) : assert(text != null || child != null, 'Either text or child must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Size-based properties
    double height;
    double iconSize;
    EdgeInsetsGeometry effectivePadding;
    TextStyle? textStyle;
    
    switch (size) {
      case ButtonSize.small:
        height = 36.0;
        iconSize = 18.0;
        effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 16.0);
        textStyle = theme.textTheme.labelMedium;
        break;
      case ButtonSize.large:
        height = 56.0;
        iconSize = 24.0;
        effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 24.0);
        textStyle = theme.textTheme.titleMedium;
        break;
      case ButtonSize.medium:
      default:
        height = 48.0;
        iconSize = 20.0;
        effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 20.0);
        textStyle = theme.textTheme.labelLarge;
    }
    
    final effectiveBorderRadius = borderRadius ?? AppConstants.borderRadius;
    
    // Button content
    Widget buttonContent;
    
    if (isLoading) {
      buttonContent = SizedBox(
        height: iconSize,
        width: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOutlined ? (backgroundColor ?? theme.colorScheme.primary) 
                      : (foregroundColor ?? Colors.white),
          ),
        ),
      );
    } else if (child != null) {
      buttonContent = child!;
    } else {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(size: iconSize),
              child: icon!,
            ),
            const SizedBox(width: 8.0),
          ],
          if (text != null)
            Text(
              text!,
              style: textStyle,
            ),
        ],
      );
    }
    
    // Button widget
    Widget button;
    
    if (isOutlined) {
      button = OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor ?? theme.colorScheme.primary,
          padding: effectivePadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
          ),
          minimumSize: Size(0, height),
          side: BorderSide(
            color: backgroundColor ?? theme.colorScheme.primary,
            width: 1.5,
          ),
        ),
        child: buttonContent,
      );
    } else {
      button = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.colorScheme.primary,
          foregroundColor: foregroundColor ?? Colors.white,
          padding: effectivePadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
          ),
          minimumSize: Size(0, height),
          elevation: 1.0,
        ),
        child: buttonContent,
      );
    }
    
    // Apply full width if needed
    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    
    return button;
  }
}

class IconButtonWithBadge extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final int? badgeCount;
  final Color? badgeColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final String? tooltip;

  const IconButtonWithBadge({
    super.key,
    required this.icon,
    required this.onPressed,
    this.badgeCount,
    this.badgeColor,
    this.iconColor,
    this.size = 48.0,
    this.iconSize = 24.0,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget iconButtonWidget = IconButton(
      icon: Icon(icon, size: iconSize),
      onPressed: onPressed,
      color: iconColor,
      tooltip: tooltip,
    );
    
    if (badgeCount == null || badgeCount == 0) {
      return iconButtonWidget;
    }
    
    return Stack(
      alignment: Alignment.center,
      children: [
        iconButtonWidget,
        Positioned(
          top: 8.0,
          right: 8.0,
          child: Container(
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              color: badgeColor ?? theme.colorScheme.error,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(
              minWidth: 16.0,
              minHeight: 16.0,
            ),
            child: Center(
              child: Text(
                badgeCount! > 99 ? '99+' : badgeCount.toString(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontSize: 10.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
} 