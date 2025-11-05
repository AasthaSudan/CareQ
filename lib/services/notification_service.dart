import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    showNotification(
      title: message.notification?.title ?? 'Alert',
      body: message.notification?.body ?? '',
      priority: message.data['priority'] ?? 'normal',
    );
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String priority = 'normal',
  }) async {
    final importance = priority == 'critical'
        ? Importance.max
        : Importance.high;

    final androidDetails = AndroidNotificationDetails(
      'triage_channel',
      'Triage Notifications',
      channelDescription: 'Critical patient alerts',
      importance: importance,
      priority: priority == 'critical' ? Priority.max : Priority.high,
      color: priority == 'critical' ? Color(0xFFEF5350) : Color(0xFF4DB6AC),
      playSound: true,
      sound: priority == 'critical'
          ? RawResourceAndroidNotificationSound('critical_alert')
          : null,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      interruptionLevel: priority == 'critical'
          ? InterruptionLevel.critical
          : InterruptionLevel.timeSensitive,
    );

    await _notifications.show(
      DateTime.now().millisecond,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  Future<void> sendCriticalPatientAlert(String patientName) async {
    await showNotification(
      title: '🚨 CRITICAL PATIENT ALERT',
      body: '$patientName requires immediate attention!',
      priority: 'critical',
    );
  }
}