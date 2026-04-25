// notifications_controller.dart
import 'dart:async';

import 'package:alzajeltravel/model/db/db_helper.dart';
import 'package:alzajeltravel/model/notification/notification_model.dart';
import 'package:get/get.dart';

/// Debouncer لتأخير تنفيذ البحث
class Debouncer {
  Debouncer({required this.milliseconds});
  final int milliseconds;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

class NotificationsController extends GetxController {
  static const String _table = 'notifications';

  final DbHelper _db = DbHelper();

  /// القائمة الأصلية
  final List<NotificationModel> _all = [];

  /// القائمة المعروضة بعد البحث
  final List<NotificationModel> visible = [];

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;

  int unreadCount = 0;

  String searchText = '';
  bool isSearchMode = false;

  final Debouncer _debouncer = Debouncer(milliseconds: 350);

  final int pageSize;
  int _offset = 0;

  NotificationsController({this.pageSize = 30});

  @override
  void onInit() {
    super.onInit();
    fetchFirstPage();
  }

  @override
  void onClose() {
    _debouncer.dispose();
    super.onClose();
  }

  // -------------------- Search UI state --------------------

  void openSearch() {
    isSearchMode = true;
    update();
  }

  void closeSearch() {
    isSearchMode = false;
    _clearSearchInternal(updateUi: true);
  }

  void clearSearch() {
    _clearSearchInternal(updateUi: true);
  }

  void _clearSearchInternal({required bool updateUi}) {
    searchText = '';
    _applySearchNow('');
    if (updateUi) update();
  }

  void onSearchChanged(String value) {
    searchText = value;
    _debouncer.run(() {
      _applySearchNow(searchText);
      update();
    });
  }

  void _applySearchNow(String query) {
    final q = query.trim().toLowerCase();

    visible
      ..clear()
      ..addAll(
        q.isEmpty
            ? _all
            : _all.where((n) {
                final tAr = n.titleAr.toLowerCase();
                final tEn = n.titleEn.toLowerCase();
                final bAr = n.bodyAr.toLowerCase();
                final bEn = n.bodyEn.toLowerCase();

                return tAr.contains(q) ||
                    tEn.contains(q) ||
                    bAr.contains(q) ||
                    bEn.contains(q);
              }),
      );
  }

  // -------------------- Fetch from DB --------------------

  Future<void> fetchFirstPage() async {
    _offset = 0;
    hasMore = true;

    isLoading = true;
    update();

    try {
      final items = await _fetchPage(limit: pageSize, offset: _offset);

      _all
        ..clear()
        ..addAll(items);

      _offset += items.length;
      hasMore = items.length == pageSize;

      await _updateUnreadCount();

      _applySearchNow(searchText);
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> refreshNotifications() async {
    print('refreshNotifications');
    await fetchFirstPage();
  }

  /// استدعها عند نهاية الـ Scroll لعمل Pagination
  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore || isLoading) return;

    isLoadingMore = true;
    update();

    try {
      final items = await _fetchPage(limit: pageSize, offset: _offset);

      _all.addAll(items);

      _offset += items.length;
      hasMore = items.length == pageSize;

      await _updateUnreadCount();

      _applySearchNow(searchText);
    } finally {
      isLoadingMore = false;
      update();
    }
  }

  Future<List<NotificationModel>> _fetchPage({
    required int limit,
    required int offset,
  }) async {
    final rows = await _db.rawSelect(
      sql:
          '''
        SELECT *
        FROM $_table
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?;
      ''',
      params: [limit, offset],
    );

    return rows.map((r) => NotificationModel.fromDbMap(r)).toList();
  }

  Future<void> _updateUnreadCount() async {
    unreadCount = await _db.countRows(table: _table, condition: 'is_read = 0');
  }

  // -------------------- Actions --------------------

  Future<void> markAsRead(String id) async {
    await _db.update(
      table: _table,
      obj: {'is_read': 1},
      condition: 'id = ?',
      conditionParams: [id],
    );

    // تحديث القائمة في الذاكرة بدون إعادة تحميل كاملة
    _replaceInMemoryReadFlag(id, true);
    await _updateUnreadCount();
    _applySearchNow(searchText);
    update();
  }

  Future<void> deleteNotification(String id) async {
    await _db.delete(table: _table, condition: 'id = ?', conditionParams: [id]);

    _all.removeWhere((e) => e.id == id);
    _applySearchNow(searchText);
    await _updateUnreadCount();
    update();
  }

  Future<void> clearAll() async {
    await _db.execute(sql: 'DELETE FROM $_table;');

    _all.clear();
    visible.clear();
    unreadCount = 0;
    update();
  }

  NotificationModel _copyWithRead(NotificationModel n, bool read) {
    return NotificationModel(
      id: n.id,
      titleAr: n.titleAr,
      bodyAr: n.bodyAr,
      titleEn: n.titleEn,
      bodyEn: n.bodyEn,
      img: n.img,
      url: n.url,
      route: n.route,
      payload: n.payload,
      isRead: read,
      createdAt: n.createdAt,
    );
  }

  void _replaceInMemoryReadFlag(String id, bool read) {
    final idx = _all.indexWhere((e) => e.id == id);
    if (idx != -1) {
      _all[idx] = _copyWithRead(_all[idx], read);
    }

    final vIdx = visible.indexWhere((e) => e.id == id);
    if (vIdx != -1) {
      visible[vIdx] = _copyWithRead(visible[vIdx], read);
    }
  }
}
