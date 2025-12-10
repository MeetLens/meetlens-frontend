import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/meeting_state.dart';
import '../providers/meeting_provider.dart';
import '../utils/transcript_utils.dart';
import '../widgets/buttons.dart';
import '../widgets/transcript_widgets.dart';
import 'full_transcript_screen.dart';
import 'summary_screen.dart';

/// Live meeting screen using lyrics-style layout per DLS.
class MeetingScreen extends ConsumerStatefulWidget {
  const MeetingScreen({super.key});

  @override
  ConsumerState<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends ConsumerState<MeetingScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;
  bool _isPaused = false;
  final double _rowExtent = 118; // estimated height for consistent centering

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleUserScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleUserScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleUserScroll() {
    if (!_scrollController.hasClients) return;
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.forward && _autoScroll) {
      // User scrolled upward: pause auto-scroll and show chip.
      setState(() {
        _autoScroll = false;
      });
    }
  }

  List<TranscriptItem> _buildTranscript(MeetingState state) {
    final originals = TranscriptUtils.splitIntoSegments(state.stableTranscript);
    final translations = TranscriptUtils.splitIntoSegments(state.stableTranslation);
    final count = max(originals.length, translations.length);
    final now = DateTime.now();
    final items = <TranscriptItem>[];

    for (int i = 0; i < count; i++) {
      items.add(
        TranscriptItem(
          id: 'stable_$i',
          original: i < originals.length ? originals[i] : '',
          translation: i < translations.length ? translations[i] : '',
          timestamp: now.subtract(Duration(minutes: count - i)),
        ),
      );
    }

    // Treat unstable transcript as the current line.
    if (state.unstableTranscript.isNotEmpty) {
      items.add(
        TranscriptItem(
          id: 'live_current',
          original: state.unstableTranscript,
          translation: state.partialTranslation.isNotEmpty
              ? state.partialTranslation
              : (translations.isNotEmpty ? translations.last : ''),
          isPartialTranslation: state.partialTranslation.isNotEmpty,
          timestamp: now,
        ),
      );
    }

    return items;
  }

  void _scrollToCurrent(int index) {
    if (!_autoScroll || !_scrollController.hasClients) return;
    final targetOffset = max<double>((index - 1) * _rowExtent, 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final meetingState = ref.watch(meetingProvider);
    final meetingNotifier = ref.read(meetingProvider.notifier);
    final items = _buildTranscript(meetingState);
    final currentIndex = items.isNotEmpty ? items.length - 1 : 0;

    // Show any errors surfaced by the provider.
    if (meetingState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(meetingState.errorMessage!),
            backgroundColor: MeetLensColors.danger,
          ),
        );
      });
    }

    // Keep the current line centered when auto-scroll is enabled.
    if (_autoScroll && items.isNotEmpty) {
      _scrollToCurrent(currentIndex);
    }

    return Scaffold(
      backgroundColor: MeetLensColors.background,
      appBar: AppBar(
        title: const Text('Live Meeting'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Full transcript',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FullTranscriptScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Live lyrics-style transcript
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            vertical: constraints.maxHeight * 0.30,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final isCurrent = index == currentIndex;
                            final isNext = index == currentIndex - 1;
                            return LiveTranscriptRow(
                              item: item,
                              isCurrent: isCurrent,
                              isNext: isNext,
                            );
                          },
                        );
                      },
                    ),
                    if (!_autoScroll)
                      Positioned(
                        bottom: MeetLensSpacing.l,
                        child: JumpToNowButton(
                          onPressed: () {
                            setState(() => _autoScroll = true);
                            _scrollToCurrent(currentIndex);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom control bar
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: MeetLensSpacing.m,
                  vertical: MeetLensSpacing.m,
                ),
                decoration: const BoxDecoration(
                  color: MeetLensColors.surface,
                  border: Border(
                    top: BorderSide(color: MeetLensColors.border),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: _isPaused ? 'Resume' : 'Pause',
                          onPressed: () {
                            setState(() => _isPaused = !_isPaused);
                            // Hook into pause/resume logic when available.
                          },
                        ),
                      ),
                      const SizedBox(width: MeetLensSpacing.m),
                      Text(
                        meetingState.connectionStatus == ConnectionStatus.listening
                            ? 'Live'
                            : 'Connecting',
                        style: MeetLensTypography.caption.copyWith(
                          color: MeetLensColors.secondaryText,
                        ),
                      ),
                      const SizedBox(width: MeetLensSpacing.m),
                      Expanded(
                        child: PrimaryButton(
                          text: 'End Meeting',
                          isDanger: true,
                          fullWidth: true,
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

