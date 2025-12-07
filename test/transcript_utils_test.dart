import 'package:flutter_test/flutter_test.dart';
import 'package:meetlens/utils/transcript_utils.dart';

void main() {
  group('TranscriptUtils.splitIntoSegments', () {
    test('splits by newlines', () {
      final input = "Line 1\nLine 2\r\nLine 3";
      final result = TranscriptUtils.splitIntoSegments(input);
      expect(result, equals(['Line 1', 'Line 2', 'Line 3']));
    });

    test('splits by punctuation', () {
      final input = "Hello world. This is a test! Is it working?";
      final result = TranscriptUtils.splitIntoSegments(input);
      expect(result, equals(['Hello world.', 'This is a test!', 'Is it working?']));
    });

    test('soft wraps long lines', () {
      // 80 chars limit
      final longLine = "This is a very long line that should be split because it exceeds the eighty character limit significantly and we want to verify soft wrapping.";
      // Length is > 100. It should split. 
      final result = TranscriptUtils.splitIntoSegments(longLine);
      expect(result.length, greaterThan(1));
      expect(result.first.length, lessThanOrEqualTo(80));
    });

    test('handles mixed content', () {
      final input = "First sentence.\nSecond sentence is quite long but maybe not too long to split forcibly.";
      final result = TranscriptUtils.splitIntoSegments(input);
      expect(result, contains('First sentence.'));
    });

    test('handles empty input', () {
      expect(TranscriptUtils.splitIntoSegments(''), isEmpty);
    });
  });
}
