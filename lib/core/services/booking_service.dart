import 'package:tubes_ppb_app/core/network/api_service.dart';
import 'package:tubes_ppb_app/models/booking_model.dart';

class BookingService {
  final ApiService _apiService;

  BookingService(this._apiService);

  /// Fetch the authenticated traveler's booking history
  Future<List<BookingModel>> getBookings() async {
    final response = await _apiService.get('/traveler/bookings');
    final dynamic data = response.data;
    if (data is Map && data.containsKey('data')) {
      final list = data['data'] as List;
      return list.map((item) => BookingModel.fromJson(item)).toList();
    } else if (data is List) {
      return data.map((item) => BookingModel.fromJson(item)).toList();
    }
    return [];
  }

  /// Create a new open trip booking
  Future<BookingModel> createBooking({
    required String tripId,
    required int ticketCount,
    required String contactName,
    required String contactPhone,
    required String contactEmail,
    String? notes,
  }) async {
    final response = await _apiService.post('/traveler/bookings', data: {
      'trip_id': tripId,
      'ticket_count': ticketCount,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'notes': notes,
    });
    
    final data = response.data;
    if (data is Map && data.containsKey('booking')) {
      return BookingModel.fromJson(data['booking']);
    }
    return BookingModel.fromJson(data);
  }

  /// Cancel an existing booking
  Future<BookingModel> cancelBooking(String bookingId, {String? reason}) async {
    final response = await _apiService.patch(
      '/traveler/bookings/$bookingId/cancel',
      data: {'cancellation_reason': reason},
    );
    final data = response.data;
    if (data is Map && data.containsKey('booking')) {
      return BookingModel.fromJson(data['booking']);
    }
    return BookingModel.fromJson(data);
  }
}
