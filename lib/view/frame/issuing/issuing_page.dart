import 'package:alzajeltravel/controller/bookings_report/bookings_report_controller.dart';
import 'package:alzajeltravel/model/booking_data_model.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/enums.dart';
import 'package:alzajeltravel/utils/widgets/custom_dialog.dart';
import 'package:alzajeltravel/utils/widgets/farings_baggages_table.dart';
import 'package:alzajeltravel/view/frame/issuing/print_issuing_ar.dart';
import 'package:alzajeltravel/view/frame/time_remaining.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:alzajeltravel/controller/travelers_review/travelers_review_controller.dart';
import 'package:alzajeltravel/model/contact_model.dart';
import 'package:alzajeltravel/model/flight/revalidated_flight_model.dart';
import 'package:alzajeltravel/model/passport/traveler_review/traveler_review_model.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/view/frame/flights/flight_detail/more_flight_detail_page.dart';
import 'package:alzajeltravel/view/frame/flights/flight_offers_list.dart';
import 'package:alzajeltravel/view/frame/issuing/print_issuing.dart';
import 'package:loader_overlay/loader_overlay.dart';

class IssuingPage extends StatefulWidget {
  final RevalidatedFlightModel offerDetail;
  final List<TravelerReviewModel> travelers;
  final ContactModel contact;
  final String pnr;
  final BookingDataModel booking;
  final String fromPage;
  const IssuingPage({
    super.key,
    required this.offerDetail,
    required this.travelers,
    required this.contact,
    required this.pnr,
    required this.booking,
    required this.fromPage,
  });

  @override
  State<IssuingPage> createState() => _IssuingPageState();
}

class _IssuingPageState extends State<IssuingPage> {
  late TravelersReviewController travelersReviewController;

  List<Map<String, dynamic>> faringsData = [];

  List<Map<String, dynamic>> baggagesData = [];

  late TravelerFareSummary summary;

  late BookingDataModel booking;

  String bookingStatus = "";

  DateTime? timeLimit;
  bool isExpired = false;

  String createdOn = "";
  String? voidOn;
  String? cancelOn;

  @override
  void initState() {
    super.initState();
    travelersReviewController = Get.put(TravelersReviewController(widget.travelers));
    booking = widget.booking;
    final tmpBaggage = widget.offerDetail.offer.baggagePerSegment.first;
    summary = travelersReviewController.summary;

    if (summary.adultCount > 0) {
      faringsData.add({"type": "Adult X ".tr + " ${summary.adultCount}", "Total fare": AppFuns.priceWithCoin(summary.adultTotalFare, "")});
      baggagesData.add({"type": "Adult".tr, "Weight": AppFuns.formatBaggageWeight(tmpBaggage)});
    }
    if (summary.childCount > 0) {
      faringsData.add({"type": "Child X ".tr + " ${summary.childCount}", "Total fare": AppFuns.priceWithCoin(summary.childTotalFare, "")});
      baggagesData.add({"type": "Child".tr, "Weight": "10kg"});
    }
    if (summary.infantLapCount > 0) {
      faringsData.add({
        "type": "Infant X ".tr + " ${summary.infantLapCount}",
        "Total fare": AppFuns.priceWithCoin(summary.infantLapTotalFare, ""),
      });
      baggagesData.add({"type": "Infant".tr, "Weight": "5kg"});
    }
    bookingStatus = booking.status.name;
    timeLimit = widget.offerDetail.timeLimit;
    if (timeLimit != null) {
      isExpired = timeLimit!.isBefore(DateTime.now());
    }
    createdOn = _formatDateTime(booking.createdOn)!;
    voidOn = _formatDateTime(widget.offerDetail.voidOn);
    cancelOn = _formatDateTime(widget.offerDetail.cancelOn);
  }

  bool allowVoid() {
    final createdOn = booking.createdOn;
    final now = DateTime.now();
    final diff = now.difference(createdOn);

    // أقل من 23 ساعة => مسموح
    return diff.inMinutes < 23 * 60;
  }

  BookingsReportController bookingsReportController = Get.isRegistered<BookingsReportController>() ? 
    Get.find<BookingsReportController>() : 
    Get.put(BookingsReportController());

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // لون لوحة أزرار Outlined في الليلي — نفس عائلة البطاقات (بدل الأسود الافتراضي)
    final Color darkOutlineButtonFill = const Color(0xFF121A38);

