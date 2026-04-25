// notifications_page.dart
import 'package:alzajeltravel/controller/bookings_report/trip_detail/booking_detail.dart';
import 'package:alzajeltravel/controller/bookings_report/trip_detail/flight_detail.dart';
import 'package:alzajeltravel/controller/bookings_report/trip_detail/travelers_detail.dart';
import 'package:alzajeltravel/controller/notifications/notifications_controller.dart';
import 'package:alzajeltravel/model/contact_model.dart';
import 'package:alzajeltravel/utils/app_apis.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/widgets.dart';
import 'package:alzajeltravel/view/frame/issuing/issuing_page_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final TextEditingController _searchCtrl;
  late final ScrollController _scrollCtrl;

  // ✅ نُنشئ الكنترولر مرة واحدة حتى نقدر نستعمله في Listener
  late final NotificationsController _controller;

  @override
  void initState() {
    super.initState();

    _controller = NotificationsController();
    _searchCtrl = TextEditingController();
    _scrollCtrl = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;

    // ✅ نطلب المزيد قبل النهاية بقليل
    const threshold = 220.0;
    final pos = _scrollCtrl.position;

    if (pos.pixels >= pos.maxScrollExtent - threshold) {
      _controller.loadMore();
    }
  }

  /// تنسيق التاريخ مثل المطلوب: 17-فبراير-2026 8:22 م
  String formatNotificationDate(DateTime dt) {
    Jiffy.setLocale(AppVars.lang ?? 'en');
    return AppFuns.replaceArabicNumbers(
      Jiffy.parseFromDateTime(dt).format(pattern: 'd-MMMM-yyyy | h:mm a'),
    );
  }

  /// ✅ حسب طلبك: عربي فقط إذا AppVars.lang == "ar" غير ذلك إنجليزي
  String _pickLang({required String ar, required String en}) {
    final lang = (AppVars.lang ?? 'en').toLowerCase();
    if (lang == 'ar') return ar.isNotEmpty ? ar : en;
    return en.isNotEmpty ? en : ar;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationsController>(
      init: _controller,
      builder: (c) {
        return PopScope(
          canPop: false, // ✅ نحن نتحكم بالكامل بالرجوع
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;

            if (c.isSearchMode) {
              _searchCtrl.clear();
              c.closeSearch();
              FocusScope.of(context).unfocus();
              return;
            }

            Get.back();
          },

          child: SafeArea(
            top: false,
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
                      onRefresh: () => c.refreshNotifications(),
                      onSearch: () {
                        _searchCtrl.text = c.searchText;
                        _searchCtrl.selection = TextSelection.collapsed(
                          offset: _searchCtrl.text.length,
                        );
                        c.openSearch();
                      },
                    ),
              body: _buildBody(context, c),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, NotificationsController c) {
    // ✅ Pull to refresh يعمل في كل الحالات
    Future<void> onPullRefresh() async {
      await c.refreshNotifications();
    }

    // حالة Empty: نخليها قابلة للسحب (ListView بطفل واحد)
    if (c.visible.isEmpty) {
      return RefreshIndicator(
        onRefresh: onPullRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: _EmptyNotificationsView(
                title: (c.searchText.trim().isNotEmpty)
                    ? 'No results'.tr
                    : 'No notifications'.tr,
                subtitle: (c.searchText.trim().isNotEmpty)
                    ? 'Try different keywords'.tr
                    : 'Make a transfer or pay using your wallet to see notifications'
                          .tr,
              ),
            ),
          ],
        ),
      );
    }

    // ✅ Pagination: عنصر إضافي للتحميل (اختياري وخفيف)
    final itemCount = c.visible.length + (c.isLoadingMore ? 1 : 0);

    // حالة فيها بيانات: نفس ListView لكن داخل RefreshIndicator
    return RefreshIndicator(
      onRefresh: onPullRefresh,
      child: ListView.separated(
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 0, bottom: 8),
        itemCount: itemCount,
        separatorBuilder: (_, __) =>
            Divider(thickness: 1, color: Theme.of(context).dividerColor),
        itemBuilder: (context, index) {
          // ✅ Loader في آخر القائمة
          if (c.isLoadingMore && index == c.visible.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          final n = c.visible[index];

          final titleText = _pickLang(ar: n.titleAr, en: n.titleEn);
          final bodyText = _pickLang(ar: n.bodyAr, en: n.bodyEn);

          final dateText = formatNotificationDate(
            DateTime.fromMillisecondsSinceEpoch(n.createdAt),
          );

          final showDocIcon = (n.url != null && n.url!.isNotEmpty);

          goToIssuingPage() async {
            context.loaderOverlay.show();
            if (n.url == null || n.url!.isEmpty) {
              if (context.mounted) context.loaderOverlay.hide();
              return;
            }
            try {
              final insertId = n.url!.split("/").last;
              final response = await AppVars.api.get(
                AppApis.tripDetail + insertId,
              );

              final pnr = response['flight']['UniqueID'];
              final booking = BookingDetail.bookingDetail(response['booking']);
              final flight = FlightDetail.flightDetail(response['flight']);
              final travelers = TravelersDetail.travelersDetail(
                response['flight'],
                response['passengers'],
              );

              final contact = ContactModel.fromApiJson({
                'title': "MR",
                'first_name': booking.customerId.split("@").first,
                'last_name': "_",
                'email': booking.customerId,
                'phone': booking.mobileNo,
                'country_code': booking.countryCode,
                'nationality': "ye",
              });

              // Get.to(() => IssuingPage(offerDetail: flight, travelers: travelers, contact: contact, pnr: pnr, booking: booking));
              if (context.mounted) {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: IssuingPageWeb(
                    offerDetail: flight,
                    travelers: travelers,
                    contact: contact,
                    pnr: pnr,
                    booking: booking,
                    fromPage: "bookings_report",
                  ),
                  withNavBar: true, // ✅ يبقي الـ Bottom Nav ظاهر
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              }
            } catch (e) {
              // ممكن تعرض Dialog بدل print
              print("error: $e");
            }
            if (context.mounted) context.loaderOverlay.hide();
          }

          onTapNotification() async {
            if (n.url != null && n.url!.isNotEmpty) {
              if (n.url!.contains("http")) {
                AppFuns.openUrl(n.url!);
              } else if (n.url!.contains("api")) {
                goToIssuingPage();
              }
            }
            if (!n.isRead) {
              await c.markAsRead(n.id);
            }

            final route = (n.route ?? '').trim();
            if (route.isNotEmpty) {
              print("route: $route");
              // Get.toNamed(route, arguments: n.payload ?? {});
            }
          }

          return _NotificationTile(
            titleText: titleText,
            bodyText: bodyText,
            dateText: dateText,
            img: n.img,
            showDocIcon: showDocIcon,
            onDocTap: showDocIcon ? onTapNotification : null,
            onTap: onTapNotification,
          );
        },
      ),
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
      leading: BackButton(onPressed: onBack),
      centerTitle: false,
      title: Text('Notifications'.tr),
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
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 8, end: 4),
      child: Material(
        borderRadius: radius,
        color: cs.surfaceContainerHighest,
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
          ),
        ),
      ),
    );
  }
}

