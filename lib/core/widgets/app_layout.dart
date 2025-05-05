import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppLayout extends StatelessWidget {
  final Widget mobileView;
  final Widget? tabletView;
  final Widget? desktopView;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool extendBody;
  final bool resizeToAvoidBottomInset;

  const AppLayout({
    super.key,
    required this.mobileView,
    this.tabletView,
    this.desktopView,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.extendBody = false,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: appBar,
          body: _buildResponsiveView(constraints),
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          backgroundColor: backgroundColor,
          extendBody: extendBody,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        );
      },
    );
  }

  Widget _buildResponsiveView(BoxConstraints constraints) {
    if (constraints.maxWidth >= 1200 && desktopView != null) {
      // Desktop view
      return desktopView!;
    } else if (constraints.maxWidth >= 600 && tabletView != null) {
      // Tablet view
      return tabletView!;
    } else {
      // Mobile view
      return mobileView;
    }
  }
}

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        EdgeInsetsGeometry effectivePadding;

        if (width >= 1200) {
          // Desktop padding
          effectivePadding = padding ?? const EdgeInsets.all(AppConstants.largePadding * 2);
        } else if (width >= 600) {
          // Tablet padding
          effectivePadding = padding ?? const EdgeInsets.all(AppConstants.largePadding);
        } else {
          // Mobile padding
          effectivePadding = padding ?? const EdgeInsets.all(AppConstants.defaultPadding);
        }

        return Padding(
          padding: effectivePadding,
          child: child,
        );
      },
    );
  }
} 