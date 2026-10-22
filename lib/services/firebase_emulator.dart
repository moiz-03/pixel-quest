import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

Future<void> connectToEmulators() async {
  // We use 127.0.0.1 because we tunnel it via USB (adb reverse)
  const host = '127.0.0.1';

  try {
    // automaticHostMapping: false forces the app to use 127.0.0.1
    // instead of rewriting it to 10.0.2.2 (which only works on emulators)
    await FirebaseAuth.instance.useAuthEmulator(
      host,
      9099,
      automaticHostMapping: false,
    );

    FirebaseFirestore.instance.useFirestoreEmulator(
      host,
      8080,
      automaticHostMapping: false,
    );

    debugPrint(
      '🔌 Configured for Firebase Emulator Suite at $host (USB Tunnel)',
    );
  } catch (e) {
    debugPrint('⚠️ Failed to configure emulators: $e');
  }
}
