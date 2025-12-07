import 'package:flutter/material.dart';

class MeetLensColors {
  static const Color background = Color(0xFFF7F7F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE3E3E3);
  static const Color primaryText = Color(0xFF111111);
  static const Color secondaryText = Color(0xFF6B6B6B);
  static const Color disabledText = Color(0xFFA3A3A3);
  static const Color danger = Color(0xFFD32F2F);
  static const Color primaryButton = Color(0xFF000000);
  static const Color onPrimaryButton = Color(0xFFFFFFFF);
}

class MeetLensSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
}

class MeetLensTypography {
  static const String _fontFamily = 'Inter';
  static const List<String> _fallbackFonts = [
    'SF Pro Text',
    'SF Pro Display',
    'Roboto',
    'Arial',
  ];

  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fallbackFonts,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: MeetLensColors.primaryText,
    height: 1.15,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fallbackFonts,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: MeetLensColors.primaryText,
    height: 1.2,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fallbackFonts,
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: MeetLensColors.secondaryText,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fallbackFonts,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: MeetLensColors.primaryText,
    height: 1.5,
  );

  // Slightly smaller body for dense captions when needed.
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fallbackFonts,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: MeetLensColors.primaryText,
    height: 1.45,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fallbackFonts,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: MeetLensColors.secondaryText,
    height: 1.35,
  );

  static const TextStyle captionSmall = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fallbackFonts,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: MeetLensColors.secondaryText,
    height: 1.3,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fallbackFonts,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: MeetLensColors.onPrimaryButton,
    height: 1.2,
  );
}

final ThemeData meetLensTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: MeetLensColors.background,
  primaryColor: MeetLensColors.primaryButton,
  fontFamily: MeetLensTypography._fontFamily,
  colorScheme: const ColorScheme.light(
    primary: MeetLensColors.primaryButton,
    onPrimary: MeetLensColors.onPrimaryButton,
    surface: MeetLensColors.surface,
    onSurface: MeetLensColors.primaryText,
    error: MeetLensColors.danger,
    background: MeetLensColors.background,
    onBackground: MeetLensColors.primaryText,
  ),
  textTheme: const TextTheme(
    displayLarge: MeetLensTypography.h1,
    headlineSmall: MeetLensTypography.h2,
    titleMedium: MeetLensTypography.subtitle,
    bodyLarge: MeetLensTypography.body,
    bodyMedium: MeetLensTypography.bodySmall,
    bodySmall: MeetLensTypography.caption,
    labelLarge: MeetLensTypography.button,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: MeetLensColors.surface,
    foregroundColor: MeetLensColors.primaryText,
    elevation: 0,
    centerTitle: true,
    shape: Border(bottom: BorderSide(color: MeetLensColors.border)),
    titleTextStyle: TextStyle(
      color: MeetLensColors.primaryText,
      fontSize: 17,
      fontWeight: FontWeight.w600,
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: MeetLensColors.border,
    thickness: 1,
    space: MeetLensSpacing.m,
  ),
  iconTheme: const IconThemeData(color: MeetLensColors.primaryText),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: MeetLensColors.primaryButton,
      foregroundColor: MeetLensColors.onPrimaryButton,
      minimumSize: const Size(double.infinity, 48),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
      textStyle: MeetLensTypography.button,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
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
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: MeetLensColors.secondaryText,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: MeetLensTypography.subtitle.copyWith(
        color: MeetLensColors.secondaryText,
        fontSize: 14,
      ),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: MeetLensColors.primaryButton,
    foregroundColor: MeetLensColors.onPrimaryButton,
    elevation: 4,
  ),
  cardTheme: CardThemeData(
    color: MeetLensColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: MeetLensColors.border),
    ),
    margin: const EdgeInsets.all(MeetLensSpacing.m),
  ),
);
