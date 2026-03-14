import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Stream to handle notification taps
  final StreamController<String?> _onNotificationTap =
      StreamController<String?>.broadcast();
  Stream<String?> get onNotificationTap => _onNotificationTap.stream;

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          _onNotificationTap.add(response.payload);
        }
      },
    );
  }

  Future<void> showMaintenanceAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'maintenance_channel',
      'Manutenzione Bici',
      channelDescription: 'Avvisi relativi alla manutenzione della bicicletta',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(id, title, body, details);
  }

  Future<void> showNewRideNotification(double km, String type) async {
    const androidDetails = AndroidNotificationDetails(
      'activity_channel',
      'Nuove Attività',
      channelDescription: 'Notifiche per nuove attività rilevate',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      888, // Fixed ID for new ride (or unique if multiple)
      'Nuova Attività Rilevata! 🚴',
      'Ehi, il Biciclista ha visto che hai fatto ${km.toStringAsFixed(1)}km di $type. Su quale bici li carichiamo?',
      details,
      payload: '$km|$type', // Pass km and type as payload
    );
  }
}
