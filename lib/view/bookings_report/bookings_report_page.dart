import 'package:alzajeltravel/controller/airline_controller.dart';
import 'package:alzajeltravel/controller/bookings_report/bookings_report_controller.dart';
import 'package:alzajeltravel/controller/bookings_report/trip_detail/booking_detail.dart';
import 'package:alzajeltravel/controller/bookings_report/trip_detail/flight_detail.dart';
import 'package:alzajeltravel/controller/bookings_report/trip_detail/travelers_detail.dart';
import 'package:alzajeltravel/controller/flight/flight_detail_controller.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:jiffy/jiffy.dart';
import 'dart:convert';

class BookingsReportPage extends StatefulWidget {
  const BookingsReportPage({super.key});

  @override
  State<BookingsReportPage> createState() => _BookingsReportPageState();
}

class _BookingsReportPageState extends State<BookingsReportPage> with SingleTickerProviderStateMixin {
  FlightDetailApiController flightDetailApiController = Get.put(FlightDetailApiController());
  AirlineController airlineController = Get.put(AirlineController());

  late final TabController _tabController;
  late final BookingsReportController c;

  // نختار الستاتس من apiValue (حتى لو اسم enum عندك مختلف)
  static BookingStatus _pickStatus(List<String> values) {
    for (final v in values) {
      final s = BookingStatus.fromJson(v);
      if (s != BookingStatus.notFound) return s;
    }
    return BookingStatus.notFound;
  }

  late final List<_StatusTab> tabs = <_StatusTab>[
    _StatusTab(_pickStatus(['pre-book']), 'Pre-book'),
    _StatusTab(_pickStatus(['confirmed']), 'Confirmed'),
    _StatusTab(_pickStatus(['cancelled', 'canceled']), 'Cancelled'),
    _StatusTab(_pickStatus(['void', 'voided']), 'Void'),
  ];

