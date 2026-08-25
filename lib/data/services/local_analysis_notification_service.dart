import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/services/analysis_notification_service.dart';

class LocalAnalysisNotificationService implements AnalysisNotificationService {
  static const completedTitle = 'Check-up complete';
  static const completedBody =
      'Your private check-up report is ready in HerAlth.';
  static const failedTitle = "Check-up couldn't be completed";
  static const failedBody = 'Open HerAlth to try your check-up again.';

  static const _channelId = 'heralth_ai_analysis';
  static const _channelName = 'AI check-up status';
  static const _channelDescription =
      'Notifies you when an AI check-up completes or fails.';
  static const _maxNotificationId = 0x7fffffff;

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  int _lastNotificationId = 0;

  LocalAnalysisNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  Future<bool> initialize() async {
    if (_initialized) return true;
    if (kIsWeb || !_isSupportedPlatform) return false;

    try {
      final result = await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('launcher_icon'),
          iOS: IOSInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
            defaultPresentAlert: true,
            defaultPresentBanner: true,
            defaultPresentList: true,
            defaultPresentSound: true,
          ),
          macOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
            defaultPresentAlert: true,
            defaultPresentBanner: true,
            defaultPresentList: true,
            defaultPresentSound: true,
          ),
        ),
      );
      _initialized = result != false;
    } on Exception {
      _initialized = false;
    }
    return _initialized;
  }

  @override
  Future<bool> requestPermission() async {
    if (!await initialize()) return false;

    try {
      return switch (defaultTargetPlatform) {
        TargetPlatform.android =>
          await _plugin
                  .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin
                  >()
                  ?.requestNotificationsPermission() ??
              true,
        TargetPlatform.iOS =>
          await _plugin
                  .resolvePlatformSpecificImplementation<
                    IOSFlutterLocalNotificationsPlugin
                  >()
                  ?.requestPermissions(alert: true, sound: true) ??
              false,
        TargetPlatform.macOS =>
          await _plugin
                  .resolvePlatformSpecificImplementation<
                    MacOSFlutterLocalNotificationsPlugin
                  >()
                  ?.requestPermissions(alert: true, sound: true) ??
              false,
        _ => false,
      };
    } on Exception {
      return false;
    }
  }

  @override
  Future<void> showAnalysisCompleted() => _show(
    title: completedTitle,
    body: completedBody,
    payload: 'analysis_complete',
  );

  @override
  Future<void> showAnalysisFailed() =>
      _show(title: failedTitle, body: failedBody, payload: 'analysis_failed');

  Future<void> _show({
    required String title,
    required String body,
    required String payload,
  }) async {
    if (!await initialize()) return;

    try {
      await _plugin.show(
        id: _nextNotificationId(),
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            visibility: NotificationVisibility.private,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBanner: true,
            presentList: true,
            presentSound: true,
            threadIdentifier: _channelId,
          ),
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBanner: true,
            presentList: true,
            presentSound: true,
            threadIdentifier: _channelId,
          ),
        ),
        payload: payload,
      );
    } on Exception {
      // Notifications are best-effort and must never change check-up state.
    }
  }

  bool get _isSupportedPlatform =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  int _nextNotificationId() {
    final timestampId = DateTime.now().millisecondsSinceEpoch.remainder(
      _maxNotificationId,
    );
    _lastNotificationId = timestampId > _lastNotificationId
        ? timestampId
        : (_lastNotificationId + 1).remainder(_maxNotificationId);
    return _lastNotificationId;
  }
}
