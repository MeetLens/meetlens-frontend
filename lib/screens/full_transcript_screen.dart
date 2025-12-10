import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/meeting_provider.dart';
import '../models/meeting_state.dart';
import '../config/theme.dart';
import '../utils/transcript_utils.dart';
import '../widgets/transcript_widgets.dart';

class FullTranscriptScreen extends ConsumerWidget {
  const FullTranscriptScreen({super.key});

  List<TranscriptItem> _generateTranscriptItems(MeetingState state) {
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
          timestamp: now.subtract(Duration(minutes: (count - i) * 5)),
        ),
      );
    }

    if (state.unstableTranscript.isNotEmpty) {
      items.add(
        TranscriptItem(
          id: 'current',
          original: state.unstableTranscript,
          translation: state.partialTranslation,
          isPartialTranslation: state.partialTranslation.isNotEmpty,
          timestamp: now,
        ),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingState = ref.watch(meetingProvider);
    final items = _generateTranscriptItems(meetingState);

    return Scaffold(
      backgroundColor: MeetLensColors.surface,
      appBar: AppBar(
        title: const Text('Full Transcript'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: MeetLensSpacing.m,
              vertical: MeetLensSpacing.l,
            ),
            itemCount: items.length,
            separatorBuilder: (context, index) {
              final previous = items[index];
              final next = items[index + 1];
              final minuteGap = next.timestamp.difference(previous.timestamp).inMinutes.abs();
              final showDivider = minuteGap >= 5;
              if (!showDivider) return const SizedBox(height: MeetLensSpacing.l);

              final label = '${next.timestamp.hour.toString().padLeft(2, '0')}:${next.timestamp.minute.toString().padLeft(2, '0')}';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: MeetLensSpacing.m),
                child: Row(
                  children: [
                    const Expanded(child: Divider(thickness: 1, color: MeetLensColors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: MeetLensSpacing.m),
                      child: Text(
                        label,
                        style: MeetLensTypography.captionSmall,
                      ),
                    ),
                    const Expanded(child: Divider(thickness: 1, color: MeetLensColors.border)),
                  ],
                ),
              );
            },
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: MeetLensSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                      style: MeetLensTypography.captionSmall,
                    ),
                    const SizedBox(height: MeetLensSpacing.xs),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.original,
                            style: MeetLensTypography.body.copyWith(
                              color: MeetLensColors.secondaryText,
                            ),
                          ),
                        ),
                        const SizedBox(width: MeetLensSpacing.m),
                        Expanded(
                          child: Text(
                            item.translation,
                            style: MeetLensTypography.body.copyWith(
                              fontWeight: FontWeight.w500,
                              color: item.isPartialTranslation
                                  ? MeetLensColors.secondaryText
                                  : null,
                              fontStyle: item.isPartialTranslation
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
