// notifications_controller.dart
import 'dart:async';
import 'package:alzajeltravel/model/notification/notification_model.dart';
import 'package:get/get.dart';


/// كلاس Debouncer لتأخير تنفيذ البحث (حتى ما يصير بحث مع كل حرف بشكل مزعج)
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
  /// كل الإشعارات (القائمة الأصلية)
  final List<NotificationModel> _all = [];

  /// الإشعارات المعروضة (بعد الفلترة/البحث)
  final List<NotificationModel> visible = [];

  /// حالة التحميل
  bool isLoading = false;

  /// نص البحث الحالي
  String searchText = '';

  /// هل نحن في وضع البحث؟
  bool isSearchMode = false;

  /// Debouncer للبحث
  final Debouncer _debouncer = Debouncer(milliseconds: 350);

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  @override
  void onClose() {
    _debouncer.dispose();
    super.onClose();
  }

  /// فتح وضع البحث (يغير شكل الـ AppBar فقط)
  void openSearch() {
    isSearchMode = true;
    update();
  }

  /// إغلاق وضع البحث + تصفير البحث وإرجاع القائمة كاملة
  void closeSearch() {
    isSearchMode = false;
    _clearSearchInternal(updateUi: true);
  }

  /// مسح نص البحث فقط (زر X)
  void clearSearch() {
    _clearSearchInternal(updateUi: true);
  }

  void _clearSearchInternal({required bool updateUi}) {
    searchText = '';
    _applySearchNow('');
    if (updateUi) update();
  }

  /// محاكاة جلب إشعارات من السيرفر مع تأخير ثانية
  Future<void> fetchNotifications() async {
    isLoading = true;
    update();

    await Future.delayed(const Duration(seconds: 1));

    _all
      ..clear()
      ..addAll(_buildDemoNotifications(count: 20));

    /// بعد الجلب نطبق البحث الحالي (لو المستخدم كان يبحث)
    _applySearchNow(searchText);

    isLoading = false;
    update();
  }

  /// عند تغيير المستخدم لنص البحث (يتم استدعاؤها من onChanged في TextField)
  void onSearchChanged(String value) {
    searchText = value;

    /// نستخدم Debouncer لتقليل عدد عمليات الفلترة
    _debouncer.run(() {
      _applySearchNow(searchText);
      update();
    });
  }

  /// تطبيق البحث فعلياً (فلترة)
  void _applySearchNow(String query) {
    final q = query.trim().toLowerCase();

    visible
      ..clear()
      ..addAll(
        q.isEmpty
            ? _all
            : _all.where((n) {
                final t = n.title.toLowerCase();
                final b = n.body.toLowerCase();
                return t.contains(q) || b.contains(q);
              }),
      );
  }

  /// ديمو: إنشاء إشعارات
  List<NotificationModel> _buildDemoNotifications({required int count}) {
    final now = DateTime.now();

    return List.generate(count, (i) {
      return NotificationModel(
        title: 'Notification ${i + 1}',
        body: 'This is demo notification body number ${i + 1}.',
        createdAt: now.subtract(Duration(minutes: i * 7)),
      );
    });
  }
}
