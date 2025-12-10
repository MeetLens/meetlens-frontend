import 'dart:convert';

/// Base class for WebSocket messages
abstract class WebSocketMessage {
  final String type;
  final String sessionId;

  WebSocketMessage({
    required this.type,
    required this.sessionId,
  });

  Map<String, dynamic> toJson();
}

/// Client → Server: Audio chunk message
class AudioChunkMessage extends WebSocketMessage {
  final int chunkId;
  final String audioFormat;
  final String data; // Base64 encoded audio

  AudioChunkMessage({
    required super.sessionId,
    required this.chunkId,
    this.audioFormat = 'pcm_s16le_16k_mono',
    required this.data,
  }) : super(type: 'audio_chunk');

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'session_id': sessionId,
      'chunk_id': chunkId,
      'audio_format': audioFormat,
      'data': data,
    };
  }
}

/// Client → Server: End session message
class EndSessionMessage extends WebSocketMessage {
  EndSessionMessage({required super.sessionId}) : super(type: 'end_session');

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'session_id': sessionId,
    };
  }
}

/// Server → Client: Transcript partial message
class TranscriptPartialMessage extends WebSocketMessage {
  final int chunkId;
  final String text;

  TranscriptPartialMessage({
    required super.sessionId,
    required this.chunkId,
    required this.text,
  }) : super(type: 'transcript_partial');

  factory TranscriptPartialMessage.fromJson(Map<String, dynamic> json) {
    return TranscriptPartialMessage(
      sessionId: json['session_id'] as String,
      chunkId: json['chunk_id'] as int,
      text: json['text'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'session_id': sessionId,
      'chunk_id': chunkId,
      'text': text,
    };
  }
}

/// Server → Client: Transcript stable message
class TranscriptStableMessage extends WebSocketMessage {
  final String text;

  TranscriptStableMessage({
    required super.sessionId,
    required this.text,
  }) : super(type: 'transcript_stable');

  factory TranscriptStableMessage.fromJson(Map<String, dynamic> json) {
    return TranscriptStableMessage(
      sessionId: json['session_id'] as String,
      text: json['text'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'session_id': sessionId,
      'text': text,
    };
  }
}

/// Server → Client: Translation partial message
class TranslationPartialMessage extends WebSocketMessage {
  final int chunkId;
  final String text;

  TranslationPartialMessage({
    required super.sessionId,
    required this.chunkId,
    required this.text,
  }) : super(type: 'translation_partial');

  factory TranslationPartialMessage.fromJson(Map<String, dynamic> json) {
    return TranslationPartialMessage(
      sessionId: json['session_id'] as String,
      chunkId: json['chunk_id'] as int,
      text: json['text'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'session_id': sessionId,
      'chunk_id': chunkId,
      'text': text,
    };
  }
}

/// Server → Client: Translation stable message
class TranslationStableMessage extends WebSocketMessage {
  final String text;

  TranslationStableMessage({
    required super.sessionId,
    required this.text,
  }) : super(type: 'translation_stable');

  factory TranslationStableMessage.fromJson(Map<String, dynamic> json) {
    return TranslationStableMessage(
      sessionId: json['session_id'] as String,
      text: json['text'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'session_id': sessionId,
      'text': text,
    };
  }
}

/// Server → Client: Error message
class ErrorMessage extends WebSocketMessage {
  final String message;
  final String? code;

  ErrorMessage({
    required super.sessionId,
    required this.message,
    this.code,
  }) : super(type: 'error');

  factory ErrorMessage.fromJson(Map<String, dynamic> json) {
    return ErrorMessage(
      sessionId: json['session_id'] as String,
      message: json['message'] as String,
      code: json['code'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'session_id': sessionId,
      'message': message,
      if (code != null) 'code': code,
    };
  }
}

/// Parse incoming WebSocket message from JSON
WebSocketMessage parseWebSocketMessage(String jsonString) {
  final json = jsonDecode(jsonString) as Map<String, dynamic>;
  final type = json['type'] as String;

  switch (type) {
    case 'transcript_partial':
      return TranscriptPartialMessage.fromJson(json);
    case 'transcript_stable':
      return TranscriptStableMessage.fromJson(json);
    case 'translation_partial':
      return TranslationPartialMessage.fromJson(json);
    case 'translation_stable':
      return TranslationStableMessage.fromJson(json);
    case 'translation':
      // Legacy fallback to treat old translation messages as stable
      return TranslationStableMessage.fromJson(json);
    case 'error':
      return ErrorMessage.fromJson(json);
    default:
      throw FormatException('Unknown message type: $type');
  }
}

