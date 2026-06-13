import 'package:tubes_ppb_app/core/network/api_service.dart';
import 'package:tubes_ppb_app/data/models/trip_model.dart';
import 'package:tubes_ppb_app/models/booking_model.dart';

class TripService {
  final ApiService _apiService;

  TripService(this._apiService);

  /// Fetch public upcoming trips. Filterable by destination search query.
  Future<List<Trip>> getPublicTrips({String? destination}) async {
    final Map<String, dynamic> queryParams = {};
    if (destination != null && destination.isNotEmpty) {
      queryParams['destination'] = destination;
    }

    final response = await _apiService.get('/trips', queryParameters: queryParams);
    
    // Check if the response follows standard Laravel resource pagination where data is under 'data'
    final dynamic data = response.data;
    if (data is Map && data.containsKey('data')) {
      final list = data['data'] as List;
      return list.map((item) => Trip.fromJson(item)).toList();
    } else if (data is List) {
      return data.map((item) => Trip.fromJson(item)).toList();
    }
    return [];
  }

  /// Get details of a single public trip
  Future<Trip> getPublicTripDetail(String id) async {
    final response = await _apiService.get('/trips/$id');
    final data = response.data;
    if (data is Map && data.containsKey('trip')) {
      return Trip.fromJson(data['trip']);
    }
    return Trip.fromJson(data);
  }

  // ─── Agent Specific API Methods ─────────────────────────

  /// Fetch all trips created by the logged-in Travel Agent
  Future<List<Trip>> getAgentTrips() async {
    final response = await _apiService.get('/agent/trips');
    final dynamic data = response.data;
    if (data is Map && data.containsKey('data')) {
      final list = data['data'] as List;
      return list.map((item) => Trip.fromJson(item)).toList();
    } else if (data is List) {
      return data.map((item) => Trip.fromJson(item)).toList();
    }
    return [];
  }

  /// Create a new open trip
  Future<Trip> createTrip(Map<String, dynamic> tripData) async {
    final response = await _apiService.post('/agent/trips', data: tripData);
    final data = response.data;
    if (data is Map && data.containsKey('trip')) {
      return Trip.fromJson(data['trip']);
    }
    return Trip.fromJson(data);
  }

  /// Fetch details of an agent's own trip
  Future<Trip> getAgentTripDetail(String id) async {
    final response = await _apiService.get('/agent/trips/$id');
    final data = response.data;
    if (data is Map && data.containsKey('trip')) {
      return Trip.fromJson(data['trip']);
    }
    return Trip.fromJson(data);
  }

  /// Update an existing trip (Agent only)
  Future<Trip> updateTrip(String id, Map<String, dynamic> tripData) async {
    final response = await _apiService.put('/agent/trips/$id', data: tripData);
    final data = response.data;
    if (data is Map && data.containsKey('trip')) {
      return Trip.fromJson(data['trip']);
    }
    return Trip.fromJson(data);
  }

  /// Delete/cancel a trip (Agent only)
  Future<void> deleteTrip(String id) async {
    await _apiService.delete('/agent/trips/$id');
  }

  /// Fetch all traveler bookings/participants list for a specific trip (Agent only)
  Future<List<BookingModel>> getTripBookings(String id) async {
    final response = await _apiService.get('/agent/trips/$id/bookings');
    final dynamic data = response.data;
    if (data is Map && data.containsKey('data')) {
      final list = data['data'] as List;
      return list.map((item) => BookingModel.fromJson(item)).toList();
    } else if (data is List) {
      return data.map((item) => BookingModel.fromJson(item)).toList();
    }
    return [];
  }
}
