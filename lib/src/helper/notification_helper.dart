// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Timezone (for scheduled notifications)
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// App Notification States
enum NotificationState { foreground, background, terminated }

class NotificationHelper {
  /// Holds notification data when app is opened from a killed state
  static Map<String, dynamic>? pendingRoute;

  /// Local notification plugin instance
  static final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Firebase messaging instance
  static final FirebaseMessaging messaging = FirebaseMessaging.instance;

  /// Used to prevent duplicate navigation triggers
  static String? _lastPayload;
  static DateTime? _lastTapTime;

  /// Navigation lock to avoid race conditions
  static bool _isNavigating = false;




  // =========================================================
  // PERMISSION + INITIALIZATION
  // =========================================================

  /// Returns current notification permission status
  static Future<AuthorizationStatus> checkNotificationStatus() async {
    final status = await messaging.getNotificationSettings();
    return status.authorizationStatus;
  }

  /// Request permission and initialize notification services
  static Future<void> initNotification() async {
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    /// Proceed only if user has granted permission
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||settings.authorizationStatus == AuthorizationStatus.provisional) {
      
      /// Android 13+ introduces runtime notification permission (POST_NOTIFICATIONS).
      /// Firebase's permission request alone is not always sufficient on Android.
      /// This ensures notifications can actually be displayed on newer Android versions.
      if (Platform.isAndroid) {
        await notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
      }

      // Setup notification channels, handlers, and timezone configuration
      await setupNotification();

      // Get device FCM token for push notifications
      await getFcmToken();

      /// Start listening to FCM events (foreground, background, terminated)
      getPushedNotification();
    } else {
      debugPrint("❌ Notification permission denied");
    }
  }

  // =========================================================
  // LOCAL NOTIFICATION SETUP
  // =========================================================

  /// Configure local notification plugin, channel, and timezone
  static Future<void> setupNotification() async {
    // Define platform-specific initialization settings
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization with all permissions requested
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combine into a single initialization settings object
    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    /// Initialize the plugin with settings and handlers
    await notificationsPlugin.initialize(
      settings: settings,

      /// Triggered when user taps notification in foreground
      onDidReceiveNotificationResponse: onForegroundNotification,

      /// Triggered when notification is tapped in background/terminated
      onDidReceiveBackgroundNotificationResponse: localNotificationBackgroundHandler,
    );

    /// High priority channel ensures heads-up notifications on Android
    const channel = AndroidNotificationChannel(
      'PETRAS',
      'PETRAS Notifications',
      importance: Importance.max,
      playSound: true
    );
    /// Create the channel on Android (no-op on iOS)
    await notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    /// Required for scheduling notifications with correct local timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kathmandu'));
  }



  // =========================================================
  // FCM TOKEN
  // =========================================================

  /// Retrieve device FCM token for push notifications
  static Future<String?> getFcmToken() async {
    try {
      if (Platform.isIOS) {
        // 1. Request permission first
        NotificationSettings settings = await messaging.requestPermission();
        if (settings.authorizationStatus != AuthorizationStatus.authorized &&
            settings.authorizationStatus != AuthorizationStatus.provisional) {
          debugPrint("⚠️ Notification permission not granted");
          return null;
        }

        // 2. Fetch APNs Token with retries (Physical Device only)
        String? apnsToken = await messaging.getAPNSToken();
        int retries = 0;
        while (apnsToken == null && retries < 3) {
          await Future.delayed(const Duration(seconds: 1));
          apnsToken = await messaging.getAPNSToken();
          retries++;
        }

        // 3. If APNs token is null, we are likely on a Simulator or APNs isn't configured.
        // We catch/skip the APNs check error so the app doesn't crash.
        if (apnsToken == null) {
          debugPrint("ℹ️ Running on iOS Simulator or APNs token not available. Attempting direct FCM token retrieval...");
        }
      }

      // Safe call wrapped in try-catch
      final fcm = await messaging.getToken();
      debugPrint("FCM Token: $fcm");
      return fcm;
    } catch (e) {
      debugPrint("⚠️ Could not fetch FCM Token (Expected on iOS Simulator): $e");
      return null;
    }
  }



  // =========================================================
  // NOTIFICATION UI CONFIG
  // =========================================================

  /// Common notification styling
  static NotificationDetails notificationDetails() {
    return const NotificationDetails(
      // Android channel configuration
      android: AndroidNotificationDetails(
        'PETRAS',
        'PETRAS',
        importance: Importance.high,
        icon: "ic_launcher",
        playSound: true
      ),
      // iOS presentation options (critical for showing notifications in foreground)
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }




  // =========================================================
  // FOREGROUND DISPLAY
  // =========================================================

  /// Show local notification when app is in foreground
  static Future<void> showNotification({
    required RemoteMessage message,
  }) async {
    try {
      final data = _parseMessage(message);

      /// Unique ID prevents notification override & tap issues
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await notificationsPlugin.show(
        id: id,
        title: message.notification?.title ?? "",
        body: message.notification?.body ?? "",
        notificationDetails: notificationDetails(),
        payload: jsonEncode(data),
      );
    } catch (e) {
      debugPrint("showNotification error: $e");
    }
  }




  // =========================================================
  // NOTIFICATION LISTENERS
  // =========================================================

  /// Listen to all notification states
  static Future<void> getPushedNotification() async {
    /// App opened from terminated state
    messaging.getInitialMessage().then((message) {
      if (message != null) {
        pendingRoute = _parseMessage(message);
      }
    });

    /// Foreground message → show local notification
    FirebaseMessaging.onMessage.listen((message) {
      showNotification(message: message);
    });

    /// Background notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      routeFromNotification(NotificationState.background, message);
    });
  }




  // =========================================================
  // TAP HANDLERS
  // =========================================================

  /// Handle tap when app is in foreground
  static void onForegroundNotification(NotificationResponse response) {
    if (response.payload == null || response.payload!.isEmpty) return;
    /// Directly route without delay since app is already active
    routeFromNotification(
      NotificationState.foreground,
      response.payload,
    );
  }



  // =========================================================
  // ROUTING LOGIC
  // =========================================================

  /// Normalize message into consistent Map format
  static Map<String, dynamic> _parseMessage(dynamic message) {
    try {
      if (message is RemoteMessage) return message.data;
      if (message is String) return jsonDecode(message);
      if (message is Map<String, dynamic>) return message;
      return {};
    } catch (e) {
      debugPrint("parseMessage error: $e");
      return {};
    }
  }

  /// Entry point for notification navigation
  static Future<void> routeFromNotification(NotificationState state, dynamic message) async {
    // Parse message into a consistent Map format regardless of source (FCM or local notification)
    final messageData = _parseMessage(message);
    if (messageData.isEmpty) return;

    /// Create a unique payload string for duplicate tap prevention
    final currentPayload = jsonEncode(messageData);
    final now = DateTime.now();

    /// Prevent duplicate navigation (FCM + local double trigger)
    if (_lastPayload == currentPayload && _lastTapTime != null && now.difference(_lastTapTime!).inMilliseconds < 1000) {
      debugPrint("Duplicate tap blocked");
      return;
    }

    // Update last payload and tap time for future duplicate checks
    _lastPayload = currentPayload;
    _lastTapTime = now;

    // Ensure user is authenticated before navigating to protected routes
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;
    if (state == NotificationState.terminated) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _handleRouting(messageData);
      });
    } else {
      await _handleRouting(messageData);
    }
  }

  /// Execute navigation based on notification type
  static Future<void> _handleRouting(Map<String, dynamic> messageData) async {
    // Prevent multiple navigations if user taps multiple notifications rapidly
    if (_isNavigating) return;
    // Set navigating flag to true to block subsequent taps until navigation is complete
    _isNavigating = true;

    try {
      final type = messageData["type"];

      switch (type) {
        case "calender":
          break;

        case "notificationList":
          // await Get.to(() => const NotificationPage());
          break;

        default: debugPrint("Unknown notification type: $type");
      }
    } finally {
      // Reset navigating flag after a short delay to allow navigation to complete and prevent
      Future.delayed(
        const Duration(milliseconds: 500),
        () => _isNavigating = false,
      );
    }
  }

  /// Handle pending navigation after cold start
  static void handlePendingNavigation() {
    // If there's no pending route, simply return
    if (pendingRoute == null) return;

    // Extract data and clear pending route to prevent duplicates
    final data = Map<String, dynamic>.from(pendingRoute!);
    // Clear pending route to prevent duplicate navigation
    pendingRoute = null;

    // Route based on the extracted data
    routeFromNotification(NotificationState.terminated, data);
  }



  // =========================================================
  // BACKGROUND HANDLERS
  // =========================================================

  /// Firebase background message handler (used for silent updates)
  @pragma('vm:entry-point')
  static Future<void> backgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
  }

  /// Handle tap when app is background/terminated (local notification)
  @pragma('vm:entry-point')
  static void localNotificationBackgroundHandler(NotificationResponse response) {
    if (response.payload == null) return;

    try {
      pendingRoute = jsonDecode(response.payload!);
    } catch (e) {
      debugPrint("Background tap parse error: $e");
    }
  }
}