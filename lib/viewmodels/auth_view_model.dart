import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todotask/services/auth_service.dart';

class AuthViewModel with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  AuthViewModel() {
    _checkCurrentUser();
  }

  // Check if user is logged in and update state
  Future<void> _checkCurrentUser() async {
    _user = _authService.getCurrentUser();
    notifyListeners();
  }

  // Register method
  Future<bool> register(String email, String password) async {
    _setLoading(true);
    User? user =
        await _authService.registerWithEmailAndPassword(email, password);
    _setLoading(false);

    if (user != null) {
      _user = user;
      _errorMessage = null;
      notifyListeners();
      return true; // Registration successful
    } else {
      _errorMessage = "Registration failed";
      notifyListeners();
      return false; // Registration failed
    }
  }

  // Login method
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    User? user = await _authService.signInWithEmailAndPassword(email, password);
    _setLoading(false);

    if (user != null) {
      _user = user;
      _errorMessage = null;
      notifyListeners();
      return true; // Login successful
    } else {
      _errorMessage = "Login failed";
      notifyListeners();
      return false; // Login failed
    }
  }

  // Sign out
  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  // Helper to set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }
}
