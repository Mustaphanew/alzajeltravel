import 'package:alzajeltravel/model/bookings_report/bookings_report_model.dart';
import 'package:alzajeltravel/utils/app_apis.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/enums.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BookingsReportController extends GetxController {
  BookingsReportData? bookingsReportData;

  /// ✅ Required for search
  BookingStatus? currentStatus;

  /// ✅ API pagination
  final int limit = 30;
  int offset = 0;

  bool loading = false;
  bool loadingMore = false;
  String? error;

  /// ✅ do not show list before first search
  bool searched = false;

  /// ✅ track the current search range (createdAt)
  DateTime? _dateFrom;
  DateTime? _dateTo;

  /// ✅ has more pages?
  bool hasMore = false;

  List<BookingReportItem> get items => bookingsReportData?.items ?? const [];

  String _fmt(DateTime d) => DateFormat('yyyy-MM-dd', 'en').format(d);

  String? _apiSessionId() {
    // TODO: adjust to your profile/session field name
    return AppVars.apiSessionId;
  }

  /// ✅ Start new search (offset resets to 0, items reset)
  Future<void> search({
    required BookingStatus status,
    required DateTime dateFrom,
    required DateTime dateTo,
    int fullDetails = 0,
  }) async {
    searched = true;
    currentStatus = status;

    _dateFrom = dateFrom;
    _dateTo = dateTo;

    offset = 0;
    hasMore = false;

    bookingsReportData = null;
    error = null;
    loading = true;
    loadingMore = false;
    update();

    await _fetchPage(fullDetails: fullDetails, resetItems: true);
  }

  /// ✅ Load next page
  Future<void> loadMore({int fullDetails = 0}) async {
    if (!searched) return;
    if (loading || loadingMore) return;
    if (!hasMore) return;

    loadingMore = true;
    error = null;
    update();

    offset += limit;
    await _fetchPage(fullDetails: fullDetails, resetItems: false);
  }

  /// ✅ Refresh current search
  Future<void> refreshData({int fullDetails = 0}) async {
    if (!searched) return;
    if (currentStatus == null || _dateFrom == null || _dateTo == null) return;

    offset = 0;
    hasMore = false;

    bookingsReportData = null;
    error = null;
    loading = true;
    loadingMore = false;
    update();

    await _fetchPage(fullDetails: fullDetails, resetItems: true);
  }

  Future<void> _fetchPage({
    required int fullDetails,
    required bool resetItems,
  }) async {
    if (AppVars.profile == null) {
      error = 'Not logged in'.tr;
      loading = false;
      loadingMore = false;
      hasMore = false;
      update();
      return;
    }

    final sid = _apiSessionId();
    if (sid == null || sid.isEmpty) {
      error = 'Session not found'.tr;
      loading = false;
      loadingMore = false;
      hasMore = false;
      update();
      return;
    }

    if (currentStatus == null || _dateFrom == null || _dateTo == null) {
      error = 'Invalid search params'.tr;
      loading = false;
      loadingMore = false;
      hasMore = false;
      update();
      return;
    }

    try {
      final response = await AppVars.api.post(
        AppApis.bookingsReport,
        params: {
          "api_session_id": sid,
          "status": currentStatus!.apiValue,
          "date_from": (currentStatus == BookingStatus.preBooking) ? null : _fmt(_dateFrom!),
          "date_to": (currentStatus == BookingStatus.preBooking) ? null : _fmt(_dateTo!),
          "full_details": fullDetails,
          "limit": limit,
          "offset": offset,
        },
        asJson: true,
      );

      if ((response['status'] ?? '').toString() != 'success') {
        throw Exception((response['message'] ?? 'Request failed'.tr).toString());
      }

      final dataJson = (response['data'] ?? {}) as Map<String, dynamic>;
      final data = BookingsReportData.fromJson(dataJson);

      final oldItems = resetItems
          ? <BookingReportItem>[]
          : (bookingsReportData?.items ?? const <BookingReportItem>[]);

      final newItems = <BookingReportItem>[...oldItems, ...data.items];

      bookingsReportData = BookingsReportData(
        agentId: data.agentId,
        status: data.status,
        fullDetails: data.fullDetails,
        count: data.count,
        items: newItems,
      );

      hasMore = data.items.length >= limit;
    } catch (e) {
      error = e.toString();
      hasMore = false;
    }

    loading = false;
    loadingMore = false;
    update();
  }

  void clear() {
    bookingsReportData = null;
    currentStatus = null;

    offset = 0;
    hasMore = false;

    _dateFrom = null;
    _dateTo = null;

    error = null;
    loading = false;
    loadingMore = false;
    searched = false;

    update();
  }
}
