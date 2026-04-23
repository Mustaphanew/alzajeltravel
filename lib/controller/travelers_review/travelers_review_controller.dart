import 'package:alzajeltravel/controller/flight/flight_detail_controller.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/model/passport/traveler_review/traveler_review_model.dart';
import 'package:alzajeltravel/model/passport/traveler_review/seat_model.dart';
import 'package:alzajeltravel/utils/app_apis.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/app_vars.dart';

class TravelersReviewController extends GetxController {
  final FlightDetailApiController flightDetailApiController = Get.put(FlightDetailApiController());
  final List<TravelerReviewModel> travelers;

  TravelersReviewController(this.travelers);

  late final TravelerFareSummary summary;

  @override
  void onInit() {
    super.onInit();
    summary = TravelerFareSummary.fromTravelers(travelers);
  }

  // مثال: تغيير مقعد لمسافر معين
  void changeSeat(int index, Seat? newSeat) {
    travelers[index] = travelers[index].copyWith(seat: newSeat);
    update();
  }

  // set ticket number by passport number
  void setTicketNumber(String passportNumber, String ticketNumber) {
    // نجيب index للمسافر اللي جوازه يطابق الرقم
    final index = travelers.indexWhere((t) => t.passport.documentNumber == passportNumber);

    if (index == -1) {
      // لو ما لقينا أحد بهذا الرقم، ممكن تطبع لوج أو تتجاهل
      // print('No traveler found for passport $passportNumber');
      return;
    }

    // ننسخ العنصر مع تعديل ticketNumber
    travelers[index] = travelers[index].copyWith(ticketNumber: ticketNumber);

    // update(); // عشان تحدّث الواجهة
  }


  DateTime? parseTktTimeLimit(dynamic v) {
    final s = (v ?? '').toString().trim();
    if (s.isEmpty) return null;

    // يحول "2025-12-31 23:59:59" إلى "2025-12-31T23:59:59" عشان DateTime.parse يكون مضمون
    final normalized = s.contains('T') ? s : s.replaceFirst(' ', 'T');
    return DateTime.tryParse(normalized);
  }


  dynamic preRes;
  String? prePnr;
  Future<dynamic> preBooking(String insertId) async {
    try {
      // 1) استدعاء pre-book
      preRes = await AppVars.api.post(AppApis.preBookFlight, params: {"insert_id": insertId});

      if (preRes == null) {
        AppFuns.showSnack("Error".tr, "Could not pre-book".tr, type: SnackType.error);
        return null;
      }

      if (preRes is! Map<String, dynamic>) {
        AppFuns.showSnack("Error".tr, "Invalid server response".tr, type: SnackType.error);
        return null;
      }

      prePnr = preRes['PNR']?.toString();
      print("📦 pre-book response: $preRes");
      print("➡️ pre-book PNR: $prePnr");

      // لو ما رجع PNR من pre-book نوقف هنا
      if (prePnr == null || prePnr!.isEmpty) {
        final msg = preRes['messages']?['error']?.toString() ?? preRes['message']?.toString() ?? "Unknown error";
        AppFuns.showSnack("Error".tr, msg, type: SnackType.error);
        return null;
      }
    } catch (e) {
      print("❌ pre-book error: $e");
      AppFuns.showSnack("Error".tr, "Could not pre-book".tr, type: SnackType.error);
      return null;
    }

      final tkt = preRes['flight']?['ticket_deadline'];
      print('ticket_deadline: $tkt');
      final c = flightDetailApiController.revalidatedDetails;
      final current = c.value;
      if (current != null) {
        c.value = current.copyWith(timeLimit: parseTktTimeLimit(tkt));
        print('timeLimit: ${flightDetailApiController.revalidatedDetails.value?.timeLimit}');
      }

    return preRes;
  }

  // issuing booking = confirm booking
  dynamic issueRes;
  Future<dynamic> confirmBooking(String insertId) async {
    // 2) استدعاء issue بعد نجاح pre-book ووجود PNR
    try {
      issueRes = await AppVars.api.post( 
        AppApis.issueFlight, 
        params: {"insert_id": insertId},
      ); 

      if (issueRes == null) {
        AppFuns.showSnack("Error".tr, "Could not issue ticket".tr, type: SnackType.error);
        return null;
      }

      if (issueRes is! Map<String, dynamic>) {
        AppFuns.showSnack("Error".tr, "Invalid server response".tr, type: SnackType.error);
        return null;
      }

      final String? issuePnr = issueRes['PNR']?.toString();
      final String? ticketNum = issueRes['TicketNum']?.toString();

      print("📦 issue response: $issueRes");
      print("➡️ issue PNR: $issuePnr, TicketNum: $ticketNum");

      if (ticketNum != null && ticketNum.isNotEmpty) {
        // نجاح كامل: تم إصدار التذكرة
        AppFuns.showSnack(
          "Booking".tr,
          "Ticket issued successfully\nPNR: @pnr\nTicket: @ticket".trParams({"pnr": (issuePnr ?? prePnr) ?? "-", "ticket": ticketNum}),
          type: SnackType.success,
          duration: const Duration(seconds: 5),
        );

        return issueRes;

        // هنا تقدر:
        // - تحفظ PNR/TicketNum في AppVars أو Controller
        // - وتوجّه المستخدم لصفحة ملخص الحجز
        // Get.off(() => BookingSummaryPage(pnr: issuePnr ?? prePnr, ticketNum: ticketNum));
      } else {
        // ما فيه TicketNum → شيء ناقص في الإصدار
        final msg = issueRes['messages']?['error']?.toString() ?? issueRes['message']?.toString() ?? "Unknown error";
        AppFuns.showSnack("Error".tr, msg, type: SnackType.error);
        return null;
      }
    } catch (e) {
      print("❌ confirmBooking error: $e");
      AppFuns.showSnack("Error".tr, "Could not confirm booking".tr, type: SnackType.error);
      return null;
    }
  }

  // cancel pre-booking
  dynamic cancelPreBookingRes;
  Future<dynamic> cancelPreBooking(String insertId) async {
    try {
      cancelPreBookingRes = await AppVars.api.post(
        AppApis.cancelPnr,
        params: {
          "insert_id": insertId,
          "api_session_id": AppVars.apiSessionId,
        },
      );
      if (cancelPreBookingRes == null) {
        AppFuns.showSnack("Error".tr, "Could not cancel pre-booking".tr, type: SnackType.error);
        return null;
      }
      if (cancelPreBookingRes is! Map<String, dynamic>) {
        AppFuns.showSnack("Error".tr, "Invalid server response".tr, type: SnackType.error);
        return null;
      }
      return cancelPreBookingRes;
    } catch (e) {
      print("❌ cancelPreBooking error: $e");
      AppFuns.showSnack("Error".tr, "Could not cancel pre-booking".tr, type: SnackType.error);
      return null;
    }
  }

  // void issue
  dynamic voidIssueRes;
  Future<dynamic> voidIssue(String insertId) async { 
    try {
      voidIssueRes = await AppVars.api.post(  
        AppApis.voidIssue,
        params: {
          "insert_id": insertId,
          "api_session_id": AppVars.apiSessionId,
        },
      );
      print("voidIssueRes: $voidIssueRes");
      if (voidIssueRes == null) {
        AppFuns.showSnack("Error".tr, "Could not void issue 1".tr, type: SnackType.error);
        return null;
      }
      if (voidIssueRes is! Map<String, dynamic>) {
        AppFuns.showSnack("Error".tr, "Invalid server response".tr, type: SnackType.error);
        return null;
      }
      return voidIssueRes;
    } catch (e) {
      print("❌ voidIssue error: $e");
        AppFuns.showSnack("Error".tr, "Could not void issue 2".tr, type: SnackType.error);
      return null;
    }
  }

}
