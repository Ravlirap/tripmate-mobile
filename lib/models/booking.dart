class Booking {
  final String id;
  final String tripId;
  final String userId;
  final int participantCount;
  final String notes;
  final String status; // 'pending', 'confirmed', 'cancelled'
  final DateTime bookingDate;

  Booking({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.participantCount,
    required this.notes,
    required this.status,
    required this.bookingDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'userId': userId,
      'participantCount': participantCount,
      'notes': notes,
      'status': status,
      'bookingDate': bookingDate.toIso8601String(),
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      tripId: map['tripId'],
      userId: map['userId'],
      participantCount: map['participantCount'],
      notes: map['notes'],
      status: map['status'],
      bookingDate: DateTime.parse(map['bookingDate']),
    );
  }
}
