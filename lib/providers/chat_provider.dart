import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:tubes_ppb_app/models/chat_message_model.dart';

class ChatProvider extends ChangeNotifier {
  WebSocketChannel? _channel;
  final List<ChatMessageModel> _messages = [];
  bool _isConnected = false;
  String? _errorMessage;

  List<ChatMessageModel> get messages => _messages;
  bool get isConnected => _isConnected;
  String? get errorMessage => _errorMessage;

  /// Connect to the WebSocket server for a specific trip chat room.
  void connect({
    required String tripId,
    required String userId,
    required String userName,
    String? userAvatar,
    String wsUrl = 'ws://10.0.2.2:3000',
  }) {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('$wsUrl?trip_id=$tripId&user_id=$userId&user_name=$userName'),
      );

      _isConnected = true;
      _errorMessage = null;
      notifyListeners();

      _channel!.stream.listen(
        (data) {
          try {
            final json = jsonDecode(data);
            final msg = ChatMessageModel.fromJson(json);
            _messages.add(msg);
            notifyListeners();
          } catch (e) {
            debugPrint('WebSocket parse error: $e');
          }
        },
        onError: (error) {
          _isConnected = false;
          _errorMessage = 'Koneksi chat terputus.';
          notifyListeners();
        },
        onDone: () {
          _isConnected = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _isConnected = false;
      _errorMessage = 'Gagal terhubung ke server chat.';
      notifyListeners();
    }
  }

  /// Send a message through the WebSocket.
  void sendMessage({
    required String tripId,
    required String senderId,
    required String senderName,
    String? senderAvatar,
    required String message,
  }) {
    if (_channel == null || !_isConnected) return;

    final msg = ChatMessageModel(
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      message: message,
      tripId: tripId,
      timestamp: DateTime.now(),
    );

    _channel!.sink.add(jsonEncode(msg.toJson()));
  }

  /// Disconnect from the WebSocket.
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _messages.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
