import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userPasswordKey = 'user_password'; // For demo purposes only
  static const String _profileImageKey = 'profile_image';
  
  final SharedPreferences _prefs;
  
  AuthService(this._prefs);
  
  Future<bool> isAuthenticated() async {
    return _prefs.containsKey(_userIdKey);
  }
  
  Future<String?> getUserId() async {
    return _prefs.getString(_userIdKey);
  }
  
  Future<String?> getUserName() async {
    return _prefs.getString(_userNameKey);
  }
  
  Future<String?> getUserEmail() async {
    return _prefs.getString(_userEmailKey);
  }

  Future<String?> getProfileImage() async {
    return _prefs.getString(_profileImageKey);
  }
  
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // In a real app, you would validate the credentials with a backend service
      // For now, we'll just store the user data locally
      final userId = const Uuid().v4();
      
      await _prefs.setString(_userIdKey, userId);
      await _prefs.setString(_userNameKey, name);
      await _prefs.setString(_userEmailKey, email);
      await _prefs.setString(_userPasswordKey, password); // Not secure, for demo only
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      // In a real app, you would validate the credentials with a backend service
      // For now, we'll just check if the email exists
      final storedEmail = _prefs.getString(_userEmailKey);
      final storedPassword = _prefs.getString(_userPasswordKey);
      
      if (storedEmail == email && storedPassword == password) {
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> logout() async {
    // In a real app, you might want to keep the user data but just log them out
    // For demo purposes, we'll remove everything
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userNameKey);
    await _prefs.remove(_userEmailKey);
    // Don't remove the password or profile image when logging out
    // as we want to keep the account data
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
  }) async {
    try {
      if (name != null) {
        await _prefs.setString(_userNameKey, name);
      }
      
      if (email != null) {
        await _prefs.setString(_userEmailKey, email);
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final storedPassword = _prefs.getString(_userPasswordKey);
      
      if (storedPassword == currentPassword) {
        await _prefs.setString(_userPasswordKey, newPassword);
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setProfileImage(String base64Image) async {
    try {
      await _prefs.setString(_profileImageKey, base64Image);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeProfileImage() async {
    try {
      await _prefs.remove(_profileImageKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    try {
      // Remove all user data from SharedPreferences
      await _prefs.remove(_userIdKey);
      await _prefs.remove(_userNameKey);
      await _prefs.remove(_userEmailKey);
      await _prefs.remove(_userPasswordKey);
      await _prefs.remove(_profileImageKey);
      
      // In a real app, you would also make an API call to delete the account on the server
      
      return true;
    } catch (e) {
      return false;
    }
  }
} 