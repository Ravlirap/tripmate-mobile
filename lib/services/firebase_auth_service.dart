import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';
import '../models/user.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? get currentFirebaseUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Inisialisasi GoogleSignIn
  Future<void> init() async {
    await _googleSignIn.initialize();
    await _googleSignIn.attemptLightweightAuthentication();
  }

  // ---------- LOGIN DENGAN GOOGLE ----------
  Future<User?> signInWithGoogle() async {
    try {
      // 1. Authenticate dengan Google (API v7 menggunakan .authenticate())
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) {
        // User membatalkan login
        return null;
      }

      // 2. Dapatkan ID Token
      final String? idToken = await googleUser.authentication.then(
        (auth) => auth.idToken,
      );
      if (idToken == null) {
        throw Exception('ID Token tidak ditemukan');
      }

      // 3. Login ke Firebase dengan credential
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Gagal login ke Firebase');
      }

      // 4. Kirim ID Token ke backend PHP untuk sinkronisasi
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/login_google.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'id_token': idToken},
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['status'] == 'success') {
        if (responseData['user'] != null) {
          final u = responseData['user'];
          ApiService.currentUser = User(
            id: u['id'].toString(),
            name: u['name'],
            email: u['email'],
            password: '',
            role: u['role'] ?? 'traveler',
          );
          return ApiService.currentUser;
        } else {
          // Jika response tidak mengirim user, ambil dari database
          final result = await ApiService.loginWithGoogle(email);
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