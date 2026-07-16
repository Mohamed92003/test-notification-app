import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class LocalNotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static StreamController<NotificationResponse> streamController =
      StreamController();

  static void onTap(NotificationResponse notificationResponse) {
    // log(notificationResponse.id!.toString());
    // log(notificationResponse.payload!.toString());
    streamController.add(notificationResponse);
    // Navigator.push(context, route);
  }

  static Future init() async {
    InitializationSettings settings = const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    flutterLocalNotificationsPlugin.initialize(
      onDidReceiveNotificationResponse: onTap,
      onDidReceiveBackgroundNotificationResponse: onTap,
      settings: settings,
    );
  }

  //basic Notification
  //basic Notification
  static void showBasicNotification(RemoteMessage message) async {
    final String? imageUrl = message.notification?.android?.imageUrl;
    StyleInformation? styleInformation;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final http.Response image = await http.get(Uri.parse(imageUrl));
        styleInformation = BigPictureStyleInformation(
          ByteArrayAndroidBitmap.fromBase64String(
            base64Encode(image.bodyBytes),
          ),
          largeIcon: ByteArrayAndroidBitmap.fromBase64String(
            base64Encode(image.bodyBytes),
          ),
        );
      } catch (e) {
        // Image fetch failed - fall back to a plain notification instead of crashing
        styleInformation = null;
      }
    }

    AndroidNotificationDetails android = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: styleInformation,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('fi_confirmation'),
    );
    NotificationDetails details = NotificationDetails(android: android);
    await flutterLocalNotificationsPlugin.show(
      id: 0,
      title: message.notification?.title ?? 'null',
      body: message.notification?.body ?? 'null',
      payload: message.data.toString(),
      notificationDetails: details,
    );
  }
}
