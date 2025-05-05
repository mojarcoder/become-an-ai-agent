import 'package:flutter/material.dart';
import 'package:become_an_ai_agent/services/auth_service.dart';
import 'dart:convert';
import 'dart:typed_data';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  bool _isAuthenticated = false;
  String? _userId;
  String? _userName;
  String? _userEmail;
  Uint8List? _profileImage;

  AuthProvider(this._authService) {
    _init();
  }

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  Uint8List? get profileImage => _profileImage;

  Future<void> _init() async {
    _isAuthenticated = await _authService.isAuthenticated();
    if (_isAuthenticated) {
      _userId = await _authService.getUserId();
      _userName = await _authService.getUserName();
      _userEmail = await _authService.getUserEmail();
      final imageStr = await _authService.getProfileImage();
      if (imageStr != null) {
        _profileImage = base64Decode(imageStr);
      }
    }
    notifyListeners();
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final success = await _authService.signUp(
      name: name,
      email: email,
      password: password,
    );

    if (success) {
      await _init();
    }

    return success;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final success = await _authService.login(
      email: email,
      password: password,
    );

    if (success) {
      await _init();
    }

    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    _userId = null;
    _userName = null;
    _userEmail = null;
    _profileImage = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
  }) async {
    final success = await _authService.updateProfile(
      name: name,
      email: email,
    );

    if (success) {
      if (name != null) _userName = name;
      if (email != null) _userEmail = email;
      notifyListeners();
    }

    return success;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<bool> setProfileImage(Uint8List imageBytes) async {
    final base64Image = base64Encode(imageBytes);
    final success = await _authService.setProfileImage(base64Image);
    
    if (success) {
      _profileImage = imageBytes;
      notifyListeners();
    }

    return success;
  }

  Future<bool> removeProfileImage() async {
    final success = await _authService.removeProfileImage();
    
    if (success) {
      _profileImage = null;
      notifyListeners();
    }

    return success;
  }

  Future<bool> deleteAccount() async {
    final success = await _authService.deleteAccount();
    
    if (success) {
      _isAuthenticated = false;
      _userId = null;
      _userName = null;
      _userEmail = null;
      _profileImage = null;
      notifyListeners();
    }
    
    return success;
  }
} 