import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/meeting_state.dart';
import '../models/websocket_messages.dart';
import '../services/audio_service.dart';
import '../services/websocket_service.dart';
import '../services/summary_service.dart';

/// Provider for AudioService
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

/// Provider for WebSocketService
final websocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(() {
    service.disconnect();
  });
  return service;
});

/// Provider for SummaryService
final summaryServiceProvider = Provider<SummaryService>((ref) {
  return SummaryService();
});

/// StateNotifier for managing meeting state
class MeetingNotifier extends StateNotifier<MeetingState> {
  final AudioService _audioService;
  final WebSocketService _websocketService;
  StreamSubscription<Uint8List>? _audioSubscription;
  StreamSubscription<WebSocketMessage>? _messageSubscription;
  int _chunkId = 0;
  final _uuid = const Uuid();

  MeetingNotifier(
    this._audioService,
    this._websocketService,
  ) : super(const MeetingState(sessionId: ''));

  /// Start a new meeting
  Future<bool> startMeeting() async {
    try {
      // Generate session ID
      final sessionId = _uuid.v4();
      state = state.copyWith(
        sessionId: sessionId,
        connectionStatus: ConnectionStatus.connecting,
      );

      // Connect WebSocket
      final connected = await _websocketService.connect();
      if (!connected) {
        state = state.copyWith(
          connectionStatus: ConnectionStatus.idle,
          errorMessage: 'Failed to connect to server',
        );
        return false;
      }

      // Start audio recording
      final recordingStarted = await _audioService.startRecording();
      if (!recordingStarted) {
        await _websocketService.disconnect();
        state = state.copyWith(
          connectionStatus: ConnectionStatus.idle,
          errorMessage: 'Microphone permission denied',
        );
        return false;
      }

      // Set up audio chunk stream
      _chunkId = 0;
      _audioSubscription = _audioService.getAudioChunkStream()?.listen(
        (audioBytes) {
          _chunkId++;
          final base64Audio = base64Encode(audioBytes);
          final message = AudioChunkMessage(
            sessionId: sessionId,
            chunkId: _chunkId,
            data: base64Audio,
          );
          _websocketService.sendAudioChunk(message);
        },
        onError: (error) {
          print('Audio stream error: $error');
        },
      );

      // Set up WebSocket message stream
      _messageSubscription = _websocketService.getMessageStream()?.listen(
        (message) {
          _handleWebSocketMessage(message);
        },
        onError: (error) {
          state = state.copyWith(
            errorMessage: 'WebSocket error: $error',
          );
        },
      );

      state = state.copyWith(
        connectionStatus: ConnectionStatus.listening,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        connectionStatus: ConnectionStatus.idle,
        errorMessage: 'Error starting meeting: $e',
      );
      return false;
    }
  }

  /// Handle incoming WebSocket messages
  void _handleWebSocketMessage(WebSocketMessage message) {
    if (message is TranscriptPartialMessage) {
      state = state.copyWith(
        unstableTranscript: message.text,
      );
    } else if (message is TranscriptStableMessage) {
      state = state.copyWith(
        stableTranscript: state.stableTranscript + message.text,
        unstableTranscript: '', // Clear unstable when stable arrives
      );
    } else if (message is TranslationMessage) {
      state = state.copyWith(
        translationText: state.translationText + message.text + ' ',
      );
    } else if (message is ErrorMessage) {
      state = state.copyWith(
        errorMessage: message.message,
      );
    }
  }

  /// End the current meeting
  Future<void> endMeeting() async {
    if (state.connectionStatus != ConnectionStatus.listening) {
      return;
    }

    state = state.copyWith(
      connectionStatus: ConnectionStatus.summarizing,
    );

    // Stop audio recording
    await _audioService.stopRecording();
    _audioSubscription?.cancel();
    _audioSubscription = null;

    // Send end session message
    final endMessage = EndSessionMessage(sessionId: state.sessionId);
    _websocketService.sendEndSession(endMessage);

    // Disconnect WebSocket
    _messageSubscription?.cancel();
    _messageSubscription = null;
    await _websocketService.disconnect();

    // Generate summary
    // Note: Summary is generated in SummaryScreen to avoid blocking UI
    // The summary screen will call the API directly
    state = state.copyWith(
      connectionStatus: ConnectionStatus.done,
    );
  }

  /// Reset meeting state
  void reset() {
    _audioSubscription?.cancel();
    _messageSubscription?.cancel();
    state = const MeetingState(sessionId: '');
    _chunkId = 0;
  }
}

/// Provider for MeetingNotifier
final meetingProvider =
    StateNotifierProvider<MeetingNotifier, MeetingState>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  final websocketService = ref.watch(websocketServiceProvider);
  return MeetingNotifier(audioService, websocketService);
});

