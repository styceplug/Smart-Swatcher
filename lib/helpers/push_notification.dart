/*
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fyndr/controllers/auth_controller.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';
import '../routes/routes.dart';
import '../utils/app_constants.dart';

import 'dart:convert';


@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
  print("🔔 Background notification clicked: ${response.payload}");
}

class FirebaseMessagingHelper {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Call this from `main.dart`
  static Future<void> initializeFCM() async {
    await _requestPermissions();
    await _setupLocalNotifications();
    await _syncDeviceToken();
    _setupListeners();
  }

  static Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('🔔 Notification permission: ${settings.authorizationStatus}');
  }

  static Future<void> _syncDeviceToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token == null) return;

      final auth = Get.find<AuthController>();
      final isMerchant = auth.sharedPreferences.getBool(AppConstants.isMerchant) ?? false;
      final platform = Platform.isIOS ? 'ios' : 'aandroid';
      final newToken = DeviceToken(token: token, platform: platform);

      if (isMerchant && auth.currentMerchant.value != null) {
        final merchant = auth.currentMerchant.value!;
        final updatedTokens = _mergeTokens(merchant.deviceTokens, newToken);
        auth.currentMerchant.value = merchant.copyWith(deviceTokens: updatedTokens);
        print('✅ Synced token for merchant: $token');
      } else if (auth.currentUser.value != null) {
        final user = auth.currentUser.value!;
        final updatedTokens = _mergeTokens(user.deviceTokens, newToken);
        auth.currentUser.value = user.copyWith(deviceTokens: updatedTokens);
        print('✅ Synced token for user: $token');
      }
    } catch (e) {
      print('❌ Error syncing token: $e');
    }
  }

  static List<DeviceToken> _mergeTokens(List<DeviceToken>? existing, DeviceToken newToken) {
    final tokens = List<DeviceToken>.from(existing ?? []);
    tokens.removeWhere((t) => t.token == newToken.token);
    tokens.add(newToken);
    return tokens;
  }

  static Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Used for important notifications',
      importance: Importance.max,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        print('🔔 Foreground notification tapped: ${response.payload}');
      },
      onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse,
    );
  }

  static void _setupListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('📩 FCM received (foreground): ${message.notification?.title}');
      await _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📦 App opened from notification: ${message.notification?.title}');
      // Optional: navigate using message.data
      Get.toNamed(AppRoutes.notificationScreen);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print('🟡 App launched from terminated state via notification');
        // Optional: handle deep links here
      }
    });
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    final String? imageUrl = message.notification?.android?.imageUrl ?? message.notification?.apple?.imageUrl;

    BigPictureStyleInformation? style;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      style = BigPictureStyleInformation(
        FilePathAndroidBitmap(imageUrl),
        largeIcon: FilePathAndroidBitmap(imageUrl),
        contentTitle: notification?.title,
        summaryText: notification?.body,
      );
    }

    final androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      icon: '@mipmap/ic_launcher',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: style,
    );

    final iosDetails = DarwinNotificationDetails(
      attachments: imageUrl != null ? [DarwinNotificationAttachment(imageUrl)] : [],
    );

    await _localNotificationsPlugin.show(
      notification.hashCode,
      notification?.title,
      notification?.body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: jsonEncode(message.data),
    );
  }

  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("📨 [BG] Title: ${message.notification?.title}");
    print("📨 [BG] Body: ${message.notification?.body}");
    print("📨 [BG] Data: ${message.data}");
  }
}*/
