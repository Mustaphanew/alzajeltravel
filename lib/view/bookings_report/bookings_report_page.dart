import 'package:alzajeltravel/controller/bookings_report/bookings_report_controller.dart';
import 'package:alzajeltravel/model/bookings_report/bookings_report_model.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BookingsReportPage extends StatefulWidget {
  const BookingsReportPage({super.key});

  @override
  State<BookingsReportPage> createState() => _BookingsReportPageState();
}

class _BookingsReportPageState extends State<BookingsReportPage> with SingleTickerProviderStateMixin {
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
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _switchToStatus(tabs[_tabController.index].status);
    });
  }

  void _switchToStatus(BookingStatus status) {
    // مهم: نمسح البيانات ونظهر Loading بدل بيانات التبويب السابق
    c.bookingsReportData = null;
    c.error = null;
    c.loading = true;
    c.loadingMore = false;
    c.currentStatus = status;
    c.limit = 10;
    c.update();

    // نجلب بدون ما نعيد ضبط loading من جديد (لأننا ضبطناه هنا)
    c.getDataServer(status: status, newLimit: 10, showLoading: false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookings Report'.tr),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: tabs.map((t) => Tab(text: t.label.tr)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(tabs.length, (_) => const _BookingsReportList()),
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
          return _ErrorView(
            message: controller.error!,
            onRetry: () => controller.refreshData(initialLimit: 10),
          );
        }

        if (controller.items.isEmpty) {
          return _EmptyView(onRefresh: () => controller.refreshData(initialLimit: 10));
        }

        final showLoadMoreButton =
            !controller.loadingMore && !controller.loading && (controller.items.length >= controller.limit);

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
                      Text('Loading more...'.tr),
                    ] else if (showLoadMoreButton) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: controller.loadMore,
                          child: Text('Load more'.tr),
                        ),
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

class _ReportCard extends StatelessWidget {
  final BookingReportItem item;

  const _ReportCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final created = _formatDateTime(item.createdAt);
    final travel = _formatDate(item.travelDate);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking ID + Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Field(
                    label: 'Booking ID'.tr,
                    value: item.bookingId,
                  ),
                ),
                const SizedBox(width: 12),
                _ChipText(text: _statusLabel(item.reportStatus).tr),
              ],
            ),

            const SizedBox(height: 10),

            _Field(label: 'PNR'.tr, value: item.pnr),

            const SizedBox(height: 10),

            // Travel date + Created at
            Row(
              children: [
                Expanded(child: _Field(label: 'Travel date'.tr, value: travel)),
                const SizedBox(width: 12),
                Expanded(child: _Field(label: 'Created at'.tr, value: created)),
              ],
            ),

            const SizedBox(height: 10),

            // Route + Journey type
            Row(
              children: [
                Expanded(
                  child: _Field(
                    label: 'Route'.tr,
                    value: '${item.origin.name[AppVars.lang]} → ${item.destination.name[AppVars.lang]}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    label: 'Journey type'.tr,
                    value: _journeyTypeLabel(item.journeyType).tr,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Travelers count + Amount
            Row(
              children: [
                Expanded(
                  child: _Field(
                    label: 'Travelers'.tr,
                    value: item.travelersCount.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    label: 'Amount'.tr,
                    value: '${item.totalAmount.toStringAsFixed(2)} ${item.currency}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;

  const _Field({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelMedium;
    final valueStyle = Theme.of(context).textTheme.bodyMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 4),
        SelectableText(value, style: valueStyle),
      ],
    );
  }
}

class _ChipText extends StatelessWidget {
  final String text;

  const _ChipText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(width: 1),
      ),
      child: Text(text),
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
            OutlinedButton(
              onPressed: onRefresh,
              child: Text('Refresh'.tr),
            ),
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
            OutlinedButton(
              onPressed: onRetry,
              child: Text('Retry'.tr),
            ),
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

String _statusLabel(BookingStatus s) {
  final v = s.apiValue;
  if (v == 'confirmed') return 'Confirmed';
  if (v == 'pre-book') return 'Pre-book';
  if (v == 'cancelled' || v == 'canceled') return 'Cancelled';
  if (v == 'void' || v == 'voided') return 'Void';
  return 'Unknown';
}

String _journeyTypeLabel(JourneyType t) {
  switch (t) {
    case JourneyType.oneWay:
      return 'One way';
    case JourneyType.roundTrip:
      return 'Round trip';
    case JourneyType.multiCity:
      return 'Multi city';
  }
}

String _formatDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

String _formatDateTime(DateTime d) => DateFormat('yyyy-MM-dd HH:mm').format(d);
