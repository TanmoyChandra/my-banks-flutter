import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/crypto.dart';

class UiProvider extends ChangeNotifier {
  bool _hasCompletedOnboarding = false;
  String _userName = '';
  String? _userImage;
  bool _isDark = true;
  bool _isAppLockEnabled = false;

  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  String get userName => _userName;
  String? get userImage => _userImage;
  bool get isDark => _isDark;
  bool get isAppLockEnabled => _isAppLockEnabled;

  UiProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedData = prefs.getString('mybanks-ui');
    if (encryptedData != null) {
      try {
        final decryptedData = decryptLocal(encryptedData);
        final Map<String, dynamic> data = jsonDecode(decryptedData);
        if (data.containsKey('state')) {
          final state = data['state'];
          _hasCompletedOnboarding = state['hasCompletedOnboarding'] ?? false;
          _userName = state['userName'] ?? '';
          _userImage = state['userImage'];
          _isDark = state['isDark'] ?? true;
          _isAppLockEnabled = state['isAppLockEnabled'] ?? false;
          notifyListeners();
        }
      } catch (e) {
        // print("Failed to parse UI state");
      }
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final state = {
      'hasCompletedOnboarding': _hasCompletedOnboarding,
      'userName': _userName,
      'userImage': _userImage,
      'isDark': _isDark,
      'isAppLockEnabled': _isAppLockEnabled,
    };
    final dataString = jsonEncode({'state': state, 'version': 0});
    await prefs.setString('mybanks-ui', encryptLocal(dataString));
  }

  void completeOnboarding(String name) {
    _hasCompletedOnboarding = true;
    _userName = name;
    _saveToPrefs();
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name;
    _saveToPrefs();
    notifyListeners();
  }

  void setUserImage(String? uri) {
    _userImage = uri;
    _saveToPrefs();
    notifyListeners();
  }

  void toggleTheme() {
    _isDark = !_isDark;
    _saveToPrefs();
    notifyListeners();
  }

  void setAppLockEnabled(bool val) {
    _isAppLockEnabled = val;
    _saveToPrefs();
    notifyListeners();
  }
}
