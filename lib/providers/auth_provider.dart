import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tubes_ppb_app/core/services/auth_service.dart';
import 'package:tubes_ppb_app/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this.authService) {
    checkAuthStatus();
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
  }

  void setUser(UserModel? user) {
    _user = user;
    notifyListeners();
  }

  /// Check token persistence and load profile from local secure storage
  Future<void> checkAuthStatus() async {
    setLoading(true);
    clearError();
    try {
      final token = await secureStorage.read(key: 'sanctum_token');
      if (token != null) {
        _user = await authService.getProfile();
      } else {
        _user = null;
      }
    } catch (e) {
      await secureStorage.delete(key: 'sanctum_token');
      _user = null;
    } finally {
      setLoading(false);
    }
  }

  /// Trigger Google Sign-In, exchange for Firebase credentials, and sync with Laravel backend.
  Future<bool> loginWithGoogle({required String selectedRole}) async {
    setLoading(true);
    clearError();
    try {
      // 1. Google OAuth Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _errorMessage = 'Login dibatalkan oleh pengguna.';
        setLoading(false);
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 2. Authenticate with Firebase using Google credentials
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Gagal mendapatkan informasi pengguna dari Firebase.');
      }

      // 3. Sync with Laravel Sanctum API
      final syncResult = await authService.firebaseSync(
        firebaseUid: firebaseUser.uid,
        name: firebaseUser.displayName ?? googleUser.displayName ?? 'Traveler',
        email: firebaseUser.email ?? googleUser.email,
        avatarUrl: firebaseUser.photoURL ?? googleUser.photoUrl,
        phone: firebaseUser.phoneNumber,
        role: selectedRole,
      );

      _user = syncResult['user'] as UserModel;
      final token = syncResult['token'] as String;

      // 4. Save the Sanctum token securely
      await secureStorage.write(key: 'sanctum_token', value: token);
      
      setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      setLoading(false);
      return false;
    }
  }

  /// Refresh user profile details from the backend
  Future<void> refreshProfile() async {
    if (!isAuthenticated) return;
    try {
      _user = await authService.getProfile();
      notifyListeners();
    } catch (e) {
      if (e.toString().contains('401')) {
        await logout();
      }
    }
  }

  /// Revoke token on Laravel, sign out from Firebase, and clear secure storage.
  Future<void> logout() async {
    setLoading(true);
    try {
      await authService.logout();
    } catch (_) {
      // Ignore network errors on logout
    } finally {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      await secureStorage.delete(key: 'sanctum_token');
      _user = null;
      setLoading(false);
    }
  }
}
