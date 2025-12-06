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
  final String translationText;
  final ConnectionStatus connectionStatus;
  final String? errorMessage;

  const MeetingState({
    required this.sessionId,
    this.unstableTranscript = '',
    this.stableTranscript = '',
    this.translationText = '',
    this.connectionStatus = ConnectionStatus.idle,
    this.errorMessage,
  });

  MeetingState copyWith({
    String? sessionId,
    String? unstableTranscript,
    String? stableTranscript,
    String? translationText,
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
      translationText: translationText ?? this.translationText,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

