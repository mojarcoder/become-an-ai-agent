import 'package:flutter/material.dart';
import 'package:become_an_ai_agent/core/widgets/profile_avatar.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;
  final double? titleSpacing;
  final double? leadingWidth;
  final double? toolbarHeight;
  final Widget? flexibleSpace;
  final bool showProfileAvatar;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
    this.automaticallyImplyLeading = true,
    this.titleSpacing,
    this.leadingWidth,
    this.toolbarHeight,
    this.flexibleSpace,
    this.showProfileAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      title: Text(
        title,
        style: theme.appBarTheme.titleTextStyle,
      ),
      actions: [
        if (showProfileAvatar) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: ProfileAvatar(size: 36),
          ),
        ],
        if (actions != null) ...actions!,
      ],
      leading: leading,
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      bottom: bottom,
      automaticallyImplyLeading: automaticallyImplyLeading,
      titleSpacing: titleSpacing,
      leadingWidth: leadingWidth,
      toolbarHeight: toolbarHeight,
      flexibleSpace: flexibleSpace,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        bottom != null
            ? (toolbarHeight ?? kToolbarHeight) + bottom!.preferredSize.height
            : (toolbarHeight ?? kToolbarHeight),
      );
}

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final TextEditingController searchController;
  final VoidCallback? onSearchClear;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final List<Widget>? actions;
  final bool isSearching;
  final VoidCallback toggleSearch;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? toolbarHeight;
  final bool showProfileAvatar;

  const SearchAppBar({
    super.key,
    required this.title,
    required this.searchController,
    required this.isSearching,
    required this.toggleSearch,
    this.onSearchClear,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.actions,
    this.elevation = 0,
    this.backgroundColor,
    this.foregroundColor,
    this.toolbarHeight,
    this.showProfileAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: isSearching
          ? TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: foregroundColor?.withOpacity(0.6)),
              ),
              style: TextStyle(color: foregroundColor),
              autofocus: true,
              onChanged: onSearchChanged,
              onSubmitted: onSearchSubmitted,
            )
          : Text(title),
      actions: [
        if (isSearching)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              searchController.clear();
              if (onSearchClear != null) {
                onSearchClear!();
              }
            },
          )
        else ...[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: toggleSearch,
          ),
          if (!isSearching && actions != null) ...actions!,
          if (showProfileAvatar && !isSearching) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: ProfileAvatar(size: 36),
            ),
          ],
        ],
      ],
      elevation: elevation,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      toolbarHeight: toolbarHeight,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? kToolbarHeight);
} 