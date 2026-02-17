// notifications_page.dart
import 'package:alzajeltravel/controller/notifications/notifications_controller.dart';
import 'package:alzajeltravel/model/notification/notification_model.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';


class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// تنسيق التاريخ مثل المطلوب: 17-فبراير-2026 8:22 م
  String formatNotificationDate(DateTime dt) {
    // d = اليوم بدون صفر
    // MMMM = اسم الشهر كامل
    // yyyy = السنة
    // h:mm = وقت 12 ساعة بدون صفر
    // a = AM/PM (في العربي تصير ص/م)
    Jiffy.setLocale(AppVars.lang??'en');
    return AppFuns.replaceArabicNumbers(Jiffy.parseFromDateTime(dt).format(pattern: 'd-MMMM-yyyy | h:mm a'));
  }
  
  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationsController>(
      init: NotificationsController(),
      builder: (c) {
        return WillPopScope(
          // لو المستخدم ضغط زر الرجوع وهو داخل وضع البحث، نخرج من البحث بدل ما نطلع من الصفحة
          onWillPop: () async {
            if (c.isSearchMode) {
              _searchCtrl.clear();
              c.closeSearch();
              FocusScope.of(context).unfocus(); // إغلاق الكيبورد
              return false;
            }
            return true;
          },
          child: Scaffold(
            appBar: c.isSearchMode
                ? _SearchAppBar(
                    controller: _searchCtrl,
                    onBack: () {
                      _searchCtrl.clear();
                      c.closeSearch();
                      FocusScope.of(context).unfocus();
                    },
                    onClear: () {
                      _searchCtrl.clear();
                      c.clearSearch();
                    },
                    onChanged: c.onSearchChanged,
                  )
                : _NormalAppBar(
                    onBack: () => Get.back(),
                    onRefresh: () => c.fetchNotifications(),
                    onSearch: () {
                      // ندخل وضع البحث + نجهّز حقل الإدخال
                      _searchCtrl.text = c.searchText;
                      _searchCtrl.selection = TextSelection.collapsed(
                        offset: _searchCtrl.text.length,
                      );
                      c.openSearch();
                    },
                  ),
            body: _buildBody(context, c),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, NotificationsController c) {
    // حسب طلبك: قبل ظهور البيانات (loading) أو إذا ما فيه بيانات => نفس شاشة الـ Empty
    if (c.visible.isEmpty) {
      return _EmptyNotificationsView(
        // لو المستخدم يكتب بحث وما فيه نتائج، نغير النص قليلاً (اختياري)
        title: (c.searchText.trim().isNotEmpty)
            ? 'No results'.tr
            : 'No notifications'.tr,
        subtitle: (c.searchText.trim().isNotEmpty)
            ? 'Try different keywords'.tr
            : 'Make a transfer or pay using your wallet to see notifications'.tr,
      );
    }

    // في حال فيه بيانات، نعرض القائمة مثل الصورة (Dividers بين العناصر)
    return ListView.separated(
      padding: const EdgeInsets.only(top: 0, bottom: 8),
      itemCount: c.visible.length,
      separatorBuilder: (_, __) => Divider(
        // height: 1,
        thickness: 1,
        color: Theme.of(context).dividerColor,
      ),
      itemBuilder: (context, index) {
        final n = c.visible[index];

        // ملاحظة: أيقونة المستند في الصورة تظهر لبعض العناصر فقط.
        // بما أن المودل عندك ما فيه حقل يدل على ذلك، خليتها “ديمو” حسب index.
        final showDocIcon = index.isOdd;

        return _NotificationTile(
          notification: n,
          dateText: formatNotificationDate(n.createdAt),
          showDocIcon: showDocIcon,
          onDocTap: showDocIcon
              ? () {
                  // هنا لاحقاً تفتح تفاصيل/إيصال.. الخ
                }
              : null,
          onTap: () {
            // هنا لو تحب عند الضغط على العنصر نفسه
          },
        );
      },
    );
  }
}

/// AppBar العادي (عنوان + تحديث + بحث)
class _NormalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _NormalAppBar({
    required this.onBack,
    required this.onRefresh,
    required this.onSearch,
  });

  final VoidCallback onBack;
  final VoidCallback onRefresh;
  final VoidCallback onSearch;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // زر رجوع (direction-aware)
      leading: BackButton(onPressed: onBack),

      centerTitle: false,
      title: Text('Notifications'.tr),

      // أزرار الجهة الأخرى: تحديث + بحث (تنعكس تلقائياً RTL/LTR)
      actions: [
        IconButton(
          tooltip: 'Search'.tr,
          onPressed: onSearch,
          icon: const Icon(Icons.search_rounded),
        ),
        _RefreshChip(onTap: onRefresh),
        const SizedBox(width: 8),
      ],
    );
  }
}

