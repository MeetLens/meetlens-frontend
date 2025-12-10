import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Model representing a single transcript unit with original and translated text.
class TranscriptItem {
  final String id;
  final String original;
  final String translation;
  final DateTime timestamp;
  final bool isPartialTranslation;

  TranscriptItem({
    required this.id,
    required this.original,
    required this.translation,
    required this.timestamp,
    this.isPartialTranslation = false,
  });
}

class LiveTranscriptRow extends StatelessWidget {
  final TranscriptItem item;
  final bool isCurrent;
  final bool isNext;

  const LiveTranscriptRow({
    super.key,
    required this.item,
    this.isCurrent = false,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    // Opacity logic: Current = 1.0, Past = 0.55, Next = 0.7
    final double opacity = isCurrent ? 1.0 : (isNext ? 0.7 : 0.55);

    final baseTranslationStyle = MeetLensTypography.body.copyWith(
      fontSize: 16,
      height: 1.4,
      fontWeight: FontWeight.w500,
    );

    return Opacity(
      opacity: opacity,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: MeetLensSpacing.s,
          horizontal: MeetLensSpacing.m,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: MeetLensSpacing.m,
          horizontal: MeetLensSpacing.m,
        ),
        decoration: isCurrent
            ? BoxDecoration(
                color: MeetLensColors.surface,
                border: const Border(
                  left: BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Original text (small, secondary)
            Text(
              item.original,
              style: MeetLensTypography.caption.copyWith(
                color: MeetLensColors.secondaryText,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: MeetLensSpacing.xs + 2),
            // Bottom: Translation (larger, primary)
            Text(
              item.translation,
              style: (isCurrent
                      ? baseTranslationStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        )
                      : baseTranslationStyle)
                  .copyWith(
                color: item.isPartialTranslation
                    ? MeetLensColors.secondaryText
                    : null,
                fontStyle:
                    item.isPartialTranslation ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JumpToNowButton extends StatelessWidget {
  final VoidCallback onPressed;

  const JumpToNowButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MeetLensColors.primaryButton,
      borderRadius: BorderRadius.circular(24),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MeetLensSpacing.l,
            vertical: MeetLensSpacing.s,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.arrow_downward, size: 16, color: MeetLensColors.onPrimaryButton),
              SizedBox(width: MeetLensSpacing.s),
              Text(
                'Jump to Now',
                style: MeetLensTypography.button,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
