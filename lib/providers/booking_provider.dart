import 'package:flutter/material.dart';
import 'package:tubes_ppb_app/core/services/booking_service.dart';
import 'package:tubes_ppb_app/models/booking_model.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService;

  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  BookingProvider(this._bookingService);

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Fetch all bookings for the authenticated traveler.
  Future<void> getBookings() async {
    _setLoading(true);
    _clearError();
    try {
      _bookings = await _bookingService.getBookings();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _bookings = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new booking for a trip.
  Future<bool> createBooking({
    required String tripId,
    required int ticketCount,
    required String contactName,
    required String contactPhone,
    required String contactEmail,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final newBooking = await _bookingService.createBooking(
        tripId: tripId,
        ticketCount: ticketCount,
        contactName: contactName,
        contactPhone: contactPhone,
        contactEmail: contactEmail,
        notes: notes,
      );
      _bookings.insert(0, newBooking);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Cancel an existing booking.
  Future<bool> cancelBooking(String bookingId, {String? reason}) async {
    _setLoading(true);
    _clearError();
    try {
      final updated = await _bookingService.cancelBooking(bookingId, reason: reason);
      final index = _bookings.indexWhere((b) => b.id == updated.id);
      if (index != -1) {
        _bookings[index] = updated;
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }
}
