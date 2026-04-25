import 'dart:developer';

import 'package:alzajeltravel/controller/notifications/notifications_controller.dart';
import 'package:alzajeltravel/model/notification/notification_model.dart';
import 'package:alzajeltravel/repo/notification_local_repo.dart';
import 'package:alzajeltravel/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

const String _webVapidKey = String.fromEnvironment('FIREBASE_WEB_VAPID_KEY');

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class NotificationFCMService {
  static const String _tokenStorageKey = 'fcm_token';
  static final NotificationLocalRepo _repo = NotificationLocalRepo();

  RemoteMessage? _initialMessage;
  bool _inited = false;

  Future<void> initFCM() async {
    if (_inited) return;
    _inited = true;

    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await FirebaseMessaging.instance.getToken(
        vapidKey: _webVapidKey.isEmpty ? null : _webVapidKey,
      );
      await _saveToken(token);

      FirebaseMessaging.instance.onTokenRefresh.listen(_saveToken);

      _initialMessage = await FirebaseMessaging.instance.getInitialMessage();

      FirebaseMessaging.onMessage.listen((message) async {
        await handleRemoteMessage(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) async {
        await _handleOpen(message.data);
      });
    } catch (e, s) {
      log('NotificationFCMService web init error: $e', stackTrace: s);
    }
  }

  Future<void> handleInitialMessageAfterAppReady() async {
    final message = _initialMessage;
    if (message == null) return;
    _initialMessage = null;
    await _handleOpen(message.data);
  }

  static Future<void> handleRemoteMessage(RemoteMessage message) async {
    final model = _modelFromMessage(message);
    if (model.titleEn.isEmpty && model.bodyEn.isEmpty) return;

    await _repo.insertOrIgnore(
      id: model.id,
      titleAr: model.titleAr,
      bodyAr: model.bodyAr,
      titleEn: model.titleEn,
      bodyEn: model.bodyEn,
      img: model.img,
      url: model.url,
      route: model.route,
      payload: model.payload,
      createdAtMillis: model.createdAt,
    );

    await NotificationService.showLocalizedNotification(
      titleAr: model.titleAr,
      bodyAr: model.bodyAr,
      titleEn: model.titleEn,
      bodyEn: model.bodyEn,
      imageUrl: model.img,
      payload: model.payload?.map((key, value) {
        return MapEntry(key, value?.toString() ?? '');
      }),
    );

    if (Get.isRegistered<NotificationsController>()) {
      await Get.find<NotificationsController>().refreshNotifications();
    }
  }

  static NotificationModel _modelFromMessage(RemoteMessage message) {
    final data = Map<String, dynamic>.from(message.data);
    final notification = message.notification;

    data.putIfAbsent('title_en', () => notification?.title ?? 'Notification');
    data.putIfAbsent('body_en', () => notification?.body ?? '');
    data.putIfAbsent('title_ar', () => data['title_en']);
    data.putIfAbsent('body_ar', () => data['body_en']);

    return NotificationModel.fromFcmData(data, messageId: message.messageId);
  }

  static Future<void> _handleOpen(Map<String, dynamic> data) async {
    final id = data['id']?.toString();
    if (id != null && id.isNotEmpty) {
      await _repo.markAsRead(id);
    }

    final route = data['route']?.toString().trim();
    if (route != null && route.isNotEmpty) {
      Get.toNamed(route, arguments: data);
    }
  }

  static Future<void> _saveToken(String? token) async {
    if (token == null || token.isEmpty) return;
    debugPrint('fcm-token: $token');
    await GetStorage().write(_tokenStorageKey, token);
  }
}
