import 'package:get/get.dart';
import 'package:alzajeltravel/model/passport/traveler_review/traveler_review_model.dart';
import 'package:alzajeltravel/model/passport/traveler_review/seat_model.dart';
import 'package:alzajeltravel/utils/app_apis.dart';
import 'package:alzajeltravel/utils/app_vars.dart';

class TravelersReviewController extends GetxController {
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

  dynamic preRes;
  String? prePnr;
  Future<dynamic> preBooking(String insertId) async {
    try {
      // 1) استدعاء pre-book
      preRes = await AppVars.api.post(AppApis.preBookFlight, params: {"insert_id": insertId});

      if (preRes == null) {
        Get.snackbar("Error".tr, "Could not pre-book".tr, snackPosition: SnackPosition.BOTTOM);
        return null;
      }

      if (preRes is! Map<String, dynamic>) {
        Get.snackbar("Error".tr, "Invalid server response".tr, snackPosition: SnackPosition.BOTTOM);
        return null;
      }

      prePnr = preRes['PNR']?.toString();
      print("📦 pre-book response: $preRes");
      print("➡️ pre-book PNR: $prePnr");

      // لو ما رجع PNR من pre-book نوقف هنا
      if (prePnr == null || prePnr!.isEmpty) {
        final msg = preRes['messages']?['error']?.toString() ?? preRes['message']?.toString() ?? "Unknown error";
        Get.snackbar("Error".tr, msg, snackPosition: SnackPosition.BOTTOM);
        return null;
      }
    } catch (e) {
      print("❌ pre-book error: $e");
      Get.snackbar("Error".tr, "Could not pre-book".tr, snackPosition: SnackPosition.BOTTOM);
      return null;
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
        Get.snackbar("Error".tr, "Could not issue ticket".tr, snackPosition: SnackPosition.BOTTOM);
        return null;
      }

      if (issueRes is! Map<String, dynamic>) {
        Get.snackbar("Error".tr, "Invalid server response".tr, snackPosition: SnackPosition.BOTTOM);
        return null;
      }

      final String? issuePnr = issueRes['PNR']?.toString();
      final String? ticketNum = issueRes['TicketNum']?.toString();

      print("📦 issue response: $issueRes");
      print("➡️ issue PNR: $issuePnr, TicketNum: $ticketNum");

      if (ticketNum != null && ticketNum.isNotEmpty) {
        // نجاح كامل: تم إصدار التذكرة
        Get.snackbar(
          "Booking".tr,
          "Ticket issued successfully\nPNR: @pnr\nTicket: @ticket".trParams({"pnr": (issuePnr ?? prePnr) ?? "-", "ticket": ticketNum}),
          snackPosition: SnackPosition.BOTTOM,
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
        Get.snackbar("Error".tr, msg, snackPosition: SnackPosition.BOTTOM);
        return null;
      }
    } catch (e) {
      print("❌ confirmBooking error: $e");
      Get.snackbar("Error".tr, "Could not confirm booking".tr, snackPosition: SnackPosition.BOTTOM);
      return null;
    }
  }

}
