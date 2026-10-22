import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_sizes.dart';

/// Reusable text styles calibrated for the Press Start 2P pixel font.
///
/// Rules of thumb:
///  - Pixel glyphs are ~2x wider than a system font at the same size.
///  - Line-height 1.6+ keeps rows from cramping vertically.
///  - Letter-spacing stays low — the font is already wide.
///  - Font-weight is a no-op (only one weight ships).
class AppTextStyles {
  AppTextStyles._();

  static const String pixelFont = 'PressStart2P';

  // ---------- Display / Headings ----------
  static const TextStyle display = TextStyle(
    fontFamily: pixelFont,
    fontSize: AppSizes.fontDisplay,
    height: 1.6,
    letterSpacing: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: pixelFont,
    fontSize: AppSizes.fontXxl,
    height: 1.6,
    letterSpacing: 1,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: pixelFont,
    fontSize: AppSizes.fontXl,
    height: 1.6,
    letterSpacing: 0.8,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: pixelFont,
    fontSize: AppSizes.fontLg,
    height: 1.6,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  // ---------- Body ----------
  static const TextStyle body = TextStyle(
    fontFamily: pixelFont,
    fontSize: AppSizes.fontMd,
    height: 1.8,
    letterSpacing: 0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: pixelFont,
    fontSize: AppSizes.fontMd,
    height: 1.8,
    letterSpacing: 0.3,
    color: AppColors.textSecondary,
  );

  // ---------- Labels / Subheadings ----------
  static const TextStyle subheading = TextStyle(
    fontFamily: pixelFont,
    fontSize: AppSizes.fontSm,
    height: 1.7,
    letterSpacing: 1,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: pixelFont,
    fontSize: AppSizes.fontXs,
    height: 1.6,
    letterSpacing: 0.6,
    color: AppColors.textSecondary,
  );

  // ---------- Button text ----------
  static const TextStyle button = TextStyle(
    fontFamily: pixelFont,
    fontSize: AppSizes.fontLg,
    height: 1.5,
    letterSpacing: 1,
  );

  static const TextStyle buttonSm = TextStyle(
    fontFamily: pixelFont,
    fontSize: AppSizes.fontSm,
    height: 1.5,
    letterSpacing: 0.6,
  );

  // ---------- Link / caption ----------
  static const TextStyle link = TextStyle(
    fontFamily: pixelFont,
    fontSize: AppSizes.fontMd,
    height: 1.7,
    letterSpacing: 0.3,
    color: AppColors.primary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: pixelFont,
    fontSize: AppSizes.fontSm,
    height: 1.6,
    letterSpacing: 0.3,
    color: AppColors.textMuted,
  );

  /// Smallest legible style — for badges and pills.
  static const TextStyle micro = TextStyle(
    fontFamily: pixelFont,
    fontSize: AppSizes.fontXs,
    height: 1.4,
    letterSpacing: 0.4,
    color: AppColors.textPrimary,
  );
}
