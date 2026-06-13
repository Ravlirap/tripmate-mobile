import 'package:tubes_ppb_app/data/models/trip_model.dart';
import 'package:tubes_ppb_app/models/user_model.dart';

/// Model representing a Booking transaction made by a Traveler.
class BookingModel {
  final int id;
  final int tripId;
  final int travelerId;
  final int ticketCount;
  final double pricePerPerson;
  final double totalPrice;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final String? notes;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final Trip? trip;
  final UserModel? traveler;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookingModel({
    required this.id,
    required this.tripId,
    required this.travelerId,
    required this.ticketCount,
    required this.pricePerPerson,
    required this.totalPrice,
    required this.status,
    required this.contactName,
    required this.contactPhone,
    required this.contactEmail,
    this.notes,
    this.cancellationReason,
    this.cancelledAt,
    this.trip,
    this.traveler,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as int,
      tripId: json['trip_id'] as int,
      travelerId: json['traveler_id'] as int,
      ticketCount: json['ticket_count'] as int? ?? 1,
      pricePerPerson: double.tryParse(json['price_per_person']?.toString() ?? '0') ?? 0.0,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      contactName: json['contact_name'] as String? ?? '',
      contactPhone: json['contact_phone'] as String? ?? '',
      contactEmail: json['contact_email'] as String? ?? '',
      notes: json['notes'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      cancelledAt: json['cancelled_at'] != null ? DateTime.parse(json['cancelled_at']) : null,
      trip: json['trip'] != null ? Trip.fromJson(json['trip']) : null,
      traveler: json['traveler'] != null ? UserModel.fromJson(json['traveler']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'traveler_id': travelerId,
      'ticket_count': ticketCount,
      'price_per_person': pricePerPerson,
      'total_price': totalPrice,
      'status': status,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'notes': notes,
      'cancellation_reason': cancellationReason,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Helper getters
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
}
