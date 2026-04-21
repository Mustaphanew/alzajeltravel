import 'package:alzajeltravel/controller/airline_controller.dart';
import 'package:alzajeltravel/controller/bookings_report/bookings_report_controller.dart';
import 'package:alzajeltravel/controller/bookings_report/trip_detail/booking_detail.dart';
import 'package:alzajeltravel/controller/bookings_report/trip_detail/flight_detail.dart';
import 'package:alzajeltravel/controller/bookings_report/trip_detail/travelers_detail.dart';
import 'package:alzajeltravel/model/bookings_report/bookings_report_model.dart';
import 'package:alzajeltravel/model/contact_model.dart';
import 'package:alzajeltravel/utils/app_apis.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/enums.dart';
import 'package:alzajeltravel/utils/widgets.dart';
import 'package:alzajeltravel/view/bookings_report/search_and_filter.dart';
import 'package:alzajeltravel/view/frame/issuing/issuing_page.dart';
import 'package:alzajeltravel/view/frame/issuing/issuing_page_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:jiffy/jiffy.dart';
import 'dart:convert';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class BookingsReportPage extends StatefulWidget {
  const BookingsReportPage({super.key});

  @override
  State<BookingsReportPage> createState() => _BookingsReportPageState();
}

class _BookingsReportPageState extends State<BookingsReportPage> {
  final AirlineController airlineController = Get.isRegistered<AirlineController>()
      ? Get.find<AirlineController>()
      : Get.put(AirlineController(), permanent: true);

  late final BookingsReportController c;

  final ExpansibleController _filterTileController = ExpansibleController();

  SearchAndFilterState? parentState;

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<BookingsReportController>()) {
      c = Get.find<BookingsReportController>();
    } else {
      c = Get.put(BookingsReportController());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _filterTileController.collapse();

      // ✅ default: All + untilDay(today)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final from = DateTime(2010, 1, 1);

      parentState = SearchAndFilterState(
        applied: true,
        status: BookingStatus.all,
        dateFrom: from,
        dateTo: today,
        keyword: '',
        dateField: ReportDateField.createdAt,
        period: ReportPeriod.untilDay,
      );
      setState(() {});

      context.loaderOverlay.show();
      await c.search(status: BookingStatus.all, dateFrom: from, dateTo: today, fullDetails: 0);
      if (mounted) context.loaderOverlay.hide();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final String statusLabel = (parentState?.status == BookingStatus.all)
        ? 'All'.tr
        : (parentState?.status?.toJson() ?? '').tr;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1430) : const Color(0xFFFAF6F1),
      appBar: AppBar(
        title: Text(
          'Bookings Report'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: AppConsts.xlg,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: AppConsts.primaryColor,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: AppConsts.xlg,
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        shape: Border(
          bottom: BorderSide(
            color: AppConsts.secondaryColor.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121A38) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppConsts.secondaryColor.withValues(alpha: isDark ? 0.35 : 0.28),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppConsts.primaryColor.withValues(alpha: isDark ? 0.30 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                controller: _filterTileController,
                initiallyExpanded: false,
                maintainState: true,
                tilePadding: const EdgeInsetsDirectional.only(start: 16, end: 12),
                iconColor: AppConsts.secondaryColor,
                collapsedIconColor: AppConsts.secondaryColor,
                shape: const RoundedRectangleBorder(),
                collapsedShape: const RoundedRectangleBorder(),
                backgroundColor: Colors.transparent,
                collapsedBackgroundColor: Colors.transparent,
                title: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppConsts.secondaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: AppConsts.lg,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                            letterSpacing: 0.2,
                          ),
                          children: [
                            TextSpan(text: 'Search and Filter'.tr + ' '),
                            TextSpan(
                              text: '($statusLabel)',
                              style: const TextStyle(
                                color: AppConsts.secondaryColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                onExpansionChanged: (expanded) {
                  AppFuns.hideKeyboard();
                  if (!expanded) setState(() {});
                },
                children: [
                  SearchAndFilter(
                    tileController: _filterTileController,
                    onSearch: (state) async {
                      parentState = state;
                      setState(() {});

                      if (state.status == null) return;

                      context.loaderOverlay.show();
                      await c.search(status: state.status!, dateFrom: state.dateFrom, dateTo: state.dateTo, fullDetails: 0);
                      if (context.mounted) context.loaderOverlay.hide();
                    },
                  ),
                ],
              ),
            ),
          ),
          const Expanded(child: _BookingsReportList()),
        ],
      ),
    );
  }
}

