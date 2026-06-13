/// Model representing a Chat Message sent over the WebSocket.
class ChatMessageModel {
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String message;
  final String tripId;
  final DateTime timestamp;

  ChatMessageModel({
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.message,
    required this.tripId,
    required this.timestamp,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      senderId: json['sender_id']?.toString() ?? '',
      senderName: json['sender_name'] as String? ?? 'Traveler',
      senderAvatar: json['sender_avatar'] as String?,
      message: json['message'] as String? ?? '',
      tripId: json['trip_id']?.toString() ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'message': message,
      'trip_id': tripId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
