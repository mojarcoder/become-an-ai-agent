import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:become_an_ai_agent/core/theme/theme_provider.dart';

import '../constants/app_constants.dart';

class AppTheme {
  // Theme color schemes
  
  // Love Theme - Pink/Purple
  static const _loveThemePrimary = Color(0xFFE91E63);
  static const _loveThemeSecondary = Color(0xFF9C27B0);
  static const _loveThemeTertiary = Color(0xFFF8BBD0);
  static const _loveThemeForeground = Colors.white;
  
  // Care Theme - Green/Teal
  static const _careThemePrimary = Color(0xFF26A69A);
  static const _careThemeSecondary = Color(0xFF4CAF50);
  static const _careThemeTertiary = Color(0xFFB2DFDB);
  static const _careThemeForeground = Colors.white;
  
  // Focus Theme - Blue/Indigo
  static const _focusThemePrimary = Color(0xFF3F51B5);
  static const _focusThemeSecondary = Color(0xFF2196F3);
  static const _focusThemeTertiary = Color(0xFFC5CAE9);
  static const _focusThemeForeground = Colors.white;
  
  // Peace Theme - Light Blue/Cyan
  static const _peaceThemePrimary = Color(0xFF00BCD4);
  static const _peaceThemeSecondary = Color(0xFF03A9F4);
  static const _peaceThemeTertiary = Color(0xFFB2EBF2);
  static const _peaceThemeForeground = Colors.white;
  
  // Joy Theme - Amber/Orange
  static const _joyThemePrimary = Color(0xFFFFC107);
  static const _joyThemeSecondary = Color(0xFFFF9800);
  static const _joyThemeTertiary = Color(0xFFFFECB3);
  static const _joyThemeForeground = Colors.black;
  
  // Red Theme - Red/Pink
  static const _redThemePrimary = Color(0xFFF44336);
  static const _redThemeSecondary = Color(0xFFE91E63);
  static const _redThemeTertiary = Color(0xFFFFCDD2);
  static const _redThemeForeground = Colors.white;
  
  // New Premium Theme - Gold/Black
  static const _premiumThemePrimary = Color(0xFFFFD700);
  static const _premiumThemeSecondary = Color(0xFF212121);
  static const _premiumThemeTertiary = Color(0xFFFFF8E1);
  static const _premiumThemeForeground = Colors.black;
  
  // New Neon Theme - Electric colors
  static const _neonThemePrimary = Color(0xFF00FF85);
  static const _neonThemeSecondary = Color(0xFFFF00E4);
  static const _neonThemeTertiary = Color(0xFF001029);
  static const _neonThemeForeground = Colors.white;
  
  // Dark Theme - Grey
  static const _darkThemePrimary = Color(0xFF455A64);
  static const _darkThemeSecondary = Color(0xFF607D8B);
  static const _darkThemeTertiary = Color(0xFF78909C);
  static const _darkThemeForeground = Colors.white;
  
  // Day Theme - Light Blue/Yellow
  static const _dayThemePrimary = Color(0xFF42A5F5);
  static const _dayThemeSecondary = Color(0xFFFBC02D);
  static const _dayThemeTertiary = Color(0xFFE1F5FE);
  static const _dayThemeForeground = Colors.white;
  
  // Transparent Theme
  static const _transparentThemePrimary = Color(0xAAFFFFFF);
  static const _transparentThemeSecondary = Color(0xAAE0E0E0);
  static const _transparentThemeTertiary = Color(0xAABBDEFB);
  static const _transparentThemeForeground = Color(0xFF333333);

  // Static getters for default themes
  static ThemeData get lightTheme => getTheme(AppThemeOption.loveTheme, false, null);
  static ThemeData get darkTheme => getTheme(AppThemeOption.loveTheme, true, null);