  @override
  void initState() {
    super.initState();

    // منع تكرار put إذا الكنترولر مسجّل مسبقاً
    if (Get.isRegistered<BookingsReportController>()) {
      c = Get.find<BookingsReportController>();
    } else {
      c = Get.put(BookingsReportController());
    }

    _tabController = TabController(length: tabs.length, vsync: this);

    // أول تحميل
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _switchToStatus(tabs[0].status);
    });

    // عند تغيير التبويب
    // _tabController.addListener(() {
    //   if (_tabController.indexIsChanging) return;
    //   _switchToStatus(tabs[_tabController.index].status);
    // });
    _filterTileController.addListener(() {
      if (_filterTileController.isExpanded == false) {
        setState(() {});
      }
    });
  }

  Future<void> _switchToStatus(BookingStatus status) async {
    // مهم: نمسح البيانات ونظهر Loading بدل بيانات التبويب السابق
    c.bookingsReportData = null;
    c.error = null;
    c.loading = true;
    c.loadingMore = false;
    c.currentStatus = status;
    c.limit = 10;
    c.update();

    // نجلب بدون ما نعيد ضبط loading من جديد (لأننا ضبطناه هنا)
    print('_switchToStatus status: $status');
    await c.getDataServer(status: status, newLimit: 10, showLoading: false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final ExpansibleController _filterTileController = ExpansibleController();

  SearchAndFilterState? parentState;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookings Report'.tr),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Material(
            color: AppConsts.primaryColor.withValues(alpha: 0.4),
            child: TabBar(
              controller: _tabController,

              indicatorSize: TabBarIndicatorSize.tab,
              // indicatorWeight: 60,
              dividerHeight: 0,
              dividerColor: Colors.transparent,
              padding: EdgeInsets.all(0),
              indicator: BoxDecoration(color: AppConsts.primaryColor),
              labelColor: cs.secondary,
              unselectedLabelColor: cs.onPrimary,
              unselectedLabelStyle: TextStyle(fontSize: AppConsts.normal, fontWeight: FontWeight.normal, fontFamily: AppConsts.font),
              labelStyle: TextStyle(fontSize: AppConsts.normal, fontWeight: FontWeight.w600, fontFamily: AppConsts.font),

              physics: const NeverScrollableScrollPhysics(),
              isScrollable: false,
              tabs: tabs.map((t) => Tab(text: t.label.tr)).toList(),
              onTap: (index) async {
                print("index: $index");
                context.loaderOverlay.show();
                await _switchToStatus(tabs[index].status);
                if (context.mounted) context.loaderOverlay.hide();
                _filterTileController.collapse();
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          ExpansionTile(
            controller: _filterTileController,
            maintainState: true, // ✅ مهم جدًا: يحافظ على State عند الإغلاق
            title: Text('Search and Filter'.tr),
            collapsedBackgroundColor: (parentState == null || parentState!.applied == false) ? Colors.transparent : AppConsts.primaryColor.withValues(alpha: 0.5),
            children: [
              SearchAndFilter(
                status: c.currentStatus,
                tileController: _filterTileController, 
                onSearch: (state) {
                  
                  this.parentState = state;
                  print("state: ${state.applied}");
                  // TODO: لاحقاً اربطها بجلب البيانات من السيرفر
                  // state contains selections
                },
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: List.generate(tabs.length, (_) => const _BookingsReportList()),
            ),
          ),
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

    // إذا رجع السيرفر عناصر مساوية للـ limit → غالباً يوجد المزيد
    final canLoadMore = !c.loading && !c.loadingMore && (c.items.length >= c.limit);

    if (canLoadMore && pos.pixels >= pos.maxScrollExtent - threshold) {
      c.loadMore(); // 10 -> 20 -> 30 ...
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GetBuilder<BookingsReportController>(
      builder: (controller) {
        if (controller.loading && controller.items.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (controller.error != null && controller.items.isEmpty) {
          return _ErrorView(message: controller.error!, onRetry: () => controller.refreshData(initialLimit: 10));
        }

        if (controller.items.isEmpty) {
          return _EmptyView(onRefresh: () => controller.refreshData(initialLimit: 10));
        }

        final showLoadMoreButton = !controller.loadingMore && !controller.loading && (controller.items.length >= controller.limit);

        return RefreshIndicator(
          onRefresh: () => controller.refreshData(initialLimit: 10),
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: controller.items.length + 1,
            itemBuilder: (context, index) {
              if (index < controller.items.length) {
                final item = controller.items[index];
                return _ReportCard(item: item);
              }

              // Footer
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  children: [
                    if (controller.loadingMore) ...[
                      const SizedBox(height: 6),
                      const CircularProgressIndicator.adaptive(),
                      const SizedBox(height: 10),
                      Text('Loading more'.tr + " ..."),
                    ] else if (showLoadMoreButton) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(onPressed: controller.loadMore, child: Text('Load more'.tr)),
                      ),
                    ] else ...[
                      Text('No more results'.tr),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ReportCard extends StatefulWidget {
  final BookingReportItem item;
  const _ReportCard({required this.item});

  @override
  State<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<_ReportCard> {
  bool showCreatedAtDetail = false;
  bool showCancelledDetail = false;
  bool showVoidedDetail = false;

  BookingReportItem get item => widget.item;

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

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
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

          Get.to(() => IssuingPage(offerDetail: flight, travelers: travelers, contact: contact, pnr: pnr, booking: booking));
        } catch (e) {
          // ممكن تعرض Dialog بدل print
          print("error: $e");
        }
        if (context.mounted) context.loaderOverlay.hide();
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // booking & amount
              Row(
                children: [
                  Text(
                    item.bookingId,
                    style: TextStyle(fontSize: AppConsts.lg, fontWeight: FontWeight.bold),
                  ),
                  
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: json.encode(item.toJson())));
                      Fluttertoast.showToast(msg: "Booking copied to clipboard".tr);
                    },
                    child: Tooltip(
                      message: "Copy booking".tr,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Icon(Icons.copy_outlined, size: 18),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    AppFuns.priceWithCoin(item.totalAmount, item.currency),
                    style: TextStyle(
                      color: cs.error,
                      fontSize: AppConsts.xxlg, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // PNR
              Text('PNR'.tr),
              Text(item.pnr, style: const TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 12),

              // route
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.origin.name[AppVars.lang],
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppConsts.lg),
                      ),
                      Text(item.origin.code, style: TextStyle(fontSize: AppConsts.lg)),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const DividerLine(),
                          if (item.journeyType == JourneyType.oneWay) const Icon(Icons.arrow_forward),
                          if (item.journeyType == JourneyType.roundTrip)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              color: cs.surfaceContainerHighest,
                              child: const Icon(Icons.sync_alt, size: 28),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(item.destination.name[AppVars.lang], style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(item.destination.code),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),

              // travel date (departure & return)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Flight Date'.tr),
                      Text(travel, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  // if (item.journeyType == JourneyType.roundTrip)
                  //   Column(
                  //     crossAxisAlignment: CrossAxisAlignment.end,
                  //     children: [
                  //       Text('Return Date'.tr),
                  //       Text(travel, style: const TextStyle(fontWeight: FontWeight.bold)),
                  //     ],
                  //   ),
                ],
              ),

              const SizedBox(height: 8),

              // cancel_on
              if (item.reportStatus == BookingStatus.canceled || item.reportStatus == BookingStatus.expiry)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cancel On'.tr),
                    GestureDetector(
                      onTap: () => setState(() => showCancelledDetail = !showCancelledDetail),
                      child: Text(
                        showCancelledDetail ? (cancelledDetail ?? '_') : (cancelled ?? '_'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

              // void_on
              if (item.reportStatus == BookingStatus.voided || item.reportStatus == BookingStatus.voide)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Void On'.tr),
                    GestureDetector(
                      onTap: () => setState(() => showVoidedDetail = !showVoidedDetail),
                      child: Text(
                        showVoidedDetail ? (voidedDetail ?? '_') : (voided ?? '_'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 8),

              // count adult children and infants
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.primaryContainer.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(children: [const Icon(Icons.person_outline, size: 22), Text(item.adult.toString())]),
                    Column(children: [const Icon(Icons.child_care_outlined, size: 22), Text(item.child.toString())]),
                    Column(children: [const Icon(Icons.child_friendly_outlined, size: 22), Text(item.inf.toString())]),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // created at (relative / detail toggle)
              GestureDetector(
                onTap: () => setState(() => showCreatedAtDetail = !showCreatedAtDetail),
                child: Row(
                  children: [
                    const Spacer(),
                    Text(showCreatedAtDetail ? createdDetail : created, style: TextStyle(fontSize: AppConsts.sm)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
