import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:become_an_ai_agent/core/theme/theme_provider.dart';
import 'package:become_an_ai_agent/core/widgets/custom_app_bar.dart';
import 'package:become_an_ai_agent/core/widgets/custom_card.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:become_an_ai_agent/core/theme/app_theme.dart';

class ThemeCustomizationScreen extends StatelessWidget {
  const ThemeCustomizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Theme Customization',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThemeOptionSection(context, themeProvider),
            const SizedBox(height: 24),
            _buildThemeModeSection(context, themeProvider),
            const SizedBox(height: 24),
            if (themeProvider.isCustomTheme) ...[
              _buildCustomThemeSection(context, themeProvider),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOptionSection(BuildContext context, ThemeProvider themeProvider) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Theme Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppThemeOption.values.map((option) {
                final isSelected = themeProvider.themeOption == option;
                // Get the proper foreground color for the theme
                final themeColor = themeProvider.getThemeOptionPreviewColor(option);
                final foregroundColor = option == AppThemeOption.customTheme 
                    ? AppTheme.getBestForegroundColor(themeColor)
                    : AppTheme.getForegroundColor(option);
                
                return GestureDetector(
                  onTap: () {
                    themeProvider.setThemeOption(option);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: themeColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : themeColor.computeLuminance() > 0.7 
                                  ? Colors.grey.shade400 
                                  : Colors.transparent,
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          themeProvider.getThemeOptionIcon(option),
                          color: foregroundColor,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        themeProvider.getThemeOptionName(option),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeSection(BuildContext context, ThemeProvider themeProvider) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Theme Mode',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            RadioListTile<ThemeMode>(
              title: const Text('Light Mode'),
              subtitle: const Text('Light theme for all themes'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark Mode'),
              subtitle: const Text('Dark theme for all themes'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System Mode'),
              subtitle: const Text('Follow system brightness settings'),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomThemeSection(BuildContext context, ThemeProvider themeProvider) {
    final customColors = themeProvider.customThemeColors;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Custom Theme Colors',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {
                themeProvider.setCustomThemeColors(
                  CustomThemeColors.defaultColors(),
                );
              },
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        CustomCard(
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildColorPickerTile(
                context,
                'Primary Color',
                customColors.primary,
                (color) => themeProvider.updateCustomThemeColor(primary: color),
              ),
              _buildColorPickerTile(
                context,
                'Secondary Color',
                customColors.secondary,
                (color) => themeProvider.updateCustomThemeColor(secondary: color),
              ),
              _buildColorPickerTile(
                context,
                'Tertiary Color',
                customColors.tertiary,
                (color) => themeProvider.updateCustomThemeColor(tertiary: color),
              ),
              _buildColorPickerTile(
                context,
                'Background Color',
                customColors.background,
                (color) => themeProvider.updateCustomThemeColor(background: color),
              ),
              _buildColorPickerTile(
                context,
                'Surface Color',
                customColors.surface,
                (color) => themeProvider.updateCustomThemeColor(surface: color),
              ),
              _buildColorPickerTile(
                context,
                'Text Color',
                customColors.text,
                (color) => themeProvider.updateCustomThemeColor(text: color),
              ),
              _buildColorPickerTile(
                context,
                'Icon Color',
                customColors.icon,
                (color) => themeProvider.updateCustomThemeColor(icon: color),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Theme Preview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: customColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.palette,
                        color: AppTheme.getBestForegroundColor(customColors.primary),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Primary Color',
                        style: TextStyle(
                          color: AppTheme.getBestForegroundColor(customColors.primary),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: customColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.color_lens,
                        color: AppTheme.getBestForegroundColor(customColors.secondary),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Secondary Color',
                        style: TextStyle(
                          color: AppTheme.getBestForegroundColor(customColors.secondary),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: customColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text(
                            'Background',
                            style: TextStyle(
                              color: customColors.text,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: customColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text(
                            'Surface',
                            style: TextStyle(
                              color: customColors.text,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPickerTile(
    BuildContext context,
    String title,
    Color currentColor,
    Function(Color) onColorChanged,
  ) {
    return ListTile(
      title: Text(title),
      trailing: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: currentColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      onTap: () => _showColorPicker(
        context,
        title,
        currentColor,
        onColorChanged,
      ),
    );
  }

  void _showColorPicker(
    BuildContext context,
    String title,
    Color currentColor,
    Function(Color) onColorChanged,
  ) {
    Color pickerColor = currentColor;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose $title'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                pickerColor = color;
              },
              pickerAreaHeightPercent: 0.8,
              labelTypes: const [],
              displayThumbColor: true,
              enableAlpha: true,
              showLabel: true,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Select'),
              onPressed: () {
                onColorChanged(pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
} 