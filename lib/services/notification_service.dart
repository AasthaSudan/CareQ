import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Request permission to send notifications
  Future<void> requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
    } else {
      print('User denied notification permission');
    }
  }

  // Subscribe to a topic for notifications
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  // Handle incoming notifications
  void handleNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print('Received a notification: ${message.notification!.title}');
        // Handle the notification here (e.g., show a dialog or update the UI)
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Opened app via notification: ${message.notification!.title}');
      // Navigate to the relevant screen based on the notification
    });
  }

  // Get the device token for push notifications
  Future<String?> getDeviceToken() async {
    return await _firebaseMessaging.getToken();
  }
}
