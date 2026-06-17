import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';
import '../services/firebase_auth_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ---------- INISIALISASI ----------
  Future<void> init() async {
    _setLoading(true);
    await _authService.init();
    final firebaseUser = _authService.currentFirebaseUser;
    if (firebaseUser != null && _currentUser == null) {
      final email = firebaseUser.email ?? '';
      if (email.isNotEmpty) {
        final result = await ApiService.loginWithGoogle(email);
        if (result['success'] == true) {
          _currentUser = result['user'];
        }
      }
    }
    _setLoading(false);
  }

  // ---------- LOGIN EMAIL/PASSWORD ----------
  Future<bool> loginWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      final result = await ApiService.login(email, password);
      if (result['success'] == true) {
        _currentUser = result['user'];
        // Sinkronkan dengan Firebase (opsional)
        try {
          await _authService.signInWithEmail(email, password);
        } catch (_) {}
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['error'] ?? 'Login gagal';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ---------- REGISTER EMAIL/PASSWORD ----------
  Future<bool> registerWithEmail(String name, String email, String password, String role) async {
    _setLoading(true);
    _clearError();
    try {
      final result = await ApiService.register(name, email, password, role);
      if (result['success'] == true) {
        _currentUser = result['user'];
        // Sinkronkan dengan Firebase (opsional)
        try {
          await _authService.registerWithEmail(email, password);
        } catch (_) {}
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['error'] ?? 'Registrasi gagal';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ---------- LOGIN DENGAN GOOGLE (Firebase) ----------
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Google Login gagal: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ---------- LOGOUT ----------
  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    _clearError();
    notifyListeners();
  }

  // ---------- HELPERS ----------
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}