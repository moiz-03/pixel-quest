import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/splash/splash_screen.dart';
import 'services/firebase_emulator.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'viewmodels/auth_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Route uncaught errors in the root zone to Crashlytics.
  // Replaces Flutter's default "print to console and forget" behavior.
  runZonedGuarded(
    () async {
      await _bootstrap();

      // Route Flutter framework errors (build, layout, paint) to Crashlytics.
      FlutterError.onError = (details) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        if (kDebugMode) {
          FlutterError.presentError(details);
        }
      };

      // Route errors from outside the Flutter framework (engine, platform).
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      runApp(const PixelQuestApp());
    },
    (error, stack) {
      // Catch-all for async errors that escape to the root zone.
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}

Future<void> _bootstrap() async {
  // ── 1. Firebase init ───────────────────────────────────────────────────
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized');
  } catch (e, st) {
    debugPrint('❌ Firebase init failed: $e\n$st');
    runApp(const _FatalErrorApp(message: 'Could not connect to the server.'));
    return;
  }

  final useEmulator = kDebugMode;

  // ── 2. Emulator connection (debug only) ────────────────────────────────
  if (useEmulator) {
    await connectToEmulators();
  }

  // ── 3. Crashlytics (production only) ───────────────────────────────────
  // Enabled AFTER Firebase init but BEFORE any UI work, so crashes during
  // startup are captured. Disabled in debug so you don't pollute the
  // dashboard with dev-only errors.
  if (!useEmulator) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  // ── 4. App Check (production only) ─────────────────────────────────────
  if (!useEmulator) {
    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.deviceCheck,
      );
      debugPrint('✅ App Check activated');
    } catch (e, st) {
      // Non-fatal — see previous notes on why.
      debugPrint('⚠️ App Check activation failed (non-fatal): $e\n$st');
    }
  } else {
    debugPrint('⏭️ Skipping App Check (emulator mode)');
  }

  // ── 5. Firestore settings (production only) ────────────────────────────
  if (!useEmulator) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // ── 6. Notifications ───────────────────────────────────────────────────
  try {
    await NotificationService.instance.init();
    debugPrint('✅ Notifications initialized');
  } catch (e, st) {
    debugPrint('⚠️ Notification init failed: $e\n$st');
  }

  // ── 7. System UI ───────────────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0B0F1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
}

class PixelQuestApp extends StatelessWidget {
  const PixelQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthViewModel())],
      child: MaterialApp(
        title: 'Pixel Quest',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const _RootGate(),
      ),
    );
  }
}

class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) => const SplashScreen();
}

// ═════════════════════════════════════════════════════════════════════════════
// Fatal error fallback — shown if Firebase fails to initialize
// ═════════════════════════════════════════════════════════════════════════════
class _FatalErrorApp extends StatelessWidget {
  final String message;

  const _FatalErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _FatalErrorScreen(message: message),
    );
  }
}

class _FatalErrorScreen extends StatelessWidget {
  final String message;

  const _FatalErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Startup failed:\n\n$message',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