class _BookingsReportList extends StatefulWidget {
  const _BookingsReportList();

  @override
  State<_BookingsReportList> createState() => _BookingsReportListState();
}

class _BookingsReportListState extends State<_BookingsReportList> with AutomaticKeepAliveClientMixin {
  late final ScrollController _scroll;
  late final BookingsReportController c;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    c = Get.find<BookingsReportController>();
    _scroll = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    final threshold = 200.0;
    final pos = _scroll.position;

    final canLoadMore = c.searched && !c.loading && !c.loadingMore && c.hasMore;

    if (canLoadMore && pos.pixels >= pos.maxScrollExtent - threshold) {
      c.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GetBuilder<BookingsReportController>(
      builder: (controller) {
        // ✅ لا نعرض شيء قبل أول Search
        if (!controller.searched) {
          return const SizedBox.shrink();
        }

        if (controller.loading && controller.items.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (controller.error != null && controller.items.isEmpty) {
          return _ErrorView(message: controller.error!, onRetry: () => controller.refreshData());
        }

        if (controller.items.isEmpty) {
          return _EmptyView(onRefresh: () => controller.refreshData());
        }

        final showLoadMoreButton = !controller.loadingMore && !controller.loading && (controller.items.length >= controller.limit);

        final visibleItems = controller.items.where((e) => e.flightStatus != BookingStatus.pending).toList();

        return RefreshIndicator(
          onRefresh: () => controller.refreshData(),
          child: ListView.separated(
            controller: _scroll,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            itemCount: visibleItems.length + 1,
            itemBuilder: (context, index) {
              if (index < visibleItems.length) {
                return ReportCard(
                  item: visibleItems[index],
                );
              }

              if (controller.loadingMore) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [const CircularProgressIndicator.adaptive(), const SizedBox(height: 10), Text("Loading more".tr + " ...")],
                  ),
                );
              }

              if (controller.hasMore) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(onPressed: controller.loadMore, child: Text("Load more".tr)),
                  ),
                );
              }

              return Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text("No more results".tr));
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
          ),
        );
      
      
      },
    );
  }
}

class ReportCard extends StatefulWidget {
  final BookingReportItem item;
  const ReportCard({super.key, required this.item});

  @override
  State<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
  bool showCreatedAtDetail = false;
  bool showCancelledDetail = false;
  bool showVoidedDetail = false;
  bool showTimeDeadlineDetail = false;
  bool showIssueOnDetail = false;

  BookingReportItem get item => widget.item;

  BookingsReportController bookingsReportController = Get.isRegistered<BookingsReportController>() ? 
  Get.find<BookingsReportController>() : 
  Get.put(BookingsReportController());


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final created = _formatDateTime(item.createdAt);
    final createdDetail = _formatDateTimeDetail(item.createdAt);

    final cancelled = item.cancelOn != null ? _formatDate(item.cancelOn!) : null;
    final cancelledDetail = item.cancelOn != null ? _formatDateTimeDetail(item.cancelOn!) : null;

    final voided = item.voidOn != null ? _formatDate(item.voidOn!) : null;
    final voidedDetail = item.voidOn != null ? _formatDateTimeDetail(item.voidOn!) : null;

    final travel = _formatDate(item.travelDate);

    final timeDeadline = item.timeDeadline != null ? _formatDate(item.timeDeadline!) : null;
    final timeDeadlineDetail = item.timeDeadline != null ? _formatDateTimeDetail(item.timeDeadline!) : null;

    final issueOn = item.issueOn != null ? _formatDate(item.issueOn!) : null;
    final issueOnDetail = item.issueOn != null ? _formatDateTimeDetail(item.issueOn!) : null;

