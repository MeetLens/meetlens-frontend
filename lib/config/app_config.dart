/// Application configuration for backend URLs
class AppConfig {
  // Backend WebSocket URL for transcription
  static const String websocketUrl = 'ws://127.0.0.1:8000/ws/transcribe';
  
  // Backend HTTP URL for summary endpoint
  static const String httpBaseUrl = 'http://127.0.0.1:8000';
  
  // Summary endpoint path
  static const String summaryEndpoint = '/summary';
  
  // Full summary URL
  static String get summaryUrl => '$httpBaseUrl$summaryEndpoint';
  
  // Source language (for MVP: English)
  static const String sourceLanguage = 'en';
  
  // Target language (for MVP: Turkish)
  static const String targetLanguage = 'tr';
}

