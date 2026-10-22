class AppDurations {
  const AppDurations._();

  // ── Animations ───────────────────────────────────────────────────────────
  /// Quick fade, e.g. quest tile completion dim.
  static const Duration quick = Duration(milliseconds: 200);

  /// Standard AnimatedSwitcher / content swap.
  static const Duration standard = Duration(milliseconds: 250);

  /// Modal / dialog transition (tier-up celebration).
  static const Duration dialog = Duration(milliseconds: 400);

  // ── Delays / timeouts ────────────────────────────────────────────────────
  /// Minimum time the splash screen stays visible before routing.
  static const Duration splashMinVisible = Duration(milliseconds: 600);

  /// How long we wait for Firebase to restore a session on cold start.
  static const Duration authRestoreTimeout = Duration(seconds: 10);

  /// How long we wait for pending Firestore writes during logout before giving up.
  static const Duration logoutFlushTimeout = Duration(seconds: 5);
}
