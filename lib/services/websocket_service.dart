import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/app_config.dart';
import '../models/websocket_messages.dart';

/// WebSocket service for real-time transcription communication
class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<WebSocketMessage>? _messageController;
  bool _isConnected = false;

  /// Connect to WebSocket endpoint
  Future<bool> connect() async {
    if (_isConnected && _channel != null) {
      return true;
    }

    try {
      final uri = Uri.parse(AppConfig.websocketUrl);
      print('Attempting WebSocket connection to: $uri');

      _channel = WebSocketChannel.connect(uri);
      _messageController = StreamController<WebSocketMessage>.broadcast();

      // Mark as connected immediately for sending messages
      // The WebSocket protocol will handle buffering until connection is established
      _isConnected = true;
      print('✓ WebSocket connection initiated');

      // Listen to incoming messages
      _channel!.stream.listen(
        (data) {
          try {
            final message = parseWebSocketMessage(data as String);
            _messageController?.add(message);
          } catch (e) {
            print('Error parsing WebSocket message: $e');
          }
        },
        onError: (error) {
          print('✗ WebSocket error: $error');
          print('  Connection details:');
          print('  - URL: ${AppConfig.websocketUrl}');
          print('  - Error type: ${error.runtimeType}');
          _isConnected = false;
          _messageController?.addError(error);
        },
        onDone: () {
          print('WebSocket connection closed');
          _isConnected = false;
        },
      );

      return true;
    } catch (e) {
      print('✗ Error connecting to WebSocket: $e');
      print('  URL attempted: ${AppConfig.websocketUrl}');
      _isConnected = false;
      return false;
    }
  }

  /// Send audio chunk message
  void sendAudioChunk(AudioChunkMessage message) {
    if (!_isConnected || _channel == null) {
      print('WebSocket not connected');
      return;
    }

    try {
      final json = jsonEncode(message.toJson());
      _channel!.sink.add(json);
    } catch (e) {
      print('Error sending audio chunk: $e');
    }
  }

  /// Send end session message
  void sendEndSession(EndSessionMessage message) {
    if (!_isConnected || _channel == null) {
      print('WebSocket not connected');
      return;
    }

    try {
      final json = jsonEncode(message.toJson());
      _channel!.sink.add(json);
    } catch (e) {
      print('Error sending end session: $e');
    }
  }

  /// Get stream of incoming messages
  Stream<WebSocketMessage>? getMessageStream() {
    return _messageController?.stream;
  }

  /// Check if connected
  bool get isConnected => _isConnected;

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }
    _isConnected = false;
    await _messageController?.close();
    _messageController = null;
  }
}

