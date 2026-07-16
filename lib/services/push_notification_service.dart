import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'local_notification_service.dart';

class PushNotificationsService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static Future init() async {
    await messaging.requestPermission();
    String? token = await messaging.getToken();
    log('token::${token!}');

    // Send the initial token too, not just refreshes
    await sendTokenToServer(token);

    messaging.onTokenRefresh.listen((newToken) {
      sendTokenToServer(newToken);
    });

    // Listen for auth state changes to ensure the token is saved once the user logs in
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        String? currentToken = await messaging.getToken();
        if (currentToken != null) await sendTokenToServer(currentToken);
      }
    });

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    //foreground
    handleForegroundMessage();
    messaging.subscribeToTopic('all').then((val) {
      log('sub');
    });

    // messaging.unsubscribeFromTopic('all');
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    await Firebase.initializeApp();
    log(message.notification?.title ?? 'null');
  }

  static void handleForegroundMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // show local notification
      LocalNotificationService.showBasicNotification(message);
    });
  }

  static Future<void> sendTokenToServer(String token) async {
    // option 1 => API
    // option 2 => Firebase
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      log('sendTokenToServer: no logged-in user, skipping');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('fcm_tokens')
          .doc(token)
          .set({
            'token': token,
            'platform': _platformName(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      log('FCM token saved to Firestore for user ${user.uid}');
    } catch (e) {
      log('sendTokenToServer error: $e');
    }
  }

  static String _platformName() {
    // Optional metadata to help you tell devices apart server-side
    return defaultTargetPlatform.toString();
  }
}
