// issuing_page_web.dart
import 'package:alzajeltravel/controller/bookings_report/bookings_report_controller.dart';
import 'package:alzajeltravel/model/booking_data_model.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/enums.dart';
import 'package:alzajeltravel/utils/widgets/booking_data_table.dart';
import 'package:alzajeltravel/utils/widgets/custom_dialog.dart';
import 'package:alzajeltravel/utils/widgets/farings_baggages_table.dart';
import 'package:alzajeltravel/utils/widgets/travelers_data_table.dart';
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

class IssuingPageWeb extends StatefulWidget {
  final RevalidatedFlightModel offerDetail;
  final List<TravelerReviewModel> travelers;
  final ContactModel contact;
  final String pnr;
  final BookingDataModel booking;
  final String fromPage;
  const IssuingPageWeb({
    super.key,
    required this.offerDetail,
    required this.travelers,
    required this.contact,
    required this.pnr,
    required this.booking,
    required this.fromPage,
  });

  @override
  State<IssuingPageWeb> createState() => _IssuingPageWebState();
}

class _IssuingPageWebState extends State<IssuingPageWeb> {
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

  List<Map<String, dynamic>> bookingTableData = [];

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


final Map<String, dynamic> bookingRow = {
  "PNR".tr: (widget.pnr.isNotEmpty ? widget.pnr : "N/A".tr),
  "Booking Number".tr: booking.bookingId,
  "Created At".tr: createdOn,
};

if (voidOn != null) {
  bookingRow["Void On".tr] = voidOn!;
} else if (cancelOn != null) {
  bookingRow["Cancel On".tr] = cancelOn!;
}

bookingTableData = [bookingRow];

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


final travelersTableData = travelersReviewController.travelers.map((t) {
  String na = "N/A".tr;

  String safe(dynamic v) {
    if (v == null) return na;
    final s = v.toString().trim();
    return (s.isEmpty || s == "null") ? na : s;
  }

  String safeLangName(dynamic obj) {
    // obj expected like: obj?.name[AppVars.lang]
    if (obj == null) return na;
    try {
      final v = obj.name[AppVars.lang];
      return safe(v);
    } catch (_) {
      return na;
    }
  }

  return <String, String>{
    "full_name": safe(t.passport.fullName),
    "dob": t.passport.dateOfBirth == null
        ? na
        : AppFuns.replaceArabicNumbers(
            intl.DateFormat('dd-MMMM-yyyy', AppVars.lang).format(t.passport.dateOfBirth!),
          ),
    "sex": safe(t.passport.sex?.label),
    "passport_number": safe(t.passport.documentNumber),
    "nationality": safeLangName(t.passport.nationality),
    "issuing_country": safeLangName(t.passport.issuingCountry),
    "date_of_expiry": t.passport.dateOfExpiry == null
        ? na
        : AppFuns.replaceArabicNumbers(
            intl.DateFormat('dd-MMMM-yyyy', AppVars.lang).format(t.passport.dateOfExpiry!),
          ),
    "ticket": safe(t.ticketNumber ?? na),
  };
}).toList();

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
          appBar: AppBar(
            title: Text("Issuing".tr),
            // leading: IconButton(
            //   tooltip: "Back".tr,
            //   icon: const Icon(Icons.arrow_back),
            //   onPressed: () {
            //     Get.back();
            //   },
            // ),
            actions: [
              if (widget.booking.status == BookingStatus.confirmed)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12),
                  child: TextButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      minimumSize: const Size(100, 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: cs.primaryContainer, width: 1),
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
                            // confirm
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final dialog = await CustomDialog.success(
                                    context,
                                    title: 'Confirm Booking'.tr,
                                    desc:
                                        'Are you sure you want to confirm this booking?'.tr +
                                        '\n' +
                                        AppFuns.priceWithCoin(summary.totalPrice, booking.currency) +
                                        'will be deducted from your balance'.tr,
                                    btnOkText: 'Confirm'.tr,
                                  );
                              
                                  if (dialog != DismissType.btnOk) {
                                    return;
                                  }
                              
                                  if (context.mounted) context.loaderOverlay.show();
                                  try {
                                    final res = await travelersReviewController.confirmBooking(booking.id);
                                    if (res != null) {
                                      // update travelers by setTicketNumber
                                      final passengers = res['passengers'] as List;
                                      for (var passenger in passengers) {
                                        travelersReviewController.setTicketNumber(passenger['passport_no'], passenger['eTicketNumber']);
                                      }
                                      print("res['booking']['status'] ${res['booking']['status']}");
                                      booking = booking.copyWith(status: BookingStatus.fromJson(res['booking']['status']));
                                      bookingStatus = booking.status.name;
                                      print("booking.status.name: $bookingStatus");
                                    }
                                  } catch (e) {
                                    Get.snackbar("Error".tr, "Could not confirm booking".tr, snackPosition: SnackPosition.BOTTOM);
                                  }
                                  if (context.mounted) context.loaderOverlay.hide();
                                  setState(() {});
                                },
                                child: Text("Confirm Booking".tr),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // cancel
                            Expanded(
                              child: TextButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: cs.error,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: cs.error),
                                  ),
                                ),
                                onPressed: () async {
                                  final dialog = await CustomDialog.error(
                                    context,
                                    title: 'Cancel Pre-Booking'.tr,
                                    desc: 'Are you sure you want to cancel this pre-booking?'.tr,
                                    btnOkText: 'Cancel'.tr,
                                  );
                              
                                  if (dialog != DismissType.btnOk) {
                                    return;
                                  }
                              
                                  if (context.mounted) context.loaderOverlay.show();
                                  try {
                                    final res = await travelersReviewController.cancelPreBooking(booking.id);
                                    if (res != null) {
                                      booking = booking.copyWith(status: BookingStatus.fromJson(res['booking']['status']));
                                      bookingStatus = booking.status.name;
                              
                                      DateTime? cancelledAt = res['flight']['cancelled_at'] != null
                                          ? DateTime.parse(res['flight']['cancelled_at'])
                                          : null;
                                      DateTime? voidTime = res['flight']['void_time'] != null
                                          ? DateTime.parse(res['flight']['void_time'])
                                          : null;
                                      cancelOn = _formatDateTime(cancelledAt);
                                      voidOn = _formatDateTime(voidTime);
                                      print("booking.status.name: $bookingStatus");
                                    }
                                  } catch (e) {
                                    Get.snackbar("Error".tr, "Could not cancel pre-booking".tr, snackPosition: SnackPosition.BOTTOM);
                                    print("cancelPreBooking error: $e");
                                  }
                                  if (context.mounted) context.loaderOverlay.hide();
                                  setState(() {});
                                },
                                child: Text("Cancel".tr),
                              ),
                            ),
                          ],
                          if (booking.status == BookingStatus.confirmed && allowVoid()) ...[
                            // void
                            Expanded(
                              child: TextButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: cs.error,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: cs.error),
                                  ),
                                ),
                                onPressed: () async {
                                  final dialog = await CustomDialog.error(
                                    context,
                                    title: 'Void Issue'.tr,
                                    desc: 'Are you sure you want to void this issue?'.tr,
                                    btnOkText: 'Void'.tr,
                                  );
                              
                                  if (dialog != DismissType.btnOk) {
                                    return;
                                  }
                              
                                  if (context.mounted) context.loaderOverlay.show();
                                  try {
                                    final res = await travelersReviewController.voidIssue(booking.id);
                                    if (res != null) {
                                      booking = booking.copyWith(status: BookingStatus.fromJson(res['booking']['status']));
                                      bookingStatus = booking.status.name;
                              
                                      DateTime? cancelledAt = res['flight']['cancelled_at'] != null
                                          ? DateTime.parse(res['flight']['cancelled_at'])
                                          : null;
                              
                                      DateTime? voidTime = res['flight']['void_time'] != null
                                          ? DateTime.parse(res['flight']['void_time'])
                                          : null;
                              
                                      cancelOn = _formatDateTime(cancelledAt);
                                      voidOn = _formatDateTime(voidTime);
                                      print("booking.status.name: $bookingStatus");
                                    }
                                  } catch (e) {
                                    Get.snackbar("Error".tr, "Could not void issue".tr, snackPosition: SnackPosition.BOTTOM);
                                    print("❌ voidIssue error: $e");
                                  }
                                  if (context.mounted) context.loaderOverlay.hide();
                                  setState(() {});
                                },
                                child: Text("Void".tr),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (timeLimit != null && booking.status == BookingStatus.preBooking) ...[
                        const SizedBox(height: 12),
                        Card(
                          child: Container(
                            padding: EdgeInsets.only(top: 12, bottom: 16),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              // color: cs.secondary,
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Time Left".tr,
                                        style: TextStyle(fontSize: AppConsts.lg, fontWeight: FontWeight.bold),
                                      ),
                                      Icon(Icons.access_time, color: cs.primary),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Divider(indent: 12, endIndent: 12, thickness: 2),

                                TimeRemaining(
                                  timeLimit: timeLimit,
                                  createdAt: widget.booking.createdOn,
                                  expiredText: 'Expired'.tr,
                                  showExpiredAsZeros: false,
                                ),
                              ],
                            ),
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
const SizedBox(height: 4),

