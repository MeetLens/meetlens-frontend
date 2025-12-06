import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/summary_response.dart';

/// Service for calling the summary API endpoint
class SummaryService {
  /// Generate summary from full transcript
  Future<SummaryResponse> generateSummary({
    required String sessionId,
    required String fullTranscript,
    String? language,
  }) async {
    final uri = Uri.parse(AppConfig.summaryUrl);
    
    final body = jsonEncode({
      'session_id': sessionId,
      'full_transcript': fullTranscript,
      if (language != null) 'language': language,
    });

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return SummaryResponse.fromJson(json);
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw SummaryException(
          'Bad Request: ${error['detail'] ?? 'Invalid request'}',
        );
      } else {
        throw SummaryException(
          'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is SummaryException) {
        rethrow;
      }
      throw SummaryException('Network error: $e');
    }
  }
}

/// Exception thrown by SummaryService
class SummaryException implements Exception {
  final String message;
  SummaryException(this.message);

  @override
  String toString() => message;
}

