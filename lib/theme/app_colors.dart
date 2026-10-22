import 'package:flutter/material.dart';

/// Centralized color palette for Pixel Quest.
/// Never hardcode a Color(...) inside a widget — always pull from here.
class AppColors {
  AppColors._();

  // ---------- Pixel Quest dashboard ----------
  static const Color xpGreen = Color(0xFF4DFF6B); // progress fills, NEW QUEST
  static const Color titleYellow = Color(0xFFFFD93D); // PIXELQUEST title
  static const Color cardBg = Color(0xFF131A33); // quest card background
  static const Color cardBgDone = Color(0xFF0E142A); // completed (greyed) card
  static const Color badgeBlue = Color(0xFF3AA0FF);
  static const Color badgePink = Color(0xFFFF4D8F);
  static const Color badgePurple = Color(0xFF9D6BFF);
  static const Color badgeCyan = Color(0xFF4DD0E1);

  // ---------- Brand ----------
  static const Color primary = Color(0xFF00E5A0); // neon mint (CTA / accents)
  static const Color primaryDark = Color(0xFF00B37A); // pressed / hover
  static const Color primarySoft = Color(0x1F00E5A0); // 12% glow fills

  static const Color secondary = Color(0xFF7C5CFF); // violet (rare accents)
  static const Color accentGold = Color(0xFFFFC542); // coins / rewards
  static const Color accentDanger = Color(0xFFFF5C7A); // errors / destructive

  // ---------- Surfaces (dark theme) ----------
  static const Color background = Color(0xFF0B0F1A); // app scaffold
  static const Color backgroundAlt = Color(
    0xFF151E33,
  ); // gradient bottom / cards
  static const Color surface = Color(0xFF151E33); // input fill
  static const Color surfaceHigh = Color(0xFF1E2A45); // elevated cards
  static const Color border = Color(0xFF25324F); // subtle outlines
  static const Color divider = Color(0xFF1C2740);

  // ---------- Text ----------
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8FA3BF); // subheadings, labels
  static const Color textMuted = Color(0xFF5C6E8C); // hints, disabled
  static const Color textOnPrimary = Color(0xFF06131B); // text on mint buttons

  // ---------- Status ----------
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFFFB020);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3AA0FF);

  // ---------- Gradients ----------
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, backgroundAlt],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF00C2FF)],
  );

  // ---------- Shadows / glows ----------
  static List<BoxShadow> glowPrimary({double blur = 24, double spread = 0}) => [
    BoxShadow(
      color: primary.withValues(alpha: 0.35),
      blurRadius: blur,
      spreadRadius: spread,
    ),
  ];

  static final List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.35),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];
}