    return PopScope(
      canPop: false, // نمنع الرجوع تلقائيًا ونقرر نحن بعد التأكيد
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final ok = await AppFuns.confirmExit(title: "Exit".tr, message: "Are you sure you want to exit?".tr);

        if (ok && context.mounted) {
          Navigator.of(context).pop(result);
          if(widget.fromPage == "bookings_report") {
            bookingsReportController.refreshData();
          } else if(widget.fromPage == "home") {
            AppFuns.refreshHomePage();
          }
          // أو فقط pop() إذا ما تحتاج result
        }
      },

      child: SafeArea(
        top: false,
        child: Scaffold(
          // ليلي فقط: خلفية كحلية أعمق لإبراز البطاقات والحدود الذهبية (النهاري دون تغيير)
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF0B1430)
              : const Color(0xFFFAF6F1),
          appBar: AppBar(
            title: Text(
              "Issuing".tr,
              style: TextStyle(
                color: isDark ? Colors.white : AppConsts.primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: AppConsts.xlg,
                letterSpacing: 0.3,
              ),
            ),
            backgroundColor: isDark
                ? AppConsts.primaryColor
                : const Color(0xFFFAF6F1),
            foregroundColor:
                isDark ? Colors.white : AppConsts.primaryColor,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            iconTheme: IconThemeData(
              color: isDark ? Colors.white : AppConsts.primaryColor,
            ),
            titleTextStyle: TextStyle(
              color: isDark ? Colors.white : AppConsts.primaryColor,
              fontWeight: FontWeight.w700,
              fontSize: AppConsts.xlg,
            ),
            elevation: 0,
            centerTitle: true,
            shape: Border(
              bottom: BorderSide(
                color: AppConsts.secondaryColor
                    .withValues(alpha: isDark ? 0.45 : 0.35),
                width: 1,
              ),
            ),
            actions: [
              if (widget.booking.status == BookingStatus.confirmed)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppConsts.secondaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      minimumSize: const Size(86, 34),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppConsts.secondaryColor, width: 1.3),
                      ),
                      textStyle: const TextStyle(
                        fontSize: AppConsts.normal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      if (AppVars.lang == "ar") {
                        Get.to(
                          PrintIssuingAr(
                            pnr: widget.pnr,
                            bookingData: booking,
                            offerDetail: widget.offerDetail,
                            travelersReviewController: travelersReviewController,
                            contact: widget.contact,
                            baggagesData: baggagesData,
                          ),
                        );
                      } else {
                        Get.to(
                          PrintIssuing(
                            pnr: widget.pnr,
                            bookingData: booking,
                            offerDetail: widget.offerDetail,
                            travelersReviewController: travelersReviewController,
                            contact: widget.contact,
                            baggagesData: baggagesData,
                          ),
                        );
                      }
                    },

                    icon: const Icon(Icons.print),
                    label: Text("Print".tr),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              StatusCard(cs: cs, bookingStatus: bookingStatus),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (booking.status == BookingStatus.preBooking && !isExpired) ...[
                            // confirm — زر CTA ذهبي مع نصّ Navy
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final dialog = await CustomDialog.confirm(
                                    context,
                                    title: 'Confirm Booking'.tr,
                                    desc:
                                        'Are you sure you want to confirm this booking?'.tr +
                                        '\n' +
                                        AppFuns.priceWithCoin(summary.totalPrice, booking.currency) +
                                        'will be deducted from your balance'.tr,
                                    btnOkText: 'Confirm'.tr,
                                  );
                                  if (dialog != DismissType.btnOk) return;
                                  if (context.mounted) context.loaderOverlay.show();
                                  bool confirmed = false;
                                  try {
                                    final res = await travelersReviewController.confirmBooking(booking.id);
                                    if (res != null) {
                                      final passengers = res['passengers'] as List;
                                      for (var passenger in passengers) {
                                        travelersReviewController.setTicketNumber(passenger['passport_no'], passenger['eTicketNumber']);
                                      }
                                      booking = booking.copyWith(status: BookingStatus.fromJson(res['booking']['status']));
                                      bookingStatus = booking.status.name;
                                      confirmed = true;
                                    }
                                  } catch (e) {
                                    Get.snackbar("Error".tr, "Could not confirm booking".tr, snackPosition: SnackPosition.BOTTOM);
                                  }
                                  if (context.mounted) context.loaderOverlay.hide();
                                  setState(() {});
                                  if (confirmed && context.mounted) {
                                    await CustomDialog.success(
                                      context,
                                      title: 'Booking Confirmed'.tr,
                                      desc: 'Your booking has been confirmed successfully'.tr,
                                      btnOkText: 'Ok'.tr,
                                      showCancel: false,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConsts.secondaryColor,
                                  foregroundColor: AppConsts.primaryColor,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  textStyle: const TextStyle(
                                    fontSize: AppConsts.normal,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                icon: const Icon(Icons.check_circle_rounded, size: 18),
                                label: Text("Confirm Booking".tr),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // cancel — زر outlined أحمر
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final dialog = await CustomDialog.error(
                                    context,
                                    title: 'Cancel Pre-Booking'.tr,
                                    desc: 'Are you sure you want to cancel this pre-booking?'.tr,
                                    btnOkText: 'Cancel'.tr,
                                  );
                                  if (dialog != DismissType.btnOk) return;
                                  if (context.mounted) context.loaderOverlay.show();
                                  try {
                                    final res = await travelersReviewController.cancelPreBooking(booking.id);
                                    if (res != null) {
                                      booking = booking.copyWith(status: BookingStatus.fromJson(res['booking']['status']));
                                      bookingStatus = booking.status.name;
                                      cancelOn = _formatDateTime(res['flight']['cancelled_at'] != null ? DateTime.parse(res['flight']['cancelled_at']) : null);
                                      voidOn = _formatDateTime(res['flight']['void_time'] != null ? DateTime.parse(res['flight']['void_time']) : null);
                                    }
                                  } catch (e) {
                                    Get.snackbar("Error".tr, "Could not cancel pre-booking".tr, snackPosition: SnackPosition.BOTTOM);
                                  }
                                  if (context.mounted) context.loaderOverlay.hide();
                                  setState(() {});
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: cs.error,
                                  backgroundColor: isDark ? darkOutlineButtonFill : Colors.transparent,
                                  side: BorderSide(color: cs.error, width: 1.3),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  textStyle: const TextStyle(
                                    fontSize: AppConsts.normal,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                icon: const Icon(Icons.close_rounded, size: 18),
                                label: Text("Cancel".tr),
                              ),
                            ),
                          ],
                          if (booking.status == BookingStatus.confirmed && allowVoid()) ...[
                            // void — زر outlined أحمر بعرض كامل
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final dialog = await CustomDialog.error(
                                    context,
                                    title: 'Void Issue'.tr,
                                    desc: 'Are you sure you want to void this issue?'.tr,
                                    btnOkText: 'Void'.tr,
                                  );
                                  if (dialog != DismissType.btnOk) return;
                                  if (context.mounted) context.loaderOverlay.show();
                                  try {
                                    final res = await travelersReviewController.voidIssue(booking.id);
                                    if (res != null) {
                                      booking = booking.copyWith(status: BookingStatus.fromJson(res['booking']['status']));
                                      bookingStatus = booking.status.name;
                                      cancelOn = _formatDateTime(res['flight']['cancelled_at'] != null ? DateTime.parse(res['flight']['cancelled_at']) : null);
                                      voidOn = _formatDateTime(res['flight']['void_time'] != null ? DateTime.parse(res['flight']['void_time']) : null);
                                    }
                                  } catch (e) {
                                    Get.snackbar("Error".tr, "Could not void issue".tr, snackPosition: SnackPosition.BOTTOM);
                                  }
                                  if (context.mounted) context.loaderOverlay.hide();
                                  setState(() {});
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: cs.error,
                                  backgroundColor: isDark ? darkOutlineButtonFill : Colors.transparent,
                                  side: BorderSide(color: cs.error, width: 1.3),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  textStyle: const TextStyle(
                                    fontSize: AppConsts.normal,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                icon: const Icon(Icons.block_rounded, size: 18),
                                label: Text("Void".tr),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (timeLimit != null && booking.status == BookingStatus.preBooking) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: isDark
                                ? const Color(0xFF121A38)
                                : Colors.white,
                            border: Border.all(
                              color: AppConsts.secondaryColor
                                  .withValues(alpha: isDark ? 0.45 : 0.35),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppConsts.primaryColor.withValues(
                                  alpha: isDark ? 0.30 : 0.08,
                                ),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppConsts.secondaryColor
                                          .withValues(alpha: 0.16),
                                      border: Border.all(
                                        color: AppConsts.secondaryColor
                                            .withValues(alpha: 0.55),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.access_time_filled_rounded,
                                      color: AppConsts.secondaryColor,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 4,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: AppConsts.secondaryColor,
                                      borderRadius:
                                          BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Time Left".tr,
                                    style: TextStyle(
                                      fontSize: AppConsts.lg,
                                      fontWeight: FontWeight.w800,
                                      color: cs.onSurface,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                height: 1,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 2),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppConsts.secondaryColor
                                          .withValues(alpha: 0),
                                      AppConsts.secondaryColor
                                          .withValues(alpha: 0.45),
                                      AppConsts.secondaryColor
                                          .withValues(alpha: 0),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TimeRemaining(
                                timeLimit: timeLimit,
                                createdAt: widget.booking.createdOn,
                                expiredText: 'Expired'.tr,
                                showExpiredAsZeros: false,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      ...[
                        FirstTitle(title: "Flight".tr),
                        const SizedBox(height: 4),
                        FlightOfferCard(
                          offer: widget.offerDetail.offer,
                          showSeatLeft: false,
                          showBaggage: false,
                          onDetails: () {
                            // Get.to(() => FlightDetailPage(detail: widget.offerDetail, showContinueButton: false));
                            Get.to(
                              () => MoreFlightDetailPage(
                                flightOffer: widget.offerDetail.offer,
                                fareRules: widget.offerDetail.fareRules,
                                // revalidatedDetails: widget.offerDetail,
                                showContinueButton: false,
                              ),
                            );
                          },

                          showFare: false,
                        ),
                      ],
                      const SizedBox(height: 16),
                      Divider(),
                      const SizedBox(height: 16),

                      ...[
                        FirstTitle(title: "Booking".tr),
                        const SizedBox(height: 10),
                        _InfoCard(
                          children: [
                            _InfoRow(
                              label: "Number".tr,
                              value: booking.bookingId,
                              valueColor: const Color(0xFFC62828), // أحمر كما في الموقع — مميّز للحجز
                              monospace: true,
                              copyable: true,
                            ),
                            _InfoRow(
                              label: "PNR",
                              value: widget.pnr.isNotEmpty ? widget.pnr : "N/A".tr,
                              valueColor: AppConsts.secondaryColor, // ذهبي — نفس لون PNR في بطاقات الحجوزات
                              monospace: true,
                              copyable: true,
                            ),
                            _InfoRow(
                              label: "Created at".tr,
                              value: createdOn,
                            ),
                            if (voidOn != null)
                              _InfoRow(
                                label: "Void On".tr,
                                value: voidOn!,
                                valueColor: const Color(0xFF8E24AA),
                              ),
                            if (cancelOn != null && voidOn == null)
                              _InfoRow(
                                label: "Cancel On".tr,
                                value: cancelOn!,
                                valueColor: const Color(0xFFC62828),
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),

                      ...[
                        FirstTitle(title: "Travelers".tr),
                        const SizedBox(height: 10),
                        ...List.generate(travelersReviewController.travelers.length, (index) {
                          final traveler = travelersReviewController.travelers[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _TravelerCard(
                              index: index + 1,
                              fullName: traveler.passport.fullName,
                              dateOfBirth: AppFuns.replaceArabicNumbers(
                                intl.DateFormat('dd MMM yyyy', AppVars.lang).format(traveler.passport.dateOfBirth!),
                              ),
                              ticketNumber: traveler.ticketNumber,
                            ),
                          );
                        }),
                      ],

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      ...[FirstTitle(title: "Baggage".tr), FaringsBaggagesTable(context: context, data: baggagesData)],
                      const SizedBox(height: 16),
                      Divider(),
                      const SizedBox(height: 16),
                      ...[
                        FirstTitle(title: "Pricing".tr),
                        FaringsBaggagesTable(context: context, data: faringsData),
                        // total all — سطر بارز بلون ذهبي
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppConsts.secondaryColor.withValues(alpha: 0.12),
                            border: Border.all(
                              color: AppConsts.secondaryColor.withValues(alpha: 0.55),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "Total All".tr,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppConsts.lg,
                                  color: cs.onSurface,
                                ),
                              ),
                              const Spacer(),
                              SelectableText(
                                AppFuns.priceWithCoin(summary.totalPrice, booking.currency),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: AppConsts.xlg,
                                  color: AppConsts.secondaryColor,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 30),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              //   width: double.infinity,
              //   // height: 80,
              //   decoration: BoxDecoration(
              //     color: cs.surfaceContainer,
              //     borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              //     // shadow
              //     boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 5, blurRadius: 10, offset: const Offset(0, 2))],
              //   ),
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           mainAxisSize: MainAxisSize.min,
              //           children: [
              //             Text("Total".tr, style: const TextStyle(fontSize: AppConsts.lg)),
              //             const SizedBox(height: 8),
              //             SelectableText(
              //               AppFuns.priceWithCoin(summary.totalPrice, booking.currency),
              //               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: AppConsts.xxlg + 4),
              //             ),
              //           ],
              //         ),
              //       ),
              //       if (booking.status == BookingStatus.preBooking && !isExpired)
              //         IntrinsicWidth(
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.stretch,
              //             children: [
              //               // confirm
              //               ElevatedButton(
              //                 onPressed: () async {
              //                   final dialog = await CustomDialog.success(
              //                     context,
              //                     title: 'Confirm Booking'.tr,
              //                     desc:
              //                         'Are you sure you want to confirm this booking?'.tr +
              //                         '\n' +
              //                         AppFuns.priceWithCoin(summary.totalPrice, booking.currency) +
              //                         'will be deducted from your balance'.tr,
              //                     btnOkText: 'Confirm'.tr,
              //                   );
              //                   if (dialog != DismissType.btnOk) {
              //                     return;
              //                   }
              //                   if (context.mounted) context.loaderOverlay.show();
              //                   try {
              //                     final res = await travelersReviewController.confirmBooking(booking.id);
              //                     if (res != null) {
              //                       // update travelers by setTicketNumber
              //                       final passengers = res['passengers'] as List;
              //                       for (var passenger in passengers) {
              //                         travelersReviewController.setTicketNumber(passenger['passport_no'], passenger['eTicketNumber']);
              //                       }
              //                       print("res['booking']['status'] ${res['booking']['status']}");
              //                       booking = booking.copyWith(status: BookingStatus.fromJson(res['booking']['status']));
              //                       bookingStatus = booking.status.name;
              //                       print("booking.status.name: $bookingStatus");
              //                     }
              //                   } catch (e) {
              //                     Get.snackbar("Error".tr, "Could not confirm booking".tr, snackPosition: SnackPosition.BOTTOM);
              //                   }
              //                   if (context.mounted) context.loaderOverlay.hide();
              //                   setState(() {});
              //                 },
              //                 child: Text("Confirm Booking".tr),
              //               ),
              //               const SizedBox(height: 8),
              //               // cancel
              //               TextButton(
              //                 style: ElevatedButton.styleFrom(
              //                   foregroundColor: cs.error,
              //                   shape: RoundedRectangleBorder(
              //                     borderRadius: BorderRadius.circular(12),
              //                     side: BorderSide(color: cs.error),
              //                   ),
              //                 ),
              //                 onPressed: () async {
              //                   final dialog = await CustomDialog.error(
              //                     context,
              //                     title: 'Cancel Pre-Booking'.tr,
              //                     desc: 'Are you sure you want to cancel this pre-booking?'.tr,
              //                     btnOkText: 'Cancel'.tr,
              //                   );
              //                   if (dialog != DismissType.btnOk) {
              //                     return;
              //                   }
              //                   if (context.mounted) context.loaderOverlay.show();
              //                   try {
              //                     final res = await travelersReviewController.cancelPreBooking(booking.id);
              //                     if (res != null) {
              //                       booking = booking.copyWith(status: BookingStatus.fromJson(res['booking']['status']));
              //                       bookingStatus = booking.status.name;
              //                       DateTime? cancelledAt = res['flight']['cancelled_at'] != null
              //                           ? DateTime.parse(res['flight']['cancelled_at'])
              //                           : null;
              //                       DateTime? voidTime = res['flight']['void_time'] != null
              //                           ? DateTime.parse(res['flight']['void_time'])
              //                           : null;
              //                       cancelOn = _formatDateTime(cancelledAt);
              //                       voidOn = _formatDateTime(voidTime);
              //                       print("booking.status.name: $bookingStatus");
              //                     }
              //                   } catch (e) {
              //                     Get.snackbar("Error".tr, "Could not cancel pre-booking".tr, snackPosition: SnackPosition.BOTTOM);
              //                     print("cancelPreBooking error: $e");
              //                   }
              //                   if (context.mounted) context.loaderOverlay.hide();
              //                   setState(() {});
              //                 },
              //                 child: Text("Cancel".tr),
              //               ),
              //             ],
              //           ),
              //         ),
              //       if (booking.status == BookingStatus.confirmed && allowVoid())
              //         IntrinsicWidth(
              //           child: Column(
              //             children: [
              //               // void
              //               TextButton(
              //                 style: ElevatedButton.styleFrom(
              //                   foregroundColor: cs.error,
              //                   shape: RoundedRectangleBorder(
              //                     borderRadius: BorderRadius.circular(12),
              //                     side: BorderSide(color: cs.error),
              //                   ),
              //                 ),
              //                 onPressed: () async {
              //                   final dialog = await CustomDialog.error(
              //                     context,
              //                     title: 'Void Issue'.tr,
              //                     desc: 'Are you sure you want to void this issue?'.tr,
              //                     btnOkText: 'Void'.tr,
              //                   );
              //                   if (dialog != DismissType.btnOk) {
              //                     return;
              //                   }
              //                   if (context.mounted) context.loaderOverlay.show();
              //                   try {
              //                     final res = await travelersReviewController.voidIssue(booking.id);
              //                     if (res != null) {
              //                       booking = booking.copyWith(status: BookingStatus.fromJson(res['booking']['status']));
              //                       bookingStatus = booking.status.name;
              //                       DateTime? cancelledAt = res['flight']['cancelled_at'] != null
              //                           ? DateTime.parse(res['flight']['cancelled_at'])
              //                           : null;
              //                       DateTime? voidTime = res['flight']['void_time'] != null
              //                           ? DateTime.parse(res['flight']['void_time'])
              //                           : null;
              //                       cancelOn = _formatDateTime(cancelledAt);
              //                       voidOn = _formatDateTime(voidTime);
              //                       print("booking.status.name: $bookingStatus");
              //                     }
              //                   } catch (e) {
              //                     Get.snackbar("Error".tr, "Could not void issue".tr, snackPosition: SnackPosition.BOTTOM);
              //                     print("❌ voidIssue error: $e");
              //                   }
              //                   if (context.mounted) context.loaderOverlay.hide();
              //                   setState(() {});
              //                 },
              //                 child: Text("Void".tr),
              //               ),
              //             ],
              //           ),
              //         ),
              //     ],
              //   ),
              // ),
            
            
            
            ],
          ),
        ),
      ),
    );
  }
}

class StatusCard extends StatelessWidget {
  const StatusCard({super.key, required this.cs, required this.bookingStatus});

  final ColorScheme cs;
  final String bookingStatus;

  ({Color color, IconData icon}) _visuals(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // مقارنة مرنة (بدون حساسيّة لحالة الأحرف/المسافات) حتى لا يفشل الشرط لو جاء "Confirmed" أو فيه فراغ
    final s = bookingStatus.trim().toLowerCase();

    bool matches(BookingStatus status) => s == status.name.toLowerCase();

    // مؤكّد: أخضر واضح في الثيمين
    if (matches(BookingStatus.confirmed) || s == 'confirm' || s == 'issued' || s == 'ok') {
      return (
        color: isDark ? const Color(0xFF2FB96A) : const Color(0xFF16A34A),
        icon: Icons.check_circle_rounded,
      );
    }
    if (matches(BookingStatus.preBooking) || matches(BookingStatus.pending) || s == 'pre-book') {
      return (color: const Color(0xFFF59E0B), icon: Icons.schedule_rounded);
    }
    if (matches(BookingStatus.canceled) || matches(BookingStatus.expiry) || s == 'cancelled') {
      return (color: const Color(0xFFC62828), icon: Icons.cancel_rounded);
    }
    // Void: أحمر صريح وموحَّد في الثيمين (نفس أحمر اللايت)
    if (matches(BookingStatus.voided) || matches(BookingStatus.voide) || s == 'void') {
      return (
        color: const Color(0xFFC62828),
        icon: Icons.block_rounded,
      );
    }
    return (color: const Color(0xFF78909C), icon: Icons.help_outline_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final v = _visuals(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: v.color,
        boxShadow: [
          BoxShadow(
            color: v.color.withValues(alpha: 0.30),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.20),
            ),
            alignment: Alignment.center,
            child: Icon(v.icon, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text(
            bookingStatus.tr,
            style: const TextStyle(
              fontSize: AppConsts.xlg,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class FirstTitle extends StatelessWidget {
  final String title;
  final Color? color;
  const FirstTitle({super.key, required this.title, this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppConsts.secondaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: AppConsts.xlg,
            fontWeight: FontWeight.bold,
            color: color ?? cs.onSurface,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class SecondTitle extends StatelessWidget {
  final String title;
  const SecondTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: AppConsts.lg, fontWeight: FontWeight.bold),
    );
  }
}

String? _formatDateTime(DateTime? d) {
  if (d == null) return null;
  final s = intl.DateFormat('dd - MMM - yyyy | hh:mm:ss a', AppVars.lang).format(d);
  return AppFuns.replaceArabicNumbers(s);
}

/// بطاقة حاوية أنيقة — بحدّ ناعم وخلفية متكيّفة مع الثيم
class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        // ليلي: لوحة أوضح قليلاً من الخلفية + حد ذهبي خفيف
        color: isDark ? const Color(0xFF121A38) : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppConsts.secondaryColor.withValues(alpha: 0.38)
              : cs.outlineVariant.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        children: children,
      ),
    );
  }
}

/// صفّ معلومة بنمط "تسمية | قيمة" — مع فاصل ناعم بين الصفوف
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool monospace;
  final bool copyable;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.monospace = false,
    this.copyable = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: AppConsts.normal,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppConsts.normal,
                      color: valueColor ?? cs.onSurface,
                      fontWeight: FontWeight.bold,
                      letterSpacing: monospace ? 0.6 : 0,
                    ),
                  ),
                ),
              ),
              if (copyable) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    Get.snackbar(
                      "Copied".tr,
                      value,
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.copy_rounded,
                      size: 14,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ],
    );
  }
}

/// بطاقة مسافر — Avatar + اسم + تفاصيل مع إمكانية نسخ رقم التذكرة
class _TravelerCard extends StatelessWidget {
  final int index;
  final String fullName;
  final String dateOfBirth;
  final String? ticketNumber;