    final statusVisual = _statusVisuals(item.flightStatus);

    goToIssuingPage() async {
        context.loaderOverlay.show();
        try {
          final insertId = item.tripApi.split("/").last;
          final response = await AppVars.api.get(AppApis.tripDetail + insertId);

          final pnr = response['flight']['UniqueID'];
          final booking = BookingDetail.bookingDetail(response['booking']);
          final flight = FlightDetail.flightDetail(response['flight']);
          final travelers = TravelersDetail.travelersDetail(response['flight'], response['passengers']);

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
          if(context.mounted) {
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

    final isRtl = AppVars.lang == 'ar';
    final planeQuarterTurns = isRtl ? 3 : 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppConsts.primaryColor.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ━━━━━━ ❶ Navy ribbon: booking id + amount + PNR/travel date ━━━━━━
              _buildRibbon(cs, travel),

              // ━━━━━━ ❷ Route ━━━━━━
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: _buildRoute(cs, planeQuarterTurns),
              ),

              // ━━━━━━ ❸ Info row: conditional issue-on / deadline / cancel / void ━━━━━━
              if (item.flightStatus == BookingStatus.preBooking ||
                  item.flightStatus == BookingStatus.confirmed ||
                  item.flightStatus == BookingStatus.canceled ||
                  item.flightStatus == BookingStatus.expiry ||
                  item.flightStatus == BookingStatus.voided ||
                  item.flightStatus == BookingStatus.voide)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _buildDatesRow(
                    cs,
                    timeDeadline: timeDeadline,
                    timeDeadlineDetail: timeDeadlineDetail,
                    issueOn: issueOn,
                    issueOnDetail: issueOnDetail,
                    cancelled: cancelled,
                    cancelledDetail: cancelledDetail,
                    voided: voided,
                    voidedDetail: voidedDetail,
                  ),
                ),

              // Divider
              Divider(height: 1, thickness: 1, color: cs.outlineVariant.withValues(alpha: 0.4)),

              // ━━━━━━ ❹ Passengers + Status chip ━━━━━━
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Row(
                  children: [
                    _paxChip(FontAwesomeIcons.solidUser, item.adult, const Color(0xFF436DF4)),
                    const SizedBox(width: 10),
                    _paxChip(FontAwesomeIcons.child, item.child, const Color(0xFF438559)),
                    const SizedBox(width: 10),
                    _paxChip(FontAwesomeIcons.babyCarriage, item.inf, const Color(0xFFC74649)),
                    const Spacer(),
                    _statusChip(statusVisual),
                  ],
                ),
              ),

