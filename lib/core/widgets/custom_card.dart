import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? marginBottom;
  final double? elevation;
  final double? borderRadius;
  final BorderSide? borderSide;
  final bool hasShadow;
  final double? width;
  final double? height;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.padding,
    this.margin,
    this.marginBottom,
    this.elevation,
    this.borderRadius,
    this.borderSide,
    this.hasShadow = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveElevation = hasShadow ? (elevation ?? AppConstants.cardElevation) : 0.0;
    final effectiveBorderRadius = borderRadius ?? AppConstants.borderRadius;
    final cardColor = color ?? theme.cardColor;
    
    final effectiveMargin = margin ?? (marginBottom != null
        ? EdgeInsets.only(bottom: marginBottom!)
        : EdgeInsets.zero);
    
    return Container(
      margin: effectiveMargin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          child: Ink(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(effectiveBorderRadius),
              border: borderSide != null 
                  ? Border.fromBorderSide(borderSide!) 
                  : Border.all(
                      color: hasShadow 
                          ? Colors.transparent 
                          : colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
              boxShadow: hasShadow
                  ? [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.1),
                        blurRadius: effectiveElevation * 2.5,
                        spreadRadius: effectiveElevation * 0.5,
                        offset: Offset(0, effectiveElevation),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(effectiveBorderRadius),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 48.0,
                ),
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(AppConstants.defaultPadding),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GradientCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final List<Color> gradientColors;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final double? borderRadius;
  final BorderSide? borderSide;
  final bool hasShadow;
  final double? width;
  final double? height;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientCard({
    super.key,
    required this.child,
    required this.gradientColors,
    this.onTap,
    this.padding,
    this.elevation,
    this.borderRadius,
    this.borderSide,
    this.hasShadow = true,
    this.width,
    this.height,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveElevation = hasShadow ? (elevation ?? AppConstants.cardElevation) : 0.0;
    final effectiveBorderRadius = borderRadius ?? AppConstants.borderRadius;

    // Get foreground color based on the first gradient color (usually dominant)
    final foregroundColor = gradientColors.isNotEmpty 
        ? AppTheme.getBestForegroundColor(gradientColors.first)
        : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        highlightColor: foregroundColor.withOpacity(0.1),
        splashColor: foregroundColor.withOpacity(0.05),
        child: Ink(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: begin,
              end: end,
            ),
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            border: borderSide != null ? Border.fromBorderSide(borderSide!) : null,
            boxShadow: hasShadow
                ? [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.12),
                      blurRadius: effectiveElevation * 2.5,
                      spreadRadius: effectiveElevation * 0.5,
                      offset: Offset(0, effectiveElevation),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 48.0,
              ),
              child: Padding(
                padding: padding ?? const EdgeInsets.all(AppConstants.defaultPadding),
                child: DefaultTextStyle(
                  style: TextStyle(color: foregroundColor),
                  child: IconTheme(
                    data: IconThemeData(color: foregroundColor),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 