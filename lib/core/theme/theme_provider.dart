import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'app_theme.dart';

enum AppThemeOption {
  loveTheme,
  careTheme, 
  focusTheme,
  peaceTheme,
  joyTheme,
  redTheme,
  darkTheme,
  dayTheme,
  transparentTheme,
  premiumTheme,
  neonTheme,
  customTheme
}

class CustomThemeColors {
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color background;
  final Color surface;
  final Color text;
  final Color icon;
  
  const CustomThemeColors({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.background,
    required this.surface,
    required this.text,
    required this.icon,
  });
  
  factory CustomThemeColors.defaultColors() {
    return const CustomThemeColors(
      primary: Color(0xFFFF4D8D),
      secondary: Color(0xFF9C27B0),
      tertiary: Color(0xFF2196F3),
      background: Color(0xFFF5F5F5),
      surface: Color(0xFFFFFFFF),
      text: Color(0xFF212121),
      icon: Color(0xFF757575),
    );
  }
  
  CustomThemeColors copyWith({
    Color? primary,
    Color? secondary,
    Color? tertiary,
    Color? background,
    Color? surface,
    Color? text,
    Color? icon,
  }) {
    return CustomThemeColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      text: text ?? this.text,
      icon: icon ?? this.icon,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'primary': primary.value,
      'secondary': secondary.value,
      'tertiary': tertiary.value,
      'background': background.value,
      'surface': surface.value,
      'text': text.value,
      'icon': icon.value,
    };
  }
  
  factory CustomThemeColors.fromJson(Map<String, dynamic> json) {
    return CustomThemeColors(
      primary: Color(json['primary'] as int),
      secondary: Color(json['secondary'] as int),
      tertiary: Color(json['tertiary'] as int),
      background: Color(json['background'] as int),
      surface: Color(json['surface'] as int),
      text: Color(json['text'] as int),
      icon: Color(json['icon'] as int),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _themeOptionKey = 'theme_option';
  static const String _customThemeColorsKey = 'custom_theme_colors';
  
  ThemeMode _themeMode = ThemeMode.system;
  AppThemeOption _themeOption = AppThemeOption.loveTheme;
  CustomThemeColors _customThemeColors = CustomThemeColors.defaultColors();
  
  ThemeMode get themeMode => _themeMode;
  AppThemeOption get themeOption => _themeOption;
  CustomThemeColors get customThemeColors => _customThemeColors;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isCustomTheme => _themeOption == AppThemeOption.customTheme;
  
  ThemeProvider() {
    _loadThemePreferences();
  }
  
  Future<void> _loadThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeValue = prefs.getString(_themeModeKey);
    final themeOptionValue = prefs.getString(_themeOptionKey);
    final customThemeColorsJson = prefs.getString(_customThemeColorsKey);
    
    if (themeModeValue != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (element) => element.toString() == themeModeValue,
        orElse: () => ThemeMode.system,
      );
    }
    
    if (themeOptionValue != null) {
      _themeOption = AppThemeOption.values.firstWhere(
        (element) => element.toString() == themeOptionValue,
        orElse: () => AppThemeOption.loveTheme,
      );
    }
    
    if (customThemeColorsJson != null) {
      try {
        final Map<String, dynamic> colorsMap = Map<String, dynamic>.from(
          Map.castFrom(json.decode(customThemeColorsJson))
        );
        _customThemeColors = CustomThemeColors.fromJson(colorsMap);
      } catch (e) {
        // If there's an error, use default colors
        _customThemeColors = CustomThemeColors.defaultColors();
      }
    }
    
    notifyListeners();
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.toString());
  }
  
  Future<void> setThemeOption(AppThemeOption option) async {
    _themeOption = option;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeOptionKey, option.toString());
  }
  
  Future<void> setCustomThemeColors(CustomThemeColors colors) async {
    _customThemeColors = colors;
    
    if (_themeOption != AppThemeOption.customTheme) {
      _themeOption = AppThemeOption.customTheme;
    }
    
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customThemeColorsKey, json.encode(colors.toJson()));
    await prefs.setString(_themeOptionKey, AppThemeOption.customTheme.toString());
  }
  
  Future<void> updateCustomThemeColor({
    Color? primary,
    Color? secondary,
    Color? tertiary,
    Color? background,
    Color? surface,
    Color? text,
    Color? icon,
  }) async {
    final updatedColors = _customThemeColors.copyWith(
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      background: background,
      surface: surface,
      text: text,
      icon: icon,
    );
    
    await setCustomThemeColors(updatedColors);
  }
  
  String getThemeOptionName(AppThemeOption option) {
    switch (option) {
      case AppThemeOption.loveTheme:
        return 'Love Theme';
      case AppThemeOption.careTheme:
        return 'Care Theme';
      case AppThemeOption.focusTheme:
        return 'Focus Theme';
      case AppThemeOption.peaceTheme:
        return 'Peace Theme';
      case AppThemeOption.joyTheme:
        return 'Joy Theme';
      case AppThemeOption.redTheme:
        return 'Red Theme';
      case AppThemeOption.darkTheme:
        return 'Dark Theme';
      case AppThemeOption.dayTheme:
        return 'Day Theme';
      case AppThemeOption.transparentTheme:
        return 'Transparent Theme';
      case AppThemeOption.premiumTheme:
        return 'Premium Theme';
      case AppThemeOption.neonTheme:
        return 'Neon Theme';  
      case AppThemeOption.customTheme:
        return 'Custom Theme';
    }
  }
  
  IconData getThemeOptionIcon(AppThemeOption option) {
    switch (option) {
      case AppThemeOption.loveTheme:
        return Icons.favorite;
      case AppThemeOption.careTheme:
        return Icons.volunteer_activism;
      case AppThemeOption.focusTheme:
        return Icons.center_focus_strong;
      case AppThemeOption.peaceTheme:
        return Icons.spa;
      case AppThemeOption.joyTheme:
        return Icons.emoji_emotions;
      case AppThemeOption.redTheme:
        return Icons.local_fire_department;
      case AppThemeOption.darkTheme:
        return Icons.dark_mode;
      case AppThemeOption.dayTheme:
        return Icons.wb_sunny;
      case AppThemeOption.transparentTheme:
        return Icons.layers;
      case AppThemeOption.premiumTheme:
        return Icons.workspace_premium;
      case AppThemeOption.neonTheme:
        return Icons.electric_bolt;
      case AppThemeOption.customTheme:
        return Icons.color_lens;
    }
  }
  
  Color getThemeOptionPreviewColor(AppThemeOption option) {
    switch (option) {
      case AppThemeOption.loveTheme:
        return AppTheme.getPrimaryColor(option);
      case AppThemeOption.careTheme:
        return AppTheme.getPrimaryColor(option);
      case AppThemeOption.focusTheme:
        return AppTheme.getPrimaryColor(option);
      case AppThemeOption.peaceTheme:
        return AppTheme.getPrimaryColor(option);
      case AppThemeOption.joyTheme:
        return AppTheme.getPrimaryColor(option);
      case AppThemeOption.redTheme:
        return AppTheme.getPrimaryColor(option);
      case AppThemeOption.darkTheme:
        return Colors.grey.shade900;
      case AppThemeOption.dayTheme:
        return Colors.blue.shade300;
      case AppThemeOption.transparentTheme:
        return Colors.transparent;
      case AppThemeOption.premiumTheme:
        return AppTheme.getPrimaryColor(option);
      case AppThemeOption.neonTheme:
        return AppTheme.getPrimaryColor(option);
      case AppThemeOption.customTheme:
        return _customThemeColors.primary;
    }
  }
  
  ThemeData get currentTheme {
    if (_themeMode == ThemeMode.dark) {
      return AppTheme.getTheme(_themeOption, true, _customThemeColors);
    } else {
      return AppTheme.getTheme(_themeOption, false, _customThemeColors);
    }
  }
} 