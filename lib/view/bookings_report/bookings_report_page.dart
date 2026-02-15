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

import 'package:alzajeltravel/controller/airline_controller.dart';
import 'package:alzajeltravel/controller/bookings_report/bookings_report_controller.dart';
import 'package:alzajeltravel/model/bookings_report/bookings_report_model.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/widgets.dart';
import 'package:alzajeltravel/view/bookings_report/search_and_filter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
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
    return Scaffold(
      appBar: AppBar(title: Text('Bookings Report'.tr), centerTitle: true),
      body: Column(
        children: [
          ExpansionTile(
            controller: _filterTileController,
            initiallyExpanded: false,
            maintainState: true,

            // show status
            title: Text(
              'Search and Filter'.tr +
                  ' (' +
                  ((parentState?.status == BookingStatus.all) ? 'All'.tr : (parentState?.status?.toJson() ?? '').tr) +
                  ')',
            ),

            // collapsedBackgroundColor:
            //     (parentState == null || parentState!.applied == false)
            //         ? Colors.transparent
            //         : AppConsts.primaryColor.withValues(alpha: 0.5),
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
          const Divider(),
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
                return _ReportCard(item: visibleItems[index]);
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
  bool showTimeDeadlineDetail = false;
  bool showIssueOnDetail = false;

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

    final timeDeadline = item.timeDeadline != null ? _formatDate(item.timeDeadline!) : null;
    final timeDeadlineDetail = item.timeDeadline != null ? _formatDateTimeDetail(item.timeDeadline!) : null;

    final issueOn = item.issueOn != null ? _formatDate(item.issueOn!) : null;
    final issueOnDetail = item.issueOn != null ? _formatDateTimeDetail(item.issueOn!) : null;

    Color bgStatus = cs.primaryFixed.withOpacity(0.2);
    if (item.flightStatus == BookingStatus.canceled || item.flightStatus == BookingStatus.expiry) {
      bgStatus = Colors.red[800]!.withOpacity(0.2);
    } else if (item.flightStatus == BookingStatus.confirmed) {
      bgStatus = Colors.green[800]!.withOpacity(0.2);
    } else if (item.flightStatus == BookingStatus.preBooking) {
      bgStatus = Colors.yellow[800]!.withOpacity(0.2);
    } else if (item.flightStatus == BookingStatus.voide || item.flightStatus == BookingStatus.voided) {
      bgStatus = Colors.red[800]!.withOpacity(0.4);
    } else if (item.flightStatus == BookingStatus.pending) {
      bgStatus = Colors.yellow[600]!.withOpacity(0.6);
    } else if (item.flightStatus == BookingStatus.notFound) {
      bgStatus = cs.primaryFixed.withOpacity(0.2);
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(12),
        backgroundColor: cs.onInverseSurface,
        foregroundColor: cs.primaryFixed,
      ),
      onPressed: () async {
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
              screen: IssuingPage(
                offerDetail: flight,
                travelers: travelers,
                contact: contact,
                pnr: pnr,
                booking: booking,
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
      },
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
                style: TextStyle(fontSize: AppConsts.xxlg, fontWeight: FontWeight.bold),
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
              if (item.flightStatus == BookingStatus.preBooking)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Time Deadline'.tr),
                    GestureDetector(
                      onTap: () => setState(() => showTimeDeadlineDetail = !showTimeDeadlineDetail),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Text(
                          showTimeDeadlineDetail ? (timeDeadlineDetail ?? '_') : (timeDeadline ?? '_'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              if (item.flightStatus == BookingStatus.confirmed)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Issue On'.tr),
                    GestureDetector(
                      onTap: () => setState(() => showIssueOnDetail = !showIssueOnDetail),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Text(
                          showIssueOnDetail ? (issueOnDetail ?? '_') : (issueOn ?? '_'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 8),

          // cancel_on
          if (item.flightStatus == BookingStatus.canceled || item.flightStatus == BookingStatus.expiry)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cancel On'.tr),
                GestureDetector(
                  onTap: () => setState(() => showCancelledDetail = !showCancelledDetail),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Text(
                      showCancelledDetail ? (cancelledDetail ?? '_') : (cancelled ?? '_'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

          // void_on
          if (item.flightStatus == BookingStatus.voided || item.flightStatus == BookingStatus.voide)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Void On'.tr),
                GestureDetector(
                  onTap: () => setState(() => showVoidedDetail = !showVoidedDetail),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Text(
                      showVoidedDetail ? (voidedDetail ?? '_') : (voided ?? '_'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
                // show status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: bgStatus, borderRadius: BorderRadius.circular(4)),
                  child: Text(item.flightStatus.name.tr, style: TextStyle(fontSize: 14)),
                ),

                const Spacer(),
                Text(showCreatedAtDetail ? createdDetail : created, style: TextStyle(fontSize: AppConsts.sm)),
              ],
            ),
          ),
        ],
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