/// عنصر إشعار واحد مثل الصورة (نفس التصميم)
class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.titleText,
    required this.bodyText,
    required this.dateText,
    required this.img,
    required this.showDocIcon,
    this.onDocTap,
    this.onTap,
  });

  final String titleText;
  final String bodyText;
  final String dateText;
  final String? img;
  final bool showDocIcon;
  final VoidCallback? onDocTap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);

    final bodyStyle = Theme.of(context).textTheme.bodyMedium;
    final dateStyle = Theme.of(context).textTheme.bodyMedium;

    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surfaceContainerHighest,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (img != null && img!.isNotEmpty)
                CacheImg(img!, boxFit: BoxFit.cover, imgWidth: 80.0),
              if (img == null || img!.isEmpty) _CircleTypeIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titleText, style: titleStyle),
                    const SizedBox(height: 6),
                    Text(
                      bodyText,
                      style: bodyStyle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Text(dateText, style: dateStyle),
                  ],
                ),
              ),
              const SizedBox(width: 12),
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
                const SizedBox(width: 48),
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

/// شاشة “لا يوجد إشعارات”
class _EmptyNotificationsView extends StatelessWidget {
  const _EmptyNotificationsView({required this.title, required this.subtitle});

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
            Icon(
              Icons.notifications_none_rounded,
              size: 56,
              color: Theme.of(context).iconTheme.color,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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