  const _TravelerCard({
    required this.index,
    required this.fullName,
    required this.dateOfBirth,
    this.ticketNumber,
  });

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasTicket = ticketNumber != null && ticketNumber!.isNotEmpty && ticketNumber != 'N/A';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121A38) : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppConsts.secondaryColor.withValues(alpha: 0.38)
              : cs.outlineVariant.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Avatar ذهبي صغير برقم المسافر
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppConsts.secondaryColor, Color(0xFFD99C2F)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppConsts.secondaryColor.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(fullName),
                  style: const TextStyle(
                    color: AppConsts.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppConsts.lg,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Traveler".tr + " #$index",
                      style: TextStyle(
                        fontSize: AppConsts.sm,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(
            height: 1,
            thickness: 1,
            color: cs.outlineVariant.withValues(alpha: 0.3),
          ),
          _InfoRow(label: "Date of Birth".tr, value: dateOfBirth),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Text(
                  "Ticket".tr,
                  style: TextStyle(
                    fontSize: AppConsts.normal,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: hasTicket
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32).withValues(alpha: 0.14),
                              border: Border.all(
                                color: const Color(0xFF2E7D32).withValues(alpha: 0.55),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              ticketNumber!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF2E7D32),
                                fontSize: AppConsts.normal,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          )
                        : Text(
                            'N/A'.tr,
                            style: TextStyle(
                              fontSize: AppConsts.normal,
                              color: cs.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                  ),
                ),
                if (hasTicket) ...[
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: ticketNumber!));
                      Get.snackbar(
                        "Copied".tr,
                        ticketNumber!,
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 2),
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 14,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
