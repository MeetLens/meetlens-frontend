import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Primary black button following DLS (8–10px radius, 48/44px height).
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isDanger;
  final bool isLoading;
  final bool fullWidth;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isDanger = false,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabledBackground = MeetLensColors.border.withOpacity(0.5);
    final disabledForeground = MeetLensColors.disabledText;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDanger ? MeetLensColors.danger : MeetLensColors.primaryButton,
          foregroundColor: MeetLensColors.onPrimaryButton,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ).copyWith(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return disabledBackground;
            }
            if (isDanger) return MeetLensColors.danger;
            return MeetLensColors.primaryButton;
          }),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return disabledForeground;
            }
            return MeetLensColors.onPrimaryButton;
          }),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(MeetLensColors.onPrimaryButton),
                ),
              )
            : Text(
                text,
                style: MeetLensTypography.button.copyWith(
                  color: isDanger ? MeetLensColors.onPrimaryButton : MeetLensColors.onPrimaryButton,
                ),
              ),
      ),
    );
  }
}

/// Secondary outline button (black stroke, transparent background).
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabledColor = MeetLensColors.disabledText;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: MeetLensColors.primaryText,
          side: const BorderSide(color: MeetLensColors.primaryText, width: 1),
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: MeetLensTypography.button.copyWith(
            color: MeetLensColors.primaryText,
          ),
        ).copyWith(
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) return disabledColor;
            return MeetLensColors.primaryText;
          }),
          side: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return const BorderSide(color: MeetLensColors.border, width: 1);
            }
            return const BorderSide(color: MeetLensColors.primaryText, width: 1);
          }),
        ),
        child: isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(MeetLensColors.primaryText),
                ),
              )
            : Text(
                text,
                style: MeetLensTypography.button.copyWith(
                  color: MeetLensColors.primaryText,
                ),
              ),
      ),
    );
  }
}

/// Text-only tertiary action aligned to secondary color.
class TertiaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const TertiaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: MeetLensColors.secondaryText,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        textStyle: MeetLensTypography.subtitle.copyWith(
          color: MeetLensColors.secondaryText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ).copyWith(
        foregroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) return MeetLensColors.primaryText;
          return MeetLensColors.secondaryText;
        }),
      ),
      child: Text(text),
    );
  }
}
