import 'package:alzajeltravel/model/booking_data_model.dart';
import 'package:alzajeltravel/utils/enums.dart';
import 'package:alzajeltravel/utils/widgets/custom_dialog.dart';
import 'package:alzajeltravel/view/frame/time_remaining.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
  const IssuingPage({
    super.key,
    required this.offerDetail,
    required this.travelers,
    required this.contact,
    required this.pnr,
    required this.booking,
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

  @override
  void initState() {
    super.initState();
    travelersReviewController = Get.put(TravelersReviewController(widget.travelers));
    booking = widget.booking;
    final tmpBaggage = widget.offerDetail.offer.baggagePerSegment.first;
    summary = travelersReviewController.summary;

    if (summary.adultCount > 0) {
      faringsData.add({"type": "Adult".tr + " ${summary.adultCount}", "Total fare": "${summary.adultTotalFare}"});
      baggagesData.add({"type": "Adult".tr, "Weight": AppFuns.formatBaggageWeight(tmpBaggage)});
    }
    if (summary.childCount > 0) {
      faringsData.add({"type": "Child".tr + " ${summary.childCount}", "Total fare": "${summary.childTotalFare}"});
      baggagesData.add({"type": "Child".tr, "Weight": "10kg"});
    }
    if (summary.infantLapCount > 0) {
      faringsData.add({"type": "Infant".tr + " ${summary.infantLapCount}", "Total fare": "${summary.infantLapTotalFare}"});
      baggagesData.add({"type": "Infant".tr, "Weight": "5kg"});
    }
    bookingStatus = booking.status.name;
    timeLimit = widget.offerDetail.timeLimit;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Issuing".tr),
          leading: IconButton(
            tooltip: "Back".tr,
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Get.back();
            },
          ),
          actions: [
            TextButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                minimumSize: const Size(100, 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: cs.primaryContainer, width: 1),
                ),
              ),
              onPressed: () {
                Get.to(
                  PrintIssuing(
                    bookingData: {},
                    offerDetail: widget.offerDetail,
                    travelers: widget.travelers,
                    contact: widget.contact,
                    baggagesData: baggagesData,
                    faringsData: faringsData,
                  ),
                );
              },
      
              icon: const Icon(Icons.print),
              label: Text("Print".tr),
            ),
            const SizedBox(width: 12),
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
                    if(timeLimit != null && booking.status == BookingStatus.preBooking) ...[
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
                              Text(
                                "Time Left".tr,
                                style: TextStyle(
                                  fontSize: AppConsts.lg
                                ),
                              ),
                              SizedBox(height: 8), 
                              TimeRemaining(
                                timeLimit: timeLimit,
                                expiredText: 'Expired'.tr,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),
                    ...[
                      FirstTitle(title: "Booking".tr),
                      const SizedBox(height: 4),
      
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Ink(
                          color: cs.surfaceContainer,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // LEFT (labels) like the travelers design
                              Ink(
                                color: cs.surface,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  child: IntrinsicWidth(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SecondTitle(title: "PNR"),
                                        Divider(thickness: 1),
                                        SecondTitle(title: "Number".tr),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
      
                              // RIGHT (values)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SecondTitle(title: (widget.pnr.isNotEmpty ? widget.pnr : "N/A")),
                                      const Divider(thickness: 1),
                                      SecondTitle(title: booking.bookingId),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Divider(),
      
                    ...[
                      FirstTitle(title: "Travelers".tr),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: travelersReviewController.travelers.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            final traveler = travelersReviewController.travelers[index];
                            return Ink(
                              color: cs.surfaceContainer,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 4),
                                  Ink(
                                    color: cs.surface,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      child: IntrinsicWidth(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          spacing: 3,
                                          children: [
                                            SecondTitle(title: "Full Name".tr),
                                            const Divider(thickness: 1),
                                            SecondTitle(title: "Date of Birth".tr),
                                            const Divider(thickness: 1),
                                            SecondTitle(title: "Ticket".tr),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 3,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown, // يصغّر النص إذا ما يكفي
                                            alignment: AlignmentDirectional.centerStart, // يبقيه لليسار
                                            child: Text(
                                              traveler.passport.fullName,
                                              style: TextStyle(
                                                fontSize: AppConsts.lg, // الحجم الأقصى
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const Divider(thickness: 1),
                                          SecondTitle(
                                            title: AppFuns.replaceArabicNumbers(
                                              DateFormat('dd-MM-yyyy').format(traveler.passport.dateOfBirth!),
                                            ),
                                          ),
                                          const Divider(thickness: 1),
                                          SecondTitle(title: traveler.ticketNumber ?? 'N/A'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: const Divider(thickness: 2)),
                        ),
                      ),
                    ],
      
                    const SizedBox(height: 16),
                    const Divider(),
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
                              // revalidatedDetails: widget.offerDetail,
                            ),
                          );
                        },
                        showFare: false,
                      ),
                    ],
                    const SizedBox(height: 16),
                    Divider(),
                    ...[FirstTitle(title: "Baggage".tr), buildTable(context, baggagesData)],
                    const SizedBox(height: 16),
                    Divider(),
                    ...[
                      FirstTitle(title: "Pricing".tr),
                      buildTable(context, faringsData),
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
      
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              width: double.infinity,
              // height: 80,
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                // shadow
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Total".tr,
                          style: const TextStyle(fontSize: AppConsts.lg),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          AppFuns.priceWithCoin(summary.totalPrice, booking.currency), 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: AppConsts.xxlg + 4),
                        ),
                      ],
                    ),
                  ), 
                  if(booking.status == BookingStatus.preBooking)
                    IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
            
                              final dialog = await CustomDialog.success(
                                context, 
                                title: 'Confirm Booking'.tr, 
                                desc: 'Are you sure you want to confirm this booking?'.tr +
                                '\n' +
                                AppFuns.priceWithCoin(summary.totalPrice, booking.currency) +
                                'will be deducted from your balance'.tr, 
                                btnOkText: 'Confirm'.tr, 
                              );
            
                              if(dialog != DismissType.btnOk){
                                return;
                              }

                              if(context.mounted) context.loaderOverlay.show();
                              try {
                                final res = await travelersReviewController.confirmBooking(booking.id);
                                if (res != null) {
                                  // update travelers by setTicketNumber
                                  final passengers = res['passengers'] as List;
                                  for (var passenger in passengers) {
                                    travelersReviewController.setTicketNumber(passenger['passport_no'], passenger['eTicketNumber']);
                                  }
                                  print("res['booking']['status'] ${res['booking']['status']}");
                                  booking = booking.copyWith(
                                    status: BookingStatus.fromJson(res['booking']['status']),  
                                  );
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
                          const SizedBox(height: 8),
                          // cancel
                          TextButton(
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
            
                              if(dialog != DismissType.btnOk){ 
                                return;
                              }
            
                              if(context.mounted) context.loaderOverlay.show();
                              try {
                                final res = await travelersReviewController.cancelPreBooking(booking.id);
                                if (res != null) {
                                  booking = booking.copyWith(
                                    status: BookingStatus.fromJson(res['booking']['status']),  
                                  );
                                  bookingStatus = booking.status.name; 
                                  print("booking.status.name: $bookingStatus"); 
                                } 
                              } catch (e) {
                                Get.snackbar("Error".tr, "Could not cancel pre-booking".tr, snackPosition: SnackPosition.BOTTOM);
                              }
                              if (context.mounted) context.loaderOverlay.hide();
                              setState(() {});
            
                            },
                            child: Text("Cancel".tr),
                          ),
                        ],
                      ),
                    ),
                  if(booking.status == BookingStatus.confirmed)
                    IntrinsicWidth(
                      child: Column( 
                        children: [
                          // void
                          TextButton(
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
            
                              if(dialog != DismissType.btnOk){ 
                                return;
                              }
            
                              if(context.mounted) context.loaderOverlay.show();
                              try {
                                final res = await travelersReviewController.voidIssue(booking.id);
                                if (res != null) {
                                  booking = booking.copyWith(
                                    status: BookingStatus.fromJson(res['booking']['status']),  
                                  );
                                  bookingStatus = booking.status.name; 
                                  print("booking.status.name: $bookingStatus"); 
                                } 
                              } catch (e) {
                                Get.snackbar("Error".tr, "Could not void issue".tr, snackPosition: SnackPosition.BOTTOM);
                              }
                              if (context.mounted) context.loaderOverlay.hide();
                              setState(() {});
            
                            },
                            child: Text("Void".tr),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
      
          ],
        ),
      ),
    );
  }

  Widget buildTable(
    BuildContext context,
    List<Map<String, dynamic>> data, {
    String? title, // اختياري: عنوان الجدول (مثلاً "Baggage allowance")
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // لو ما في بيانات نرجّع كرت صغير بسيط
    if (data.isEmpty) {
      return Card(
        color: cs.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text('No data'.tr, style: theme.textTheme.bodyMedium),
        ),
      );
    }

    // نأخذ الأعمدة من أول عنصر (Map)
    final columnsKeys = data.first.keys.toList();

    bool isNumericColumn(String key) {
      final k = key.toLowerCase();
      return k.contains('weight') ||
          k.contains('price') ||
          k.contains('amount') ||
          k.contains('qty') ||
          k.contains('quantity') ||
          k.contains('fare') ||
          k.contains('total');
    }

    String labelFromKey(String key) {
      if (key.isEmpty) return key;
      // نضبط أول حرف كابيتال ونترك الباقي مثل ما هو
      return key[0].toUpperCase() + key.substring(1);
    }

    return Card(
      color: cs.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Divider(color: cs.outline.withOpacity(0.4), height: 16, thickness: 0.7),
            ],

            // الجدول نفسه
            DataTable(
              horizontalMargin: 0,
              columnSpacing: 32,
              headingRowHeight: 36,
              dataRowMinHeight: 32,
              dataRowMaxHeight: 40,
              headingTextStyle: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary),
              dataTextStyle: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface),
              headingRowColor: MaterialStateColor.resolveWith((states) => cs.surface.withOpacity(0.7)),
              columns: [
                for (final key in columnsKeys)
                  DataColumn(
                    label: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(labelFromKey(key).tr, style: TextStyle(color: cs.primaryContainer)),
                    ),
                    numeric: isNumericColumn(key),
                  ),
              ],
              rows: [
                for (final row in data) DataRow(
                  cells: [
                    for (final key in columnsKeys) 
                      DataCell(
                        Text('${row[key] ?? ''}') 
                      )
                  ]
                ),
              ],
            ),
          ],
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
    if(bookingStatus == BookingStatus.preBooking.name){
      color = cs.secondary;
      icon = Icons.info;
    }
    else if (bookingStatus == BookingStatus.confirmed.name) {
      color = cs.secondaryFixed;
      icon = Icons.check_circle;
    }
    else if (
      bookingStatus == BookingStatus.canceled.name || 
      bookingStatus == BookingStatus.expiry.name) {
      color = cs.tertiary;
      icon = Icons.error;
    } 
    else if (bookingStatus == BookingStatus.voided.name) {
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
