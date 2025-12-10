/// Connection status for meeting state machine
enum ConnectionStatus {
  idle,
  connecting,
  listening,
  summarizing,
  done,
}

/// Meeting state model containing all transcript and translation data
class MeetingState {
  final String sessionId;
  final String unstableTranscript;
  final String stableTranscript;
  final String stableTranslation;
  final String partialTranslation;
  final ConnectionStatus connectionStatus;
  final String? errorMessage;

  const MeetingState({
    required this.sessionId,
    this.unstableTranscript = '',
    this.stableTranscript = '',
    this.stableTranslation = '',
    this.partialTranslation = '',
    this.connectionStatus = ConnectionStatus.idle,
    this.errorMessage,
  });

  MeetingState copyWith({
    String? sessionId,
    String? unstableTranscript,
    String? stableTranscript,
    String? stableTranslation,
    String? partialTranslation,
    ConnectionStatus? connectionStatus,
    String? errorMessage,
    bool clearUnstableTranscript = false,
    bool clearError = false,
  }) {
    return MeetingState(
      sessionId: sessionId ?? this.sessionId,
      unstableTranscript: clearUnstableTranscript
          ? ''
          : (unstableTranscript ?? this.unstableTranscript),
      stableTranscript: stableTranscript ?? this.stableTranscript,
      stableTranslation: stableTranslation ?? this.stableTranslation,
      partialTranslation: partialTranslation ?? this.partialTranslation,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

