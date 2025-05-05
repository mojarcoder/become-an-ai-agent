import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = "Become an AI agent";
  static const String appVersion = "1.0.2";
  
  // Navigation Routes
  static const String homeRoute = "/";
  static const String knowledgeBaseRoute = "/knowledge-base";
  static const String techStackRoute = "/tech-stack";
  static const String projectTrackerRoute = "/projects";
  static const String codeCompareRoute = "/code-compare";
  static const String notesRoute = "/notes";
  static const String designPatternsRoute = "/design-patterns";
  static const String journalRoute = "/journal";
  static const String settingsRoute = "/settings";
  static const String dashboardRoute = "/dashboard";
  
  // Storage Keys
  static const String themePreferenceKey = "theme_preference";
  static const String userDataBox = "user_data";
  static const String knowledgeBaseBox = "knowledge_base";
  static const String techStackBox = "tech_stack";
  static const String projectsBox = "projects";
  static const String codeCompareBox = "code_compare";
  static const String notesBox = "notes";
  static const String designPatternsBox = "design_patterns";
  static const String journalBox = "journal";
  
  // Categories
  static const List<String> knowledgeCategories = [
    "Flutter", "Dart", "UI/UX", "State Management", 
    "Backend", "Architecture", "Testing", "Performance",
    "Kotlin", "Swift", "JavaScript", "APIs", "Database"
  ];
  
  static const List<String> skillLevels = [
    "Beginner", "Intermediate", "Advanced", "Expert"
  ];
  
  static const List<String> projectStatuses = [
    "Planned", "In Progress", "On Hold", "Completed", "Archived"
  ];
  
  static const List<String> designPatternTypes = [
    "Creational", "Structural", "Behavioral"
  ];
  
  static const List<String> dsaCategories = [
    "Arrays", "Linked Lists", "Stacks", "Queues", "Trees", 
    "Graphs", "Sorting", "Searching", "Dynamic Programming", 
    "Greedy Algorithms", "Recursion"
  ];
  
  static const List<String> noteTypes = [
    "Bullet Notes", "Checklist", "Zettelkasten", "Mind Map", "Code Snippet"
  ];
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double cardElevation = 2.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 350);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Default Colors (will be overridden by theme)
  static const Color primaryDarkColor = Color(0xFF2C3E50);
  static const Color accentDarkColor = Color(0xFF5D9CEC);
  static const Color backgroundDarkColor = Color(0xFF121212);
  static const Color primaryLightColor = Color(0xFF3498DB);
  static const Color accentLightColor = Color(0xFF5D9CEC);
  static const Color backgroundLightColor = Color(0xFFF5F5F5);
} 