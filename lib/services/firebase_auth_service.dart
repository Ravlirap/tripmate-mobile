import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';
import '../models/user.dart' as app_models;

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // FIXED: google_sign_in v6 menggunakan constructor biasa, bukan .instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  User? get currentFirebaseUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ---------- INISIALISASI ----------
  // FIXED: v6 tidak perlu .initialize() atau .attemptLightweightAuthentication()
  Future<void> init() async {
    // Tidak ada yang perlu diinisialisasi untuk google_sign_in v6
  }

  // ---------- LOGIN DENGAN EMAIL/PASSWORD (Firebase) ----------
  // FIXED: method ini sebelumnya tidak ada, sekarang ditambahkan
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Tidak perlu throw — ini opsional, gagal pun tidak masalah
      print('Firebase email sign-in error: ${e.message}');
      return null;
    }
  }

  // ---------- REGISTER DENGAN EMAIL/PASSWORD (Firebase) ----------
  // FIXED: method ini sebelumnya tidak ada, sekarang ditambahkan
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Tidak perlu throw — ini opsional, gagal pun tidak masalah
      print('Firebase email register error: ${e.message}');
      return null;
    }
  }

  // ---------- LOGIN DENGAN GOOGLE ----------
  Future<app_models.User?> signInWithGoogle() async {
    try {
      // FIXED: v6 menggunakan .signIn() bukan .authenticate()
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User membatalkan login
        return null;
      }

      // Dapatkan auth credentials dari Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        throw Exception('ID Token tidak ditemukan');
      }

      // Login ke Firebase dengan credential
      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: googleAuth.accessToken,
      );
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Gagal login ke Firebase');
      }

      // FIXED: gunakan email dari googleUser, bukan variabel 'email' yang tidak terdefinisi
      final String userEmail = googleUser.email;

      // Kirim ID Token ke backend PHP untuk sinkronisasi
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/login_google.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'id_token': idToken},
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['status'] == 'success') {
        if (responseData['user'] != null) {
          final u = responseData['user'];
          ApiService.currentUser = app_models.User(
            id: u['id'].toString(),
            name: u['name'],
            email: u['email'],
            password: '',
            role: u['role'] ?? 'traveler',
          );
          return ApiService.currentUser;
        } else {
          // Fallback: fetch user dari database berdasarkan email
          final result = await ApiService.loginWithGoogle(userEmail);
          if (result['success'] == true) {
            return result['user'];
          } else {
            throw Exception('Gagal sinkronisasi dengan backend');
          }
        }
      } else {
        throw Exception(responseData['message'] ?? 'Gagal autentikasi backend');
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  // ---------- LOGOUT ----------
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    ApiService.logout();
  }
}
