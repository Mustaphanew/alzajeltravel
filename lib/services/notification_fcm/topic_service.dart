import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class TopicService {
  static Future<void> subscribe(String topic) async {
    if (kIsWeb) {
      log('FCM topics are not supported on web clients.');
      return;
    }

    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      log('Subscribed to FCM topic: $topic');
    } catch (e, s) {
      log('FCM topic subscribe failed: $e', stackTrace: s);
    }
  }

  static Future<void> unsubscribe(String topic) async {
    if (kIsWeb) return;

    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      log('Unsubscribed from FCM topic: $topic');
    } catch (e, s) {
      log('FCM topic unsubscribe failed: $e', stackTrace: s);
    }
  }
}