BookingDataTable(
  pnr: widget.pnr,
  bookingNumber: booking.bookingId,
  createdAt: createdOn,
  voidOn: voidOn,
  cancelOn: cancelOn,
),

                      ],

                      const SizedBox(height: 16),
                      Divider(),
                      const SizedBox(height: 16),

                      ...[

FirstTitle(title: "Travelers".tr),
const SizedBox(height: 4),

TravelersDataTable(
  rows: travelersTableData,
),                      ],

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
                        // total all
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              SecondTitle(title: "Total All"),
                              const Spacer(),
                              SelectableText(
                                AppFuns.priceWithCoin(summary.totalPrice, booking.currency),
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: AppConsts.lg),
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

  @override
  Widget build(BuildContext context) {
    Color color = cs.secondary;
    IconData icon = Icons.info;
    if (bookingStatus == BookingStatus.preBooking.name) {
      color = cs.secondary;
      icon = Icons.info;
    } else if (bookingStatus == BookingStatus.confirmed.name) {
      color = cs.secondaryFixed;
      icon = Icons.check_circle;
    } else if (bookingStatus == BookingStatus.canceled.name || bookingStatus == BookingStatus.expiry.name) {
      color = cs.tertiary;
      icon = Icons.error;
    } else if (bookingStatus == BookingStatus.voided.name) {
      color = cs.error;
      icon = Icons.error;
    }
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: cs.onPrimary),
          SizedBox(width: 12),
          // FirstTitle(title: "Status".tr + " " + bookingStatus.tr, color: cs.onPrimary),
          FirstTitle(title: bookingStatus.tr, color: cs.onPrimary),
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
    return Text(
      title,
      style: TextStyle(fontSize: AppConsts.xlg, fontWeight: FontWeight.bold, color: color),
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
  final s = intl.DateFormat('dd - MMM - yyyy | hh:mm a', AppVars.lang).format(d);
  final multiLine = s.replaceAll(' | ', '\n'); // التاريخ سطر + الوقت سطر
  return AppFuns.replaceArabicNumbers(multiLine);
}