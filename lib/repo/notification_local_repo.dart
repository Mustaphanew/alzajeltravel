import 'dart:convert';

import 'package:alzajeltravel/model/db/db_helper.dart';

class NotificationLocalRepo {
  static const String table = 'notifications';

  /// يحفظ إشعار جديد (بدون تكرار)
  /// يرجع true إذا تم الإدخال، false إذا كان موجود مسبقًا
  Future<bool> insertOrIgnore({
    required String id,
    required String titleAr,
    required String bodyAr,
    required String titleEn,
    required String bodyEn,
    String? img,
    String? url,
    String? route,
    Map<String, dynamic>? payload,
    int? createdAtMillis,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final obj = <String, Object?>{
      'id': id,
      'title_ar': titleAr,
      'body_ar': bodyAr,
      'title_en': titleEn,
      'body_en': bodyEn,
      'img': img,
      'url': url,
      'route': route,
      'payload': payload == null ? null : jsonEncode(payload),
      'is_read': 0,
      'created_at': createdAtMillis ?? now,
    };

    // احذف القيم null حتى لا تخزن "null"
    obj.removeWhere((k, v) => v == null);

    final inserted = await DbHelper().insertOrIgnore(table: table, obj: obj);
    return inserted == 1;
  }

  /// جلب الإشعارات (Pagination)
  Future<List<Map<String, Object?>>> list({
    int limit = 30,
    int offset = 0,
  }) async {
    return DbHelper().rawSelect(
      sql:
          '''
        SELECT *
        FROM $table
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?;
      ''',
      params: [limit, offset],
    );
  }

  /// عدد غير المقروء
  Future<int> unreadCount() async {
    return DbHelper().countRows(table: table, condition: 'is_read = 0');
  }

  /// تعليم إشعار كمقروء
  Future<int> markAsRead(String id) async {
    return DbHelper().update(
      table: table,
      obj: {'is_read': 1},
      condition: 'id = ?',
      conditionParams: [id],
    );
  }

  /// تعليم الكل كمقروء
  Future<int> markAllAsRead() async {
    return DbHelper().execute(
      sql: 'UPDATE $table SET is_read = 1 WHERE is_read = 0;',
    );
  }

  /// حذف إشعار
  Future<int> deleteById(String id) async {
    return DbHelper().delete(
      table: table,
      condition: 'id = ?',
      conditionParams: [id],
    );
  }

  /// حذف الكل
  Future<int> clearAll() async {
    return DbHelper().execute(sql: 'DELETE FROM $table;');
  }
}
