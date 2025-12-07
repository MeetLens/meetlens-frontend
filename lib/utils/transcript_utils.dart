import 'package:flutter/material.dart';

class TranscriptUtils {
  /// Helper to split long text into smaller segments for "Lyrics" feel.
  static List<String> splitIntoSegments(String text) {
    if (text.isEmpty) return [];
    
    // Improved splitting:
    // 1. Split by newlines first.
    // 2. Split by strong punctuation (.!?) that is followed by space.
    // 3. If a segment is still too long (> 80 chars), force split at nearest space.
    
    final segments = <String>[];
    
    // First, normalize newlines
    final normalized = text.replaceAll('\r\n', '\n');
    final rawLines = normalized.split('\n');

    for (var line in rawLines) {
      if (line.trim().isEmpty) continue;
      
      // Split by sentence enders
      final sentenceSplit = line.split(RegExp(r'(?<=[.!?])\s+'));
      
      for (var sentence in sentenceSplit) {
        if (sentence.trim().isEmpty) continue;
        
        // Check length
        if (sentence.length > 80) { // arbitrary "lyrics line" max length
          // Attempt simple soft-wrap split at space
          var current = sentence.trim();
          while (current.length > 80) {
             int splitIndex = current.lastIndexOf(' ', 80);
             if (splitIndex == -1) splitIndex = 80; // force split if no space
             
             if (splitIndex < current.length) {
               segments.add(current.substring(0, splitIndex).trim());
               current = current.substring(splitIndex).trim();
             } else {
               break;
             }
          }
          if (current.isNotEmpty) segments.add(current);
        } else {
          segments.add(sentence.trim());
        }
      }
    }
    
    return segments;
  }
}
