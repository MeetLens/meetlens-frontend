import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for capturing audio from microphone and chunking it
/// Service for capturing audio from microphone and chunking it
class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  StreamController<Uint8List>? _audioStreamController;
  StreamSubscription<Uint8List>? _recordSubscription;
  bool _isRecording = false;
  
  // Buffering
  final List<int> _audioBuffer = [];
  // 16kHz * 1 channel * 2 bytes/sample * 1 second = 32000 bytes
  // Reduced from 2 seconds to 1 second for better real-time responsiveness
  static const int _chunkSize = 16000 * 2 * 1; 

  /// Check and request microphone permission (handles permanent denials).
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied || status.isRestricted) {
      // iOS will not re-prompt once denied; guide to Settings.
      await openAppSettings();
    }
    return false;
  }

  /// Check if microphone permission is granted
  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Start recording audio in 16kHz mono PCM format
  Future<bool> startRecording() async {
    if (_isRecording) {
      return true;
    }

    if (!await hasPermission()) {
      final granted = await requestPermission();
      if (!granted) {
        return false;
      }
    }

    try {
      _audioStreamController = StreamController<Uint8List>();
      _audioBuffer.clear();

      // Start stream
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );

      _isRecording = true;

      _recordSubscription = stream.listen((data) {
        _handleAudioData(data);
      }, onError: (e) {
        print('Error in audio stream: $e');
      });

      return true;
    } catch (e) {
      print('Error starting recording: $e');
      return false;
    }
  }

  /// Handle incoming raw audio data
  void _handleAudioData(Uint8List data) {
    if (!_isRecording) return;
    
    _audioBuffer.addAll(data);
    
    // Check if buffer exceeds chunk size
    if (_audioBuffer.length >= _chunkSize) {
      // Emit chunk
      final chunk = Uint8List.fromList(_audioBuffer);
      _audioStreamController?.add(chunk);
      _audioBuffer.clear();
    }
  }

  /// Stop recording
  Future<void> stopRecording() async {
    if (!_isRecording) {
      return;
    }

    _isRecording = false;
    
    // Stop subscription
    await _recordSubscription?.cancel();
    _recordSubscription = null;

    try {
      await _recorder.stop();
    } catch (e) {
      print('Error stopping recording: $e');
    }
    
    // Flush remaining buffer if needed
    if (_audioBuffer.isNotEmpty) {
       final chunk = Uint8List.fromList(_audioBuffer);
       _audioStreamController?.add(chunk);
       _audioBuffer.clear();
    }

    await _audioStreamController?.close();
    _audioStreamController = null;
  }

  /// Get stream of audio chunks
  Stream<Uint8List>? getAudioChunkStream() {
    return _audioStreamController?.stream;
  }

  /// Dispose resources
  Future<void> dispose() async {
    await stopRecording();
    await _recorder.dispose();
  }
}

