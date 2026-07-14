import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:test_notification/services/local_notification_service.dart';
import 'services/push_notification_service.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Future.wait([PushNotificationsService.init(), LocalNotificationService.init()]);
  runApp(const PushNotifications());
}

class PushNotifications extends StatelessWidget {
  const PushNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(appBar: AppBar(title: const Text('Push Notifications'))),
    );
  }
}