/// زر تحديث بشكل كبسولة مثل الصورة
class _RefreshChip extends StatelessWidget {
  const _RefreshChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 8, end: 4),
      child: Material(
        borderRadius: radius,
        color: Colors.white,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Refresh'.tr),
                const SizedBox(width: 8),
                const Icon(Icons.refresh_rounded, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// AppBar البحث (Back داخل الشريط + TextField + X Clear)
class _SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SearchAppBar({
    required this.controller,
    required this.onBack,
    required this.onClear,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onBack;
  final VoidCallback onClear;
  final ValueChanged<String> onChanged;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
        child: TextField(
          controller: controller,
          autofocus: true,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            prefixIcon: IconButton(
              tooltip: 'Back'.tr,
              onPressed: onBack,
              icon: const BackButtonIcon(),
            ),
            suffixIcon: IconButton(
              tooltip: 'Clear'.tr,
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded),
            ),
            hintText: 'Search'.tr,
            border: InputBorder.none,
            isDense: true,
            // contentPadding: const EdgeInsetsDirectional.fromSTEB(
            //   12,
            //   12,
            //   12,
            //   12,
            // ),
          ),
        ),
      ),
    );
  }
}

/// عنصر إشعار واحد مثل الصورة (أيقونة دائرية + title/body/date + Divider بين العناصر)
class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.dateText,
    required this.showDocIcon,
    this.onDocTap,
    this.onTap,
  });

  final NotificationModel notification;
  final String dateText;
  final bool showDocIcon;
  final VoidCallback? onDocTap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        );

    final bodyStyle = Theme.of(context).textTheme.bodyMedium;
    final dateStyle = Theme.of(context).textTheme.bodyMedium;

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // أيقونة دائرية على الطرف (تنعكس تلقائياً RTL/LTR لأنها أول عنصر في Row)
              _CircleTypeIcon(),
      
              const SizedBox(width: 12),
      
              // المحتوى النصي
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.title, style: titleStyle),
                    const SizedBox(height: 6),
      
                    Text(
                      notification.body,
                      style: bodyStyle,
                      // تقدر تلغي maxLines لو تحب يظهر كامل
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
      
                    Text(dateText, style: dateStyle),
                  ],
                ),
              ),
      
              const SizedBox(width: 12),
      
              // أيقونة المستند (اختيارية) على الطرف الآخر
              // وضعناها بأسفل العنصر تقريباً مثل الصورة
              if (showDocIcon)
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 44),
                  child: IconButton(
                    onPressed: onDocTap,
                    icon: const Icon(Icons.description_outlined),
                    tooltip: 'Details'.tr,
                  ),
                )
              else
                const SizedBox(width: 48), // مساحة ثابتة للحفاظ على شكل متوازن
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleTypeIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: const AlwaysStoppedAnimation(0.1),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.sync_alt_rounded),
      ),
    );
  }
}

/// شاشة “لا يوجد إشعارات” مثل الصورة (وتستخدم أيضاً قبل ظهور البيانات)
class _EmptyNotificationsView extends StatelessWidget {
  const _EmptyNotificationsView({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة بسيطة (لو تريد نفس أيقونة الصورة تماماً استخدم asset)
            Icon(
              Icons.notifications_none_rounded,
              size: 56,
              color: Theme.of(context).iconTheme.color,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
