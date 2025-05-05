import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:become_an_ai_agent/models/dsa_model.dart';

class DSAProvider extends ChangeNotifier {
  static const String _dsaItemsKey = 'dsa_items';
  
  List<DSAItem> _dsaItems = [];
  DSACategory? _selectedCategory;
  String _searchQuery = '';
  
  List<DSAItem> get dsaItems => _dsaItems;
  DSACategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  
  DSAProvider() {
    _loadDSAItems();
  }
  
  Future<void> _loadDSAItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? itemsJson = prefs.getString(_dsaItemsKey);
    
    if (itemsJson != null) {
      final List<dynamic> decodedItems = json.decode(itemsJson);
      _dsaItems = decodedItems.map((item) => DSAItem.fromJson(item)).toList();
    } else {
      // Load sample items for first-time users
      _dsaItems = getSampleDSAItems();
      _saveDSAItems();
    }
    
    notifyListeners();
  }
  
  Future<void> _saveDSAItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String itemsJson = json.encode(_dsaItems.map((item) => item.toJson()).toList());
    
    await prefs.setString(_dsaItemsKey, itemsJson);
  }
  
  Future<void> addDSAItem(DSAItem item) async {
    _dsaItems.add(item);
    notifyListeners();
    
    await _saveDSAItems();
  }
  
  Future<void> updateDSAItem(DSAItem updatedItem) async {
    final itemIndex = _dsaItems.indexWhere((item) => item.id == updatedItem.id);
    
    if (itemIndex != -1) {
      _dsaItems[itemIndex] = updatedItem;
      notifyListeners();
      
      await _saveDSAItems();
    }
  }
  
  Future<void> deleteDSAItem(String id) async {
    _dsaItems.removeWhere((item) => item.id == id);
    notifyListeners();
    
    await _saveDSAItems();
  }
  
  Future<void> toggleFavorite(String id) async {
    final itemIndex = _dsaItems.indexWhere((item) => item.id == id);
    
    if (itemIndex != -1) {
      final item = _dsaItems[itemIndex];
      _dsaItems[itemIndex] = item.copyWith(isFavorite: !item.isFavorite);
      notifyListeners();
      
      await _saveDSAItems();
    }
  }
  
  Future<void> updateProficiencyLevel(String id, int level) async {
    final itemIndex = _dsaItems.indexWhere((item) => item.id == id);
    
    if (itemIndex != -1) {
      final item = _dsaItems[itemIndex];
      _dsaItems[itemIndex] = item.copyWith(
        proficiencyLevel: level,
        lastReviewed: DateTime.now(),
      );
      notifyListeners();
      
      await _saveDSAItems();
    }
  }
  
  void setSelectedCategory(DSACategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }
  
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  List<DSAItem> getFilteredItems() {
    return _dsaItems.where((item) {
      // Apply category filter if selected
      if (_selectedCategory != null && item.category != _selectedCategory) {
        return false;
      }
      
      // Apply search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return item.name.toLowerCase().contains(query) ||
               item.description.toLowerCase().contains(query) ||
               item.tags.any((tag) => tag.toLowerCase().contains(query));
      }
      
      return true;
    }).toList();
  }
  
  List<DSAItem> getFavoriteItems() {
    return _dsaItems.where((item) => item.isFavorite).toList();
  }
  
  List<DSAItem> getItemsByCategory(DSACategory category) {
    return _dsaItems.where((item) => item.category == category).toList();
  }
  
  Map<String, int> getCategoryDistribution() {
    final distribution = <String, int>{};
    
    for (final category in DSACategory.values) {
      final categoryName = DSAItem.getCategoryName(category);
      final count = _dsaItems.where((item) => item.category == category).length;
      
      if (count > 0) {
        distribution[categoryName] = count;
      }
    }
    
    return distribution;
  }
  
  double getAverageProficiency() {
    if (_dsaItems.isEmpty) return 0.0;
    
    final totalProficiency = _dsaItems.fold<int>(
      0, (sum, item) => sum + item.proficiencyLevel
    );
    
    return totalProficiency / _dsaItems.length;
  }
  
  Map<int, int> getProficiencyDistribution() {
    final distribution = <int, int>{};
    
    for (int level = 1; level <= 5; level++) {
      final count = _dsaItems.where((item) => item.proficiencyLevel == level).length;
      distribution[level] = count;
    }
    
    return distribution;
  }
} 