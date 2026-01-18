import 'package:alzajeltravel/model/bookings_report/bookings_report_model.dart';
import 'package:alzajeltravel/utils/app_apis.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/enums.dart';
import 'package:get/get.dart';

class BookingsReportController extends GetxController {
  BookingsReportData? bookingsReportData;

  BookingStatus currentStatus = BookingStatus.preBooking;

  int limit = 10;
  final int limitStep = 10;

  bool loading = false;
  bool loadingMore = false;
  String? error;

  /// ✅ لا نعرض أي نتائج قبل أول Search
  bool searched = false;

  List<BookingReportItem> get items => bookingsReportData?.items ?? const [];
  int get itemsCount => items.length;
  bool get hasData => items.isNotEmpty;

  Future<void> search({
    required BookingStatus status,
    int initialLimit = 10,
    bool fullDetails = false,
  }) async {
    searched = true;

    bookingsReportData = null;
    error = null;
    loading = true;
    loadingMore = false;

    currentStatus = status;
    limit = initialLimit;

    update();

    await getDataServer(
      status: currentStatus,
      newLimit: limit,
      fullDetails: fullDetails,
      showLoading: false,
    );
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

  Future<void> refreshData({
    int initialLimit = 10,
    bool fullDetails = false,
  }) async {
    if (!searched) return;
    limit = initialLimit;
    await getDataServer(
      status: currentStatus,
      newLimit: limit,
      fullDetails: fullDetails,
      showLoading: true,
    );
  }

  Future<void> loadMore({
    bool fullDetails = false,
  }) async {
    if (!searched) return;
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

  void clear() {
    bookingsReportData = null;
    error = null;
    loading = false;
    loadingMore = false;
    searched = false;
    update();
  }
}
