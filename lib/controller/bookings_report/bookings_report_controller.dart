// bookings_report_controller.dart

import 'package:alzajeltravel/model/bookings_report/bookings_report_model.dart';
import 'package:alzajeltravel/utils/app_apis.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/enums.dart';
import 'package:get/get.dart';

class BookingsReportController extends GetxController {
  BookingsReportData? bookingsReportData;

  BookingStatus currentStatus = BookingStatus.preBooking;

  /// current limit used by the API
  int limit = 10;

  /// increase limit step for "load more"
  final int limitStep = 10;

  bool loading = false;
  bool loadingMore = false;
  String? error;

  List<BookingReportItem> get items => bookingsReportData?.items ?? const [];
  int get itemsCount => items.length;
  bool get hasData => items.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    // إذا تحب التحميل مباشرة عند الدخول فعّل السطر التالي
    // getDataServer();
  }

  Future<void> getDataServer({
    BookingStatus? status,
    int? newLimit,
    bool fullDetails = false,
    bool showLoading = true,
  }) async {
    if (status != null) currentStatus = status;
    if (newLimit != null) limit = newLimit;

    if (showLoading) {
      loading = true;
      error = null;
      update();
    } else {
      error = null;
      update();
    }

    if (AppVars.profile == null) {
      error = 'Not logged in'.tr;
      loading = false;
      loadingMore = false;
      update();
      return;
    }

    try {
      final response = await AppVars.api.post(
        AppApis.bookingsReport,
        params: {
          "status": currentStatus.apiValue,
          "limit": limit,
          "full_details": fullDetails ? 1 : 0,
          "agent_id": AppVars.profile!.id,
        },
        asJson: true,
      );

      bookingsReportData = BookingsReportResponse.fromJson(response).data;
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    loadingMore = false;
    update();
  }

  /// Refresh with same status and reset limit to initial
  Future<void> refreshData({
    int initialLimit = 10,
    bool fullDetails = false,
  }) async {
    limit = initialLimit;
    await getDataServer(
      status: currentStatus,
      newLimit: limit,
      fullDetails: fullDetails,
      showLoading: true,
    );
  }

  /// Naive "load more": increases limit and refetches first N items
  /// (بدون pagination حقيقية لأن الـ API ما أعطانا page/offset)
  Future<void> loadMore({
    bool fullDetails = false,
  }) async {
    if (loading || loadingMore) return;

    loadingMore = true;
    error = null;
    update();

    final nextLimit = limit + limitStep;
    await getDataServer(
      status: currentStatus,
      newLimit: nextLimit,
      fullDetails: fullDetails,
      showLoading: false,
    );
  }

  void changeStatus(BookingStatus status, {int? initialLimit}) {
    currentStatus = status;
    limit = initialLimit ?? limit;
    getDataServer(status: currentStatus, newLimit: limit);
  }

  void clear() {
    bookingsReportData = null;
    error = null;
    loading = false;
    loadingMore = false;
    update();
  }
}