  // Get primary, secondary and tertiary colors based on theme option
  static Color getPrimaryColor(AppThemeOption option) {
    switch (option) {
      case AppThemeOption.loveTheme:
        return _loveThemePrimary;
      case AppThemeOption.careTheme:
        return _careThemePrimary;
      case AppThemeOption.focusTheme:
        return _focusThemePrimary;
      case AppThemeOption.peaceTheme:
        return _peaceThemePrimary;
      case AppThemeOption.joyTheme:
        return _joyThemePrimary;
      case AppThemeOption.redTheme:
        return _redThemePrimary;
      case AppThemeOption.darkTheme:
        return _darkThemePrimary;
      case AppThemeOption.dayTheme:
        return _dayThemePrimary;
      case AppThemeOption.transparentTheme:
        return _transparentThemePrimary;
      case AppThemeOption.premiumTheme:
        return _premiumThemePrimary;
      case AppThemeOption.neonTheme:
        return _neonThemePrimary;
      case AppThemeOption.customTheme:
        // This is handled in getTheme method with customColors
        return _loveThemePrimary;
    }
  }
  
  static Color getSecondaryColor(AppThemeOption option) {
    switch (option) {
      case AppThemeOption.loveTheme:
        return _loveThemeSecondary;
      case AppThemeOption.careTheme:
        return _careThemeSecondary;
      case AppThemeOption.focusTheme:
        return _focusThemeSecondary;
      case AppThemeOption.peaceTheme:
        return _peaceThemeSecondary;
      case AppThemeOption.joyTheme:
        return _joyThemeSecondary;
      case AppThemeOption.redTheme:
        return _redThemeSecondary;
      case AppThemeOption.darkTheme:
        return _darkThemeSecondary;
      case AppThemeOption.dayTheme:
        return _dayThemeSecondary;
      case AppThemeOption.transparentTheme:
        return _transparentThemeSecondary;
      case AppThemeOption.premiumTheme:
        return _premiumThemeSecondary;
      case AppThemeOption.neonTheme:
        return _neonThemeSecondary;
      case AppThemeOption.customTheme:
        // This is handled in getTheme method with customColors
        return _loveThemeSecondary;
    }
  }
  
  static Color getTertiaryColor(AppThemeOption option) {
    switch (option) {
      case AppThemeOption.loveTheme:
        return _loveThemeTertiary;
      case AppThemeOption.careTheme:
        return _careThemeTertiary;
      case AppThemeOption.focusTheme:
        return _focusThemeTertiary;
      case AppThemeOption.peaceTheme:
        return _peaceThemeTertiary;
      case AppThemeOption.joyTheme:
        return _joyThemeTertiary;
      case AppThemeOption.redTheme:
        return _redThemeTertiary;
      case AppThemeOption.darkTheme:
        return _darkThemeTertiary;
      case AppThemeOption.dayTheme:
        return _dayThemeTertiary;
      case AppThemeOption.transparentTheme:
        return _transparentThemeTertiary;
      case AppThemeOption.premiumTheme:
        return _premiumThemeTertiary;
      case AppThemeOption.neonTheme:
        return _neonThemeTertiary;
      case AppThemeOption.customTheme:
        // This is handled in getTheme method with customColors
        return _loveThemeTertiary;
    }
  }
  
  static Color getForegroundColor(AppThemeOption option) {
    switch (option) {
      case AppThemeOption.loveTheme:
        return _loveThemeForeground;
      case AppThemeOption.careTheme:
        return _careThemeForeground;
      case AppThemeOption.focusTheme:
        return _focusThemeForeground;
      case AppThemeOption.peaceTheme:
        return _peaceThemeForeground;
      case AppThemeOption.joyTheme:
        return _joyThemeForeground;
      case AppThemeOption.redTheme:
        return _redThemeForeground;
      case AppThemeOption.darkTheme:
        return _darkThemeForeground;
      case AppThemeOption.dayTheme:
        return _dayThemeForeground;
      case AppThemeOption.transparentTheme:
        return _transparentThemeForeground;
      case AppThemeOption.premiumTheme:
        return _premiumThemeForeground;
      case AppThemeOption.neonTheme:
        return _neonThemeForeground;
      case AppThemeOption.customTheme:
        return Colors.white;
    }
  }

