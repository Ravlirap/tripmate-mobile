import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/trip.dart';
import '../models/booking.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.100.156/be-tubes';

  static User? currentUser;

  // ---------- AUTH ----------
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final u = data['user'];
        currentUser = User(
          id: u['id'].toString(),
          name: u['name'],
          email: u['email'],
          password: '',
          role: u['role'],
        );
        return {'success': true, 'user': currentUser};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Login gagal'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Koneksi error: $e'};
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/register.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'name': name, 'email': email, 'password': password, 'role': role}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final u = data['user'];
        currentUser = User(
          id: u['id'].toString(),
          name: u['name'],
          email: u['email'],
          password: '',
          role: u['role'],
        );
        return {'success': true, 'user': currentUser};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Registrasi gagal'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Koneksi error: $e'};
    }
  }

  static void logout() {
    currentUser = null;
  }

  // ---------- LOGIN DENGAN GOOGLE (untuk sinkronisasi backend) ----------
  static Future<Map<String, dynamic>> loginWithGoogle(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login_google_fetch.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final u = data;
        currentUser = User(
          id: u['id'].toString(),
          name: u['name'],
          email: u['email'],
          password: '',
          role: u['role'],
        );
        return {'success': true, 'user': currentUser};
      } else {
        return {'success': false, 'error': data['error'] ?? 'User tidak ditemukan'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Koneksi error: $e'};
    }
  }

  // ---------- TRIP ----------
  static Future<List<Trip>> getAllTrips() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/trips.php'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => _tripFromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('getAllTrips error: $e');
      return [];
    }
  }

  static Future<List<Trip>> getTripsByOrganizer(String organizerId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/trips.php?organizer_id=$organizerId'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => _tripFromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('getTripsByOrganizer error: $e');
      return [];
    }
  }

  static Future<Trip?> getTripById(String id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/trips.php?id=$id'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return _tripFromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('getTripById error: $e');
      return null;
    }
  }

  static Future<bool> addTrip(Trip trip) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/trips.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'organizer_id': trip.organizerId,
              'title': trip.title,
              'destination': trip.destination,
              'date': trip.date,
              'quota': trip.quota,
              'price': trip.price,
              'description': trip.description,
              'image_url': trip.imageUrl,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      print('addTrip error: $e');
      return false;
    }
  }

  static Future<bool> updateTrip(Trip trip) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/trips.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id': trip.id,
              'title': trip.title,
              'destination': trip.destination,
              'date': trip.date,
              'quota': trip.quota,
              'price': trip.price,
              'description': trip.description,
              'image_url': trip.imageUrl,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      print('updateTrip error: $e');
      return false;
    }
  }

  static Future<bool> deleteTrip(String id) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/trips.php?id=$id'))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      print('deleteTrip error: $e');
      return false;
    }
  }

  // ---------- BOOKING ----------
  static Future<List<Booking>> getBookingsByUser(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/bookings.php?user_id=$userId'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => _bookingFromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('getBookingsByUser error: $e');
      return [];
    }
  }

  static Future<List<Booking>> getBookingsByOrganizer(String organizerId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/bookings.php?organizer_id=$organizerId'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => _bookingFromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('getBookingsByOrganizer error: $e');
      return [];
    }
  }

  static Future<bool> addBooking(Booking booking) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/bookings.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'trip_id': booking.tripId,
              'user_id': booking.userId,
              'participant_count': booking.participantCount,
              'notes': booking.notes,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      print('addBooking error: $e');
      return false;
    }
  }

  static Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/bookings.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id': bookingId,
              'status': status,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      print('updateBookingStatus error: $e');
      return false;
    }
  }

  // ---------- Helpers ----------
  static Trip _tripFromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'].toString(),
      organizerId: json['organizer_id'].toString(),
      title: json['title'],
      destination: json['destination'],
      date: json['date'],
      quota: json['quota'],
      price: json['price'],
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? 'https://picsum.photos/seed/default/400/200',
    );
  }

  static Booking _bookingFromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'].toString(),
      tripId: json['trip_id'].toString(),
      userId: json['user_id'].toString(),
      participantCount: json['participant_count'],
      notes: json['notes'] ?? '',
      status: json['status'],
      bookingDate: DateTime.parse(json['booking_date']),
    );
  }
}