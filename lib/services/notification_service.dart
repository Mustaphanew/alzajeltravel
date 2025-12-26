import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class NotificationService {
  static const String channelKey = 'alerts_channel';
  static const String channelGroupKey = 'alerts_group';

  /// تهيئة الحزمة والقناة + تسجيل المستمعات
  /// ملاحظة: على الويب لا تطلب الإذن هنا (خليه من زر)
  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      // على الويب: الأفضل null (بدون resource://)
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

          // على الويب عطّل/اتركها null
          playSound: !kIsWeb,
          soundSource: kIsWeb ? null : 'resource://raw/notify',
          icon: kIsWeb ? null : 'resource://drawable/ic_notify',
        ),
      ],
      channelGroups: [NotificationChannelGroup(channelGroupKey: channelGroupKey, channelGroupName: 'Alerts Group')],
      debug: true,
    );

    AwesomeNotifications().setListeners(
      onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod: NotificationController.onNotificationDisplayedMethod,
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onDismissActionReceivedMethod: NotificationController.onDismissedActionReceivedMethod,
    );

    // ❌ لا تطلب الإذن تلقائياً على الويب
    if (!kIsWeb) {
      await requestPermissionFromUser();
    }
  }

  /// استدعها من زر "تفعيل الإشعارات" (خصوصاً للويب)
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
    // على الويب: لو ما في إذن، لا تحاول ترسل إشعار (أفضل UX)
    if (kIsWeb) {
      final allowed = await AwesomeNotifications().isNotificationAllowed();
      if (!allowed) return;
    }

    final bool hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;
    final int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    final mergedPayload = <String, String>{
      if (payload != null) ...payload,
      'title': payload?['title'] ?? titleEn,
      'body': payload?['body'] ?? bodyEn,
    };

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: channelKey,
        title: titleEn,
        body: bodyEn,

        // على الويب: لا تضع icon resource://
        icon: kIsWeb ? null : 'resource://drawable/ic_notify',

        // الويب غالباً سيتجاهل Layouts المتقدمة، لكن لا بأس
        notificationLayout: hasImage ? NotificationLayout.BigPicture : NotificationLayout.BigText,
        bigPicture: hasImage ? imageUrl : null,
        largeIcon: hasImage ? imageUrl : null,
        hideLargeIconOnExpand: true,

        payload: mergedPayload,
      ),
      localizations: {
        'ar': NotificationLocalization(title: titleAr, body: bodyAr, buttonLabels: {'OPEN': 'فتح', 'SHARE': 'مشاركة', 'DISMISS': 'إلغاء'}),
        'en': NotificationLocalization(title: titleEn, body: bodyEn, buttonLabels: {'OPEN': 'Open', 'SHARE': 'Share', 'DISMISS': 'Cancel'}),
      },

      // ملاحظة: أزرار الإجراء قد لا تظهر في بعض المتصفحات على الويب
      actionButtons: [
        NotificationActionButton(key: 'OPEN', label: 'Open', actionType: ActionType.Default),
        NotificationActionButton(key: 'SHARE', label: 'Share', actionType: ActionType.Default),
        NotificationActionButton(key: 'DISMISS', label: 'Cancel', actionType: ActionType.DismissAction),
      ],
    );
  }

  static Future<void> handleInitialActionIfAny() async {
    final initial = await AwesomeNotifications().getInitialNotificationAction(removeFromActionEvents: true);
    if (initial != null) {
      await NotificationController.onActionReceivedMethod(initial);
    }
  }
}

class NotificationController {
  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(ReceivedNotification received) async {
    print('🛠 [CREATED] id=${received.id} title=${received.title}');
    print('🧩 [CREATED payload] ${received.payload}');
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification received) async {
    print('👀 [DISPLAYED] id=${received.id} body=${received.body}');
    print('🧩 [DISPLAYED payload] ${received.payload}');
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction action) async {
    final String key = action.buttonKeyPressed ?? '';
    final bool isBodyTap = key.isEmpty || key == 'DEFAULT';

    print('🖱️ [ACTION] key=${key.isEmpty ? '(body)' : key} type=${action.actionType}');
    print('🧩 [ACTION payload] ${action.payload}');

    if (key == 'SHARE') {
      final title = (action.title ?? '').trim();
      final body = (action.body ?? '').trim();

      String shareText;
      if (title.isNotEmpty && body.isNotEmpty) {
        shareText = '$title\n\n$body';
      } else if (title.isNotEmpty) {
        shareText = title;
      } else if (body.isNotEmpty) {
        shareText = body;
      } else {
        final pTitle = (action.payload?['title'] ?? '').trim();
        final pBody = (action.payload?['body'] ?? '').trim();
        shareText = [pTitle, pBody].where((s) => s.isNotEmpty).join('\n\n');
        if (shareText.isEmpty) shareText = 'No content to share';
      }

      final subject = title.isNotEmpty ? title : 'Share';
      await SharePlus.instance.share(ShareParams(text: shareText, subject: subject));
      return;
    }

    if (isBodyTap || key == 'OPEN') {
      final route = action.payload?['route'];
      if (route != null && route.isNotEmpty) {
        Get.toNamed(route, arguments: action.payload);
      }
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onDismissedActionReceivedMethod(ReceivedAction action) async {
    print('❌ [DISMISSED] id=${action.id}');
    print('🧩 [DISMISSED payload] ${action.payload}');
  }
}
