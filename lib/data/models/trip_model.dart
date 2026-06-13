import 'package:tubes_ppb_app/models/user_model.dart';

/// Data model representing an Open Trip package.
/// Mapped to match the Laravel API response structure while preserving
/// the getters expected by the pre-existing Flutter UI.
class Trip {
  final String id;
  final String title;
  final String destination;
  final String description;
  final List<dynamic>? itinerary;
  final DateTime departureDate;
  final DateTime returnDate;
  final int durationDays;
  final int maxQuota;
  final int remainingQuota;
  final double pricePerPerson;
  final String currency;
  final String? coverImageUrl;
  final List<dynamic>? galleryUrls;
  final String status;
  final String? meetingPoint;
  final double? lat;
  final double? lng;
  final UserModel? agent;
  final DateTime? createdAt;

  const Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.description,
    this.itinerary,
    required this.departureDate,
    required this.returnDate,
    required this.durationDays,
    required this.maxQuota,
    required this.remainingQuota,
    required this.pricePerPerson,
    required this.currency,
    this.coverImageUrl,
    this.galleryUrls,
    required this.status,
    this.meetingPoint,
    this.lat,
    this.lng,
    this.agent,
    this.createdAt,
  });

  /// Factory to construct Trip from API JSON map
  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      description: json['description'] as String? ?? '',
      itinerary: json['itinerary'] as List<dynamic>?,
      departureDate: json['departure_date'] != null
          ? DateTime.parse(json['departure_date'])
          : DateTime.now(),
      returnDate: json['return_date'] != null
          ? DateTime.parse(json['return_date'])
          : DateTime.now(),
      durationDays: json['duration_days'] as int? ?? 1,
      maxQuota: json['max_quota'] as int? ?? 0,
      remainingQuota: json['remaining_quota'] as int? ?? 0,
      pricePerPerson: double.tryParse(json['price_per_person']?.toString() ?? '0') ?? 0.0,
      currency: json['currency'] as String? ?? 'IDR',
      coverImageUrl: json['cover_image_url'] as String?,
      galleryUrls: json['gallery_urls'] as List<dynamic>?,
      status: json['status'] as String? ?? 'draft',
      meetingPoint: json['meeting_point'] as String?,
      lat: double.tryParse(json['lat']?.toString() ?? ''),
      lng: double.tryParse(json['lng']?.toString() ?? ''),
      agent: json['agent'] != null ? UserModel.fromJson(json['agent']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  /// Converts Trip to JSON map for post/put requests to Laravel
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'destination': destination,
      'description': description,
      'itinerary': itinerary,
      'departure_date': departureDate.toIso8601String().split('T')[0],
      'return_date': returnDate.toIso8601String().split('T')[0],
      'max_quota': maxQuota,
      'price_per_person': pricePerPerson,
      'currency': currency,
      'cover_image_url': coverImageUrl,
      'gallery_urls': galleryUrls,
      'status': status,
      'meeting_point': meetingPoint,
      'lat': lat,
      'lng': lng,
    };
  }

  // ─── Getters to Preserve Flutter UI Compatibility ─────────

  String get name => title;
  String get location => destination;
  double get price => pricePerPerson;
  DateTime get date => departureDate;

  String get imageUrl =>
      coverImageUrl ??
      'https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272?w=800&q=80';

  String get duration {
    final nights = durationDays - 1;
    if (nights <= 0) {
      return '$durationDays Hari';
    }
    return '$durationDays Hari $nights Malam';
  }

  double get rating => 4.8; // Fallback mock rating since DB does not track reviews
  int get maxParticipants => maxQuota;

  /// Dynamic category resolution based on keywords to match UI category chips
  String get category {
    final term = (title + ' ' + destination).toLowerCase();
    if (term.contains('bromo') ||
        term.contains('dieng') ||
        term.contains('gunung') ||
        term.contains('mendaki') ||
        term.contains('mountain') ||
        term.contains('sunrise') ||
        term.contains('kawah')) {
      return 'Gunung';
    }
    if (term.contains('pantai') || term.contains('beach') || term.contains('kelingking')) {
      return 'Pantai';
    }
    if (term.contains('sailing') ||
        term.contains('bajo') ||
        term.contains('diving') ||
        term.contains('island') ||
        term.contains('pulau') ||
        term.contains('nusa') ||
        term.contains('raja ampat') ||
        term.contains('phinisi') ||
        term.contains('komodo')) {
      return 'Pulau';
    }
    if (term.contains('heritage') ||
        term.contains('budaya') ||
        term.contains('toraja') ||
        term.contains('candi') ||
        term.contains('adat')) {
      return 'Budaya';
    }
    return 'Pulau'; // Default fallback category
  }
}