              // ━━━━━━ ❺ Created-at + CTA ━━━━━━
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 14, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => setState(() => showCreatedAtDetail = !showCreatedAtDetail),
                      child: Text(
                        showCreatedAtDetail ? createdDetail : created,
                        style: TextStyle(
                          fontSize: AppConsts.sm,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // زرّ "تفاصيل الرحلة" — خلفية Navy + نص أبيض عريض + سهم ذهبي
                    Material(
                      color: AppConsts.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: goToIssuingPage,
                        splashColor: AppConsts.secondaryColor.withValues(alpha: 0.20),
                        highlightColor: AppConsts.secondaryColor.withValues(alpha: 0.08),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Flight Details'.tr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: AppConsts.normal,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                isRtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                                size: 16,
                                color: AppConsts.secondaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Helpers
  // ══════════════════════════════════════════════════════════════

  Widget _buildRibbon(ColorScheme cs, String travel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConsts.primaryColor,
            AppConsts.primaryColor.withValues(alpha: 0.92),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: json.encode(item.toJson())));
                  Fluttertoast.showToast(msg: "Booking copied to clipboard".tr);
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.copy_rounded, size: 16, color: Colors.white.withValues(alpha: 0.7)),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  item.bookingId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppConsts.lg,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppConsts.secondaryColor,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  AppFuns.priceWithCoin(item.totalAmount, item.currency),
                  style: const TextStyle(
                    color: AppConsts.primaryColor,
                    fontSize: AppConsts.normal,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'PNR'.tr,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: AppConsts.sm,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                item.pnr.isEmpty ? '—' : item.pnr,
                style: const TextStyle(
                  color: AppConsts.secondaryColor,
                  fontSize: AppConsts.normal,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.calendar_month_rounded, size: 13, color: Colors.white.withValues(alpha: 0.7)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  travel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: AppConsts.sm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoute(ColorScheme cs, int planeQuarterTurns) {
    final nameStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: AppConsts.lg,
      color: cs.onSurface,
    );
    final codeStyle = TextStyle(
      fontSize: AppConsts.sm,
      color: cs.onSurfaceVariant,
      letterSpacing: 1,
    );

    Widget cityCol({
      required String name,
      required String code,
      required CrossAxisAlignment align,
      required TextAlign textAlign,
    }) {
      // ConstrainedBox يسمح للنص أن يأخذ عرضه الطبيعي حتى 140px،
      // فوق ذلك يُقتطع بـ ellipsis ويبقى تخطيط البطاقة مستقرًّا.
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 140),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: align,
          children: [
            Text(
              name,
              textAlign: textAlign,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: nameStyle,
            ),
            Text(code, textAlign: textAlign, style: codeStyle),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ───── المدينة الأولى عند الطرف ─────
        cityCol(
          name: item.origin.name[AppVars.lang] ?? '',
          code: item.origin.code,
          align: CrossAxisAlignment.start,
          textAlign: TextAlign.start,
        ),

        const SizedBox(width: 8),
        _endDot(),

        // الخطّ الأول: مرن، يبدأ ذهبيًّا عند النقطة ويتلاشى نحو الطائرة
        Expanded(child: _gradientLine(fromStart: true)),

        // الطائرة (أو sync_alt للـ round-trip)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: (item.journeyType == JourneyType.roundTrip)
              ? const Icon(Icons.sync_alt_rounded, size: 22, color: AppConsts.secondaryColor)
              : RotatedBox(
                  quarterTurns: planeQuarterTurns,
                  child: const Icon(
                    Icons.flight_rounded,
                    size: 22,
                    color: AppConsts.secondaryColor,
                  ),
                ),
        ),

        // الخطّ الثاني: يتلاشى من الطائرة ويكتمل عند النقطة
        Expanded(child: _gradientLine(fromStart: false)),

        _endDot(),
        const SizedBox(width: 8),

        // ───── المدينة الثانية عند الطرف ─────
        cityCol(
          name: item.destination.name[AppVars.lang] ?? '',
          code: item.destination.code,
          align: CrossAxisAlignment.end,
          textAlign: TextAlign.end,
        ),
      ],
    );
  }

