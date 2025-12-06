import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/meeting_provider.dart';
import '../models/meeting_state.dart';
import 'summary_screen.dart';

/// Meeting screen showing live transcript and translation
class MeetingScreen extends ConsumerWidget {
  const MeetingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingState = ref.watch(meetingProvider);
    final meetingNotifier = ref.read(meetingProvider.notifier);

    // Show error messages
    if (meetingState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(meetingState.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Status indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: meetingState.connectionStatus == ConnectionStatus.listening
                ? Colors.green[100]
                : Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (meetingState.connectionStatus == ConnectionStatus.listening)
                  const Icon(Icons.mic, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  meetingState.connectionStatus == ConnectionStatus.listening
                      ? 'Listening...'
                      : 'Connecting...',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Transcript section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transcript',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Stable transcript
                  if (meetingState.stableTranscript.isNotEmpty)
                    Text(
                      meetingState.stableTranscript,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  // Unstable transcript (gray, italic)
                  if (meetingState.unstableTranscript.isNotEmpty)
                    Text(
                      meetingState.unstableTranscript,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  if (meetingState.stableTranscript.isEmpty &&
                      meetingState.unstableTranscript.isEmpty)
                    Text(
                      'Waiting for audio...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[400],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Translation section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(
                top: BorderSide(color: Colors.blue[200]!),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Translation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (meetingState.translationText.isNotEmpty)
                  Text(
                    meetingState.translationText,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  )
                else
                  Text(
                    'Waiting for translation...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),

          // End Meeting button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: meetingState.connectionStatus == ConnectionStatus.listening
                  ? () async {
                      await meetingNotifier.endMeeting();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SummaryScreen(),
                          ),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'End Meeting',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

