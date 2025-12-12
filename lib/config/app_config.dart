/// Application configuration for backend URLs
class AppConfig {
  // Backend WebSocket URL for transcription
  static const String websocketUrl = 'wss://meetlens-backend-5ptfw.ondigitalocean.app/ws/transcribe';

  // Backend HTTP URL for summary endpoint
  static const String httpBaseUrl = 'https://meetlens-backend-5ptfw.ondigitalocean.app';
  
  // Summary endpoint path
  static const String summaryEndpoint = '/summary';
  
  // Full summary URL
  static String get summaryUrl => '$httpBaseUrl$summaryEndpoint';
  
  // Source language (for MVP: English)
  static const String sourceLanguage = 'en';
  
  // Target language (for MVP: Turkish)
  static const String targetLanguage = 'tr';
}

