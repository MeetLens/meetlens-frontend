import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../providers/meeting_provider.dart';
import '../widgets/buttons.dart';
import 'meeting_screen.dart';

/// Welcome screen aligned to MeetLens DLS (monochrome, premium, minimal).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.watch(audioServiceProvider);
    final meetingState = ref.watch(meetingProvider);

    return Scaffold(
      backgroundColor: MeetLensColors.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: MeetLensSpacing.m),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: MeetLensColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(color: MeetLensColors.border),
                    ),
                    child: const Icon(
                      Icons.mic_none,
                      size: 44,
                      color: MeetLensColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: MeetLensSpacing.xl),
                  Text(
                    'Welcome to MeetLens',
                    style: MeetLensTypography.h1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: MeetLensSpacing.s),
                  Text(
                    'Real-time transcription and translation for your meetings.',
                    style: MeetLensTypography.subtitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: MeetLensSpacing.xl),
                  FutureBuilder<bool>(
                    future: audioService.hasPermission(),
                    builder: (context, snapshot) {
                      final hasPermission = snapshot.data ?? false;

                      return Column(
                        children: [
                          if (!hasPermission)
                            Padding(
                              padding: const EdgeInsets.only(bottom: MeetLensSpacing.s),
                              child: Text(
                                'Microphone permission required',
                                style: MeetLensTypography.caption.copyWith(
                                  color: MeetLensColors.secondaryText,
                                ),
                              ),
                            ),
                          PrimaryButton(
                            text: 'Start Meeting',
                            fullWidth: true,
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
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
