import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/env.dart';

/// Top-level background message handler required by FCM.
/// Must be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized when this handler runs in a separate
  // isolate.  We do NOT need to re-initialize Firebase here.
  // Simply handle the background message (e.g. update local DB, show
  // a local notification if needed).  For now we do nothing extra —
  // FCM will show the notification automatically when the app is in
  // background/terminated.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (required before FCM can be used)
  // try {
  //   await Firebase.initializeApp();
  //   // Register the background message handler BEFORE the app starts
  //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // } catch (e) {
  //   debugPrint('Firebase initialization failed: $e');
  // }

  // Initialize Supabase (no-op when SUPABASE_URL/ANON_KEY are not set)
  await Env.init();

  runApp(
    const ProviderScope(
      child: CampusSafeApp(),
    ),
  );
}