  /// خطّ متدرّج ذهبي — أحد طرفيه يبدأ بلون واضح (عند النقطة) والآخر يتلاشى (عند الطائرة)
  Widget _gradientLine({required bool fromStart}) {
    final colors = fromStart
        ? [
            AppConsts.secondaryColor.withValues(alpha: 0.8),
            AppConsts.secondaryColor.withValues(alpha: 0.0),
          ]
        : [
            AppConsts.secondaryColor.withValues(alpha: 0.0),
            AppConsts.secondaryColor.withValues(alpha: 0.8),
          ];
    return Container(
      height: 1.3,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
      ),
    );
  }

  Widget _endDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppConsts.secondaryColor,
        boxShadow: [
          BoxShadow(
            color: AppConsts.secondaryColor.withValues(alpha: 0.5),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildDatesRow(
    ColorScheme cs, {
    String? timeDeadline,
    String? timeDeadlineDetail,
    String? issueOn,
    String? issueOnDetail,
    String? cancelled,
    String? cancelledDetail,
    String? voided,
    String? voidedDetail,
  }) {
    String? label;
    String? value;
    String? valueDetail;
    bool showDetail = false;
    VoidCallback? onToggle;
    IconData icon = Icons.event_note_rounded;

    if (item.flightStatus == BookingStatus.preBooking && timeDeadline != null) {
      label = 'Time Deadline'.tr;
      value = timeDeadline;
      valueDetail = timeDeadlineDetail;
      showDetail = showTimeDeadlineDetail;
      onToggle = () => setState(() => showTimeDeadlineDetail = !showTimeDeadlineDetail);
      icon = Icons.timer_outlined;
    } else if (item.flightStatus == BookingStatus.confirmed && issueOn != null) {
      label = 'Issue On'.tr;
      value = issueOn;
      valueDetail = issueOnDetail;
      showDetail = showIssueOnDetail;
      onToggle = () => setState(() => showIssueOnDetail = !showIssueOnDetail);
      icon = Icons.send_rounded;
    } else if ((item.flightStatus == BookingStatus.canceled ||
            item.flightStatus == BookingStatus.expiry) &&
        cancelled != null) {
      label = 'Cancel On'.tr;
      value = cancelled;
      valueDetail = cancelledDetail;
      showDetail = showCancelledDetail;
      onToggle = () => setState(() => showCancelledDetail = !showCancelledDetail);
      icon = Icons.cancel_schedule_send_outlined;
    } else if ((item.flightStatus == BookingStatus.voided ||
            item.flightStatus == BookingStatus.voide) &&
        voided != null) {
      label = 'Void On'.tr;
      value = voided;
      valueDetail = voidedDetail;
      showDetail = showVoidedDetail;
      onToggle = () => setState(() => showVoidedDetail = !showVoidedDetail);
      icon = Icons.block_rounded;
    }

    if (label == null || value == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppConsts.secondaryColor),
          const SizedBox(width: 6),
          Text(
            '$label:',
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: AppConsts.sm,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              showDetail ? (valueDetail ?? value) : value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
                fontSize: AppConsts.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paxChip(IconData icon, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.15),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          '$count',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppConsts.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _statusChip(({Color color, IconData icon}) v) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: v.color.withValues(alpha: 0.14),
        border: Border.all(color: v.color.withValues(alpha: 0.6), width: 1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(v.icon, size: 13, color: v.color),
          const SizedBox(width: 4),
          Text(
            item.flightStatus.name.tr,
            style: TextStyle(
              color: v.color,
              fontSize: AppConsts.sm,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  ({Color color, IconData icon}) _statusVisuals(BookingStatus s) {
    if (s == BookingStatus.confirmed) {
      return (color: const Color(0xFF2E7D32), icon: Icons.check_circle_rounded);
    }
    if (s == BookingStatus.preBooking || s == BookingStatus.pending) {
      return (color: const Color(0xFFF59E0B), icon: Icons.schedule_rounded);
    }
    if (s == BookingStatus.canceled || s == BookingStatus.expiry) {
      return (color: const Color(0xFFC62828), icon: Icons.cancel_rounded);
    }
    if (s == BookingStatus.voided || s == BookingStatus.voide) {
      return (color: const Color(0xFF8E24AA), icon: Icons.block_rounded);
    }
    return (color: const Color(0xFF78909C), icon: Icons.help_outline_rounded);
  }
}

class _EmptyView extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No data'.tr),
            const SizedBox(height: 10),
            OutlinedButton(onPressed: onRefresh, child: Text('Refresh'.tr)),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error'.tr),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: Text('Retry'.tr)),
          ],
        ),
      ),
    );
  }
}

class _StatusTab {
  final BookingStatus status;
  final String label;
  const _StatusTab(this.status, this.label);
}

/// ---- Labels & Formatters ----

String _formatDate(DateTime d) {
  final s = DateFormat('dd - MMM - yyyy', AppVars.lang).format(d);
  return AppFuns.replaceArabicNumbers(s);
}

String _formatDateDetail(DateTime d) {
  final s = DateFormat('EEE, dd - MMM - yyyy', AppVars.lang).format(d);
  return AppFuns.replaceArabicNumbers(s);
}

String _formatDateTime(DateTime d) {
  final s = Jiffy.parseFromDateTime(d).fromNow();
  return AppFuns.replaceArabicNumbers(s);
}

String _formatDateTimeDetail(DateTime d) {
  final s = DateFormat('EEE, dd - MMM - yyyy h:mm a', AppVars.lang).format(d);
  return AppFuns.replaceArabicNumbers(s);
}
