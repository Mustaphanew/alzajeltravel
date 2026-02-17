import 'dart:convert';

/// مودل الإشعار (Notification)
class NotificationModel {
  final String title;
  final String body;
  final DateTime createdAt;

  NotificationModel({
    required this.title,
    required this.body,
    required this.createdAt,
  });

  /// تحويل المودل إلى Map (مفيد عند التعامل مع API أو التخزين المحلي)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      // نخزن التاريخ بصيغة ISO String لتكون قياسية
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// تحويل المودل إلى JSON String
  String toJson() => json.encode(toMap());

  /// (اختياري لكن مفيد) إنشاء مودل من Map قادم من السيرفر
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      title: (map['title'] ?? '').toString(),
      body: (map['body'] ?? '').toString(),
      createdAt: DateTime.tryParse((map['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  /// (اختياري) إنشاء مودل من JSON String
  factory NotificationModel.fromJson(String source) =>
      NotificationModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