  // Get theme data based on option and mode
  static ThemeData getTheme(AppThemeOption option, bool isDark, CustomThemeColors? customColors) {
    Color primaryColor;
    Color secondaryColor;
    Color tertiaryColor;
    Color foregroundColor;
    
    if (option == AppThemeOption.customTheme && customColors != null) {
      primaryColor = customColors.primary;
      secondaryColor = customColors.secondary;
      tertiaryColor = customColors.tertiary;
      foregroundColor = getBestForegroundColor(primaryColor);
    } else {
      primaryColor = getPrimaryColor(option);
      secondaryColor = getSecondaryColor(option);
      tertiaryColor = getTertiaryColor(option);
      foregroundColor = getForegroundColor(option);
    }
    
    // For transparent theme, we need special handling
    if (option == AppThemeOption.transparentTheme) {
      return _createTransparentTheme(primaryColor, secondaryColor, tertiaryColor, isDark);
    }
    
    return isDark 
      ? _createDarkTheme(primaryColor, secondaryColor, tertiaryColor, option, customColors, foregroundColor)
      : _createLightTheme(primaryColor, secondaryColor, tertiaryColor, option, customColors, foregroundColor);
  }
  
  // Helper method to determine best foreground color based on background color
  static Color getBestForegroundColor(Color backgroundColor) {
    // Calculate luminance - if color is bright use dark text, if dark use light text
    final double luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // Get contrasting text color with proper opacity based on emphasis
  static Color getTextOnColor(Color backgroundColor, {bool highEmphasis = true}) {
    final baseColor = getBestForegroundColor(backgroundColor);
    // High emphasis (headlines, important text): 87% opacity for dark on light, 100% for light on dark
    // Medium emphasis (body text): 60% opacity for dark on light, 70% for light on dark
    final opacity = baseColor == Colors.black
        ? (highEmphasis ? 0.87 : 0.60)
        : (highEmphasis ? 1.0 : 0.70);
    
    return baseColor.withOpacity(opacity);
  }

  // Light Theme
  static ThemeData _createLightTheme(
    Color primary, 
    Color secondary, 
    Color tertiary,
    AppThemeOption option,
    CustomThemeColors? customColors,
    Color foregroundColor
  ) {
    // For a custom theme, use the custom colors
    final backgroundColor = (option == AppThemeOption.customTheme && customColors != null)
        ? customColors.background
        : Colors.white;
    
    final surfaceColor = (option == AppThemeOption.customTheme && customColors != null)
        ? customColors.surface
        : Colors.grey.shade50;
    
    // Improved text colors with proper emphasis levels
    final textColor = (option == AppThemeOption.customTheme && customColors != null)
        ? customColors.text
        : getTextOnColor(backgroundColor, highEmphasis: true);
    
    final bodyTextColor = (option == AppThemeOption.customTheme && customColors != null)
        ? customColors.text.withOpacity(0.8)
        : getTextOnColor(backgroundColor, highEmphasis: false);
    
    final iconColor = (option == AppThemeOption.customTheme && customColors != null)
        ? customColors.icon
        : getTextOnColor(backgroundColor, highEmphasis: false);
    
    return FlexThemeData.light(
      colors: FlexSchemeColor(
        primary: primary,
        primaryContainer: primary.withOpacity(0.2),
        secondary: secondary,
        secondaryContainer: secondary.withOpacity(0.2),
        tertiary: tertiary,
        tertiaryContainer: tertiary.withOpacity(0.2),
        appBarColor: primary,
        error: const Color(0xFFE53935),
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 15,
      appBarOpacity: 0.95,
      subThemesData: FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        inputDecoratorRadius: AppConstants.borderRadius,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        cardRadius: AppConstants.borderRadius,
        popupMenuRadius: AppConstants.smallBorderRadius,
        bottomSheetRadius: 24.0,
        dialogRadius: 20.0,
        timePickerDialogRadius: 20.0,
        appBarBackgroundSchemeColor: SchemeColor.primary,
        tabBarItemSchemeColor: SchemeColor.primary,
        navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        navigationBarSelectedIconSchemeColor: SchemeColor.primary,
        navigationBarIndicatorSchemeColor: SchemeColor.primaryContainer,
        navigationBarBackgroundSchemeColor: SchemeColor.surfaceVariant,
        chipSchemeColor: SchemeColor.primaryContainer,
        chipSelectedSchemeColor: SchemeColor.primary,
        tooltipRadius: 4,
        tooltipSchemeColor: SchemeColor.primaryContainer,
        snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
        // Enhanced UI elements
        interactionEffects: true,
        tintedDisabledControls: true,
        blendTextTheme: true,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        adaptiveRemoveElevationTint: FlexAdaptive.all(),
        adaptiveElevationShadowsBack: FlexAdaptive.all(),
        adaptiveSplash: FlexAdaptive.all(),
        splashType: FlexSplashType.defaultSplash,
        buttonMinSize: const Size(64, 40),
        buttonPadding: const EdgeInsets.symmetric(horizontal: 16),
        thickBorderWidth: 2.0,
        defaultRadius: 16,
        fabUseShape: true,
        fabRadius: 16,
        fabSchemeColor: SchemeColor.primary,
        sliderValueTinted: true,
        sliderBaseSchemeColor: SchemeColor.primary,
        sliderIndicatorSchemeColor: SchemeColor.primary,
        switchSchemeColor: SchemeColor.primary,
        checkboxSchemeColor: SchemeColor.primary,
        radioSchemeColor: SchemeColor.primary,
        unselectedToggleIsColored: true,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
      ),
      tones: FlexTones.jolly(Brightness.light),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      fontFamily: 'Poppins',
    ).copyWith(
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.light(
        surface: surfaceColor,
        onSurface: textColor,
        primary: primary,
        onPrimary: foregroundColor,
        secondary: secondary,
        onSecondary: foregroundColor,
        tertiary: tertiary,
        onTertiary: getBestForegroundColor(tertiary),
      ),
      appBarTheme: AppBarTheme(
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: foregroundColor,
        ),
        elevation: 0.5,
        shadowColor: Colors.black12,
        backgroundColor: primary,
        foregroundColor: foregroundColor,
        iconTheme: IconThemeData(color: foregroundColor),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.light().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w700),
        displayMedium: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600),
        displaySmall: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600),
        headlineLarge: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.poppins(color: bodyTextColor, fontWeight: FontWeight.normal),
        bodyMedium: GoogleFonts.poppins(color: bodyTextColor, fontWeight: FontWeight.normal),
        bodySmall: GoogleFonts.poppins(color: bodyTextColor.withOpacity(0.8), fontWeight: FontWeight.normal),
        labelLarge: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w500),
        labelMedium: GoogleFonts.poppins(color: bodyTextColor, fontWeight: FontWeight.normal),
        labelSmall: GoogleFonts.poppins(color: bodyTextColor.withOpacity(0.8), fontWeight: FontWeight.normal),
      ),
      iconTheme: IconThemeData(
        color: iconColor,
      ),
      cardTheme: CardTheme(
        elevation: 3,
        shadowColor: Colors.black12,
        color: surfaceColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          foregroundColor: foregroundColor,
          backgroundColor: primary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          foregroundColor: primary,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          foregroundColor: primary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }

  // Dark Theme
  static ThemeData _createDarkTheme(
    Color primary, 
    Color secondary, 
    Color tertiary,
    AppThemeOption option,
    CustomThemeColors? customColors,
    Color foregroundColor
  ) {
    // For a custom theme, use the custom colors
    final backgroundColor = (option == AppThemeOption.customTheme && customColors != null)
        ? customColors.background
        : const Color(0xFF121212); // Darker background
    
    final surfaceColor = (option == AppThemeOption.customTheme && customColors != null)
        ? customColors.surface
        : const Color(0xFF1E1E1E); // Slightly lighter than background
    
    // Improved text colors with proper emphasis levels
    final textColor = (option == AppThemeOption.customTheme && customColors != null)
        ? customColors.text
        : getTextOnColor(backgroundColor, highEmphasis: true);
    
    final bodyTextColor = (option == AppThemeOption.customTheme && customColors != null)
        ? customColors.text.withOpacity(0.7)
        : getTextOnColor(backgroundColor, highEmphasis: false);
    
    final iconColor = (option == AppThemeOption.customTheme && customColors != null)
        ? customColors.icon
        : getTextOnColor(backgroundColor, highEmphasis: false);
    
    return FlexThemeData.dark(
      colors: FlexSchemeColor(
        primary: primary,
        primaryContainer: primary.withOpacity(0.2),
        secondary: secondary,
        secondaryContainer: secondary.withOpacity(0.2),
        tertiary: tertiary,
        tertiaryContainer: tertiary.withOpacity(0.2),
        appBarColor: primary,
        error: const Color(0xFFE53935),
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 20,
      appBarOpacity: 0.95,
      subThemesData: FlexSubThemesData(
        blendOnLevel: 20,
        appBarBackgroundSchemeColor: SchemeColor.primary,
        inputDecoratorRadius: AppConstants.borderRadius,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        cardRadius: AppConstants.borderRadius,
        popupMenuRadius: AppConstants.smallBorderRadius,
        bottomSheetRadius: 24.0,
        dialogRadius: 20.0,
        timePickerDialogRadius: 20.0,
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        bottomNavigationBarSelectedIconSchemeColor: SchemeColor.primary,
        navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        navigationBarSelectedIconSchemeColor: SchemeColor.primary,
        navigationBarIndicatorSchemeColor: SchemeColor.primary,
        navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
        navigationRailSelectedIconSchemeColor: SchemeColor.primary,
        navigationRailIndicatorSchemeColor: SchemeColor.primary,
        chipSchemeColor: SchemeColor.primaryContainer,
        chipSelectedSchemeColor: SchemeColor.primary,
        tooltipRadius: 4,
        tooltipSchemeColor: SchemeColor.inverseSurface,
        // Enhanced UI elements
        interactionEffects: true,
        tintedDisabledControls: true,
        blendTextTheme: true,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        adaptiveRemoveElevationTint: FlexAdaptive.all(),
        adaptiveElevationShadowsBack: FlexAdaptive.all(),
        adaptiveSplash: FlexAdaptive.all(),
        splashType: FlexSplashType.defaultSplash,
        buttonMinSize: const Size(64, 40),
        buttonPadding: const EdgeInsets.symmetric(horizontal: 16),
        thickBorderWidth: 2.0,
        defaultRadius: 16,
        fabUseShape: true,
        fabRadius: 16,
        sliderValueTinted: true,
        sliderBaseSchemeColor: SchemeColor.primary,
        sliderIndicatorSchemeColor: SchemeColor.primary,
        switchSchemeColor: SchemeColor.primary,
        checkboxSchemeColor: SchemeColor.primary,
        radioSchemeColor: SchemeColor.primary,
        unselectedToggleIsColored: true,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
      ),
      tones: FlexTones.jolly(Brightness.dark),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      fontFamily: 'Poppins',
    ).copyWith(
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.dark(
        surface: surfaceColor,
        onSurface: textColor,
        primary: primary,
        onPrimary: foregroundColor,
        secondary: secondary,
        onSecondary: foregroundColor,
        tertiary: tertiary,
        onTertiary: getBestForegroundColor(tertiary),
      ),
      appBarTheme: AppBarTheme(
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: foregroundColor,
        ),
        backgroundColor: primary,
        foregroundColor: foregroundColor,
        iconTheme: IconThemeData(color: foregroundColor),
        elevation: 0,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w700),
        displayMedium: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600),
        displaySmall: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600),
        headlineLarge: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.poppins(color: bodyTextColor, fontWeight: FontWeight.normal),
        bodyMedium: GoogleFonts.poppins(color: bodyTextColor, fontWeight: FontWeight.normal),
        bodySmall: GoogleFonts.poppins(color: bodyTextColor.withOpacity(0.8), fontWeight: FontWeight.normal),
        labelLarge: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w500),
        labelMedium: GoogleFonts.poppins(color: bodyTextColor, fontWeight: FontWeight.normal),
        labelSmall: GoogleFonts.poppins(color: bodyTextColor.withOpacity(0.8), fontWeight: FontWeight.normal),
      ),
      iconTheme: IconThemeData(
        color: iconColor,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shadowColor: Colors.black45,
        color: surfaceColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          foregroundColor: foregroundColor,
          backgroundColor: primary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: primary.withOpacity(0.8)),
          foregroundColor: primary,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          foregroundColor: primary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor.withOpacity(0.7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }
  
  // Transparent Theme
  static ThemeData _createTransparentTheme(
    Color primary,
    Color secondary,
    Color tertiary,
    bool isDark
  ) {
    final baseThemeOption = isDark ? AppThemeOption.darkTheme : AppThemeOption.dayTheme;
    final baseTheme = isDark 
        ? _createDarkTheme(primary, secondary, tertiary, AppThemeOption.transparentTheme, null, _transparentThemeForeground)
        : _createLightTheme(primary, secondary, tertiary, AppThemeOption.transparentTheme, null, _transparentThemeForeground);
        
    // For a transparent theme, we need higher contrast text
    final backgroundColor = Colors.transparent;
    final surfaceColor = (isDark ? Colors.black : Colors.white).withOpacity(0.2);
    
    // Ensure high contrast for text regardless of background
    final textColor = isDark ? Colors.white.withOpacity(0.95) : Colors.black.withOpacity(0.87);
    final bodyTextColor = isDark ? Colors.white.withOpacity(0.85) : Colors.black.withOpacity(0.75);
    
    final textTheme = GoogleFonts.poppinsTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme
    ).copyWith(
      displayLarge: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w700),
      displayMedium: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600),
      displaySmall: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600),
      headlineLarge: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600),
      headlineMedium: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.poppins(color: bodyTextColor, fontWeight: FontWeight.normal),
      bodyMedium: GoogleFonts.poppins(color: bodyTextColor, fontWeight: FontWeight.normal),
      bodySmall: GoogleFonts.poppins(color: bodyTextColor.withOpacity(0.8), fontWeight: FontWeight.normal),
      labelLarge: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w500),
      labelMedium: GoogleFonts.poppins(color: bodyTextColor, fontWeight: FontWeight.normal),
      labelSmall: GoogleFonts.poppins(color: bodyTextColor.withOpacity(0.8), fontWeight: FontWeight.normal),
    );
    
    return baseTheme.copyWith(
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: (isDark ? ColorScheme.dark() : ColorScheme.light()).copyWith(
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: surfaceColor,
        onPrimary: _transparentThemeForeground,
        onSecondary: _transparentThemeForeground,
        onSurface: textColor,
      ),
      textTheme: textTheme,
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
          ),
        ),
      ),
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: surfaceColor,
        elevation: 0,
        iconTheme: IconThemeData(color: _transparentThemeForeground),
        titleTextStyle: baseTheme.appBarTheme.titleTextStyle?.copyWith(
          color: _transparentThemeForeground,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        elevation: 0,
        selectedItemColor: primary,
        unselectedItemColor: textColor.withOpacity(0.6),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surfaceColor.withOpacity(0.8),
        elevation: 0,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      // Create a blur effect for various material components
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
} 