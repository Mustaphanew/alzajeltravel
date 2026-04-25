import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:alzajeltravel/model/db/db_helper.dart';
import 'package:alzajeltravel/utils/app_funs.dart';

class NotificationService {
  static const String channelKey = 'alerts_channel';
  static const String channelGroupKey = 'alerts_group';

  static bool _inited = false;
  static bool _backgroundInited = false;

  static Future<void> init() async {
    if (_inited) return;
    _inited = true;

    await _initializeAwesome(debug: true);

    AwesomeNotifications().setListeners(
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayedMethod,
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onDismissActionReceivedMethod:
          NotificationController.onDismissedActionReceivedMethod,
    );

    if (!kIsWeb) {
      await requestPermissionFromUser();
    }
  }

  static Future<void> initForBackground() async {
    if (_backgroundInited) return;
    _backgroundInited = true;
    await _initializeAwesome(debug: false);
  }

  static Future<void> _initializeAwesome({required bool debug}) async {
    await AwesomeNotifications().initialize(
      kIsWeb ? null : 'resource://drawable/ic_notify',
      [
        NotificationChannel(
          channelGroupKey: channelGroupKey,
          channelKey: channelKey,
          channelName: 'Alerts',
          channelDescription: 'Channel for app alerts',
          importance: NotificationImportance.High,
          channelShowBadge: true,
          defaultColor: const Color(0xffe7b245),
          ledColor: Colors.white,
          playSound: !kIsWeb,
          icon: kIsWeb ? null : 'resource://drawable/ic_notify',
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: channelGroupKey,
          channelGroupName: 'Alerts Group',
        ),
      ],
      debug: debug,
    );
  }

  static Future<void> requestPermissionFromUser() async {
    final allowed = await AwesomeNotifications().isNotificationAllowed();
    if (!allowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  static Future<void> showLocalizedNotification({
    required String titleAr,
    required String bodyAr,
    required String titleEn,
    required String bodyEn,
    String? imageUrl,
    Map<String, String>? payload,
  }) async {
    if (kIsWeb) {
      final allowed = await AwesomeNotifications().isNotificationAllowed();
      if (!allowed) return;
    }

    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;
    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    final mergedPayload = <String, String>{
      if (payload != null) ...payload,
      'title_ar': titleAr,
      'body_ar': bodyAr,
      'title_en': titleEn,
      'body_en': bodyEn,
      'title': payload?['title'] ?? titleEn,
      'body': payload?['body'] ?? bodyEn,
    };

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: channelKey,
        title: titleEn,
        body: bodyEn,
        icon: kIsWeb ? null : 'resource://drawable/ic_notify',
        notificationLayout: hasImage
            ? NotificationLayout.BigPicture
            : NotificationLayout.BigText,
        bigPicture: hasImage ? imageUrl : null,
        largeIcon: hasImage ? imageUrl : null,
        hideLargeIconOnExpand: true,
        payload: mergedPayload,
      ),
      localizations: {
        'ar': NotificationLocalization(title: titleAr, body: bodyAr),
        'en': NotificationLocalization(title: titleEn, body: bodyEn),
      },
    );
  }

  static Future<void> handleInitialActionIfAny() async {
    final initial = await AwesomeNotifications().getInitialNotificationAction(
      removeFromActionEvents: true,
    );
    if (initial != null) {
      await NotificationController.onActionReceivedMethod(initial);
    }
  }
}

class NotificationController {
  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification received,
  ) async {}

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification received,
  ) async {}

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction action) async {
    final payload = action.payload ?? const <String, String>{};
    final id = payload['id']?.trim();

    if (id != null && id.isNotEmpty) {
      try {
        await DbHelper().update(
          table: 'notifications',
          obj: {'is_read': 1},
          condition: 'id = ?',
          conditionParams: [id],
        );
      } catch (_) {}
    }

    final route = payload['route']?.trim();
    if (route != null && route.isNotEmpty) {
      Get.toNamed(route, arguments: payload);
      return;
    }

    final url = payload['url']?.trim();
    if (url != null && url.startsWith('http')) {
      AppFuns.openUrl(url);
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onDismissedActionReceivedMethod(
    ReceivedAction action,
  ) async {}
}
