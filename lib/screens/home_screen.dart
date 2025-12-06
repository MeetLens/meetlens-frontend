import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/meeting_provider.dart';
import 'meeting_screen.dart';

/// Home screen with Start Meeting button
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.watch(audioServiceProvider);
    final meetingState = ref.watch(meetingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MeetLens'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mic,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              const Text(
                'Welcome to MeetLens',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Real-time transcription and translation for your meetings',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),
              FutureBuilder<bool>(
                future: audioService.hasPermission(),
                builder: (context, snapshot) {
                  final hasPermission = snapshot.data ?? false;
                  
                  return Column(
                    children: [
                      if (!hasPermission)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            'Microphone permission required',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: () async {
                          if (!hasPermission) {
                            final granted = await audioService.requestPermission();
                            if (!granted) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Microphone permission is required to start a meeting',
                                    ),
                                  ),
                                );
                              }
                              return;
                            }
                          }

                          // Start meeting
                          final meetingNotifier = ref.read(meetingProvider.notifier);
                          final started = await meetingNotifier.startMeeting();

                          if (started && context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MeetingScreen(),
                              ),
                            );
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  meetingState.errorMessage ?? 'Failed to start meeting',
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('Start Meeting'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

