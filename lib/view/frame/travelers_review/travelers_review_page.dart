import 'package:alzajeltravel/controller/bookings_report/trip_detail/flight_detail.dart';
import 'package:alzajeltravel/model/booking_data_model.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/routes.dart';
import 'package:alzajeltravel/view/frame/flights/flight_detail/more_flight_detail_page.dart';
import 'package:alzajeltravel/view/frame/flights/flight_offers_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:loader_overlay/loader_overlay.dart';
import 'package:alzajeltravel/controller/flight/flight_detail_controller.dart';
import 'package:alzajeltravel/controller/travelers_review/travelers_review_controller.dart';
import 'package:alzajeltravel/model/contact_model.dart';
import 'package:alzajeltravel/model/passport/traveler_review/traveler_review_model.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/view/frame/flights/flight_detail/flight_detail_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TravelersReviewPage extends StatefulWidget {
  final List<TravelerReviewModel> travelers;
  final int insertId;
  final ContactModel contact;

  const TravelersReviewPage({super.key, required this.travelers, required this.insertId, required this.contact});

  /// Chip بسيطة لعرض معلومة (ممكن تستخدم لاحقًا لو حبيت)
  static Widget infoChip({required IconData icon, required String label, required String value, required ThemeData theme}) {
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text('$label: ', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.8))),
          Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  State<TravelersReviewPage> createState() => _TravelersReviewPageState();
}

class _TravelersReviewPageState extends State<TravelersReviewPage> {
  final FlightDetailApiController flightDetailApiController = Get.put(FlightDetailApiController());

  int _currentTravelerIndex = 0; // 👈 مؤشر السلايدر

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GetBuilder<TravelersReviewController>(
      init: TravelersReviewController(widget.travelers),
      builder: (c) {
        final offerDetail = flightDetailApiController.revalidatedDetails.value;
        return SafeArea(
          bottom: true,
          top: false,
          left: false,
          right: false,
          child: PopScope(

            canPop: false, // نمنع الرجوع تلقائيًا ونقرر نحن بعد التأكيد
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;

              final ok = await AppFuns.confirmExit(
                title: "Exit".tr,
                message: "Are you sure you want to exit?".tr,
              );

              if (ok && context.mounted) {
                Navigator.of(context).pop(result); 
                // أو فقط pop() إذا ما تحتاج result
              }
            },

            child: Scaffold(
              appBar: AppBar(title: Text('Travelers review'.tr)),
              body: Column(
                children: [
                  // ======= المحتوى الرئيسي القابل للتمرير =======
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 33),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [

                          if (offerDetail != null) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 0), 
                              child: FlightOfferCard(
                                offer: offerDetail.offer,
                                showSeatLeft: false,
                                showBaggage: false,
                                onDetails: () {
                                  // Get.to(() => FlightDetailPage(detail: widget.offerDetail, showContinueButton: false));
                                  Get.to(
                                    () => MoreFlightDetailPage(
                                      flightOffer: offerDetail.offer,
                                      fareRules: offerDetail.fareRules,
                                      showContinueButton: false,
                                      // revalidatedDetails: widget.offerDetail,
                                    ),
                                  );
                                },
                                showFare: false,
                              ),
                            ),
                            SizedBox(height: 8),
                          ],
            
                          // ======= قائمة المسافرين كسلايدر =======
                          if (c.travelers.isNotEmpty) ...[
                            const SizedBox(height: 0),

                                  
                      ...[
                        SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: FirstTitle(title: "Travelers data".tr), 
                        ),
                        SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: cs.outlineVariant),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: c.travelers.length,
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                final traveler = c.travelers[index];
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
                                                SecondTitle(title: "Document number".tr),
                                                const Divider(thickness: 1),
                                                SecondTitle(title: "Date of Birth".tr),
                                                const Divider(thickness: 1),
                                                SecondTitle(title: "Date of expiry".tr),
                                                const Divider(thickness: 1),
                                                SecondTitle(title: "Sex".tr),
                                                const Divider(thickness: 1),
                                                SecondTitle(title: "Ticket".tr),
                                                const Divider(thickness: 1),
                                                SecondTitle(title: "Nationality".tr),
                                                const Divider(thickness: 1),
                                                SecondTitle(title: "ISSUING COUNTRY".tr),
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
                                                title: traveler.passport.documentNumber??'N/A',
                                              ),
                                              const Divider(thickness: 1),
                                              SecondTitle(
                                                title: AppFuns.replaceArabicNumbers(
                                                  intl.DateFormat('dd-MM-yyyy').format(traveler.passport.dateOfBirth!),
                                                ),
                                              ),
                                              const Divider(thickness: 1),
                                              SecondTitle(
                                                title: AppFuns.replaceArabicNumbers(
                                                  intl.DateFormat('dd-MM-yyyy').format(traveler.passport.dateOfExpiry!),
                                                ),
                                              ),
                                              const Divider(thickness: 1),
                                              SecondTitle(
                                                title: traveler.passport.sex?.label??'N/A',
                                              ),
                                              const Divider(thickness: 1),
                                              SecondTitle(title: traveler.passport.nationality?.name[AppVars.lang] ?? 'N/A'),
                                              const Divider(thickness: 1),
                                              SecondTitle(title: traveler.passport.issuingCountry?.name[AppVars.lang] ?? 'N/A'),
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
                        ),
                      ],
      
            
                            // CarouselSlider.builder(
                            //   itemCount: c.travelers.length,
                            //   itemBuilder: (context, index, realIndex) {
                            //     return Padding(
                            //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            //       child: _buildTravelerTile(
                            //         context: context,
                            //         index: index,
                            //         traveler: c.travelers[index],
                            //         travelersCount: c.travelers.length,
                            //       ),
                            //     );
                            //   },
                            //   options: CarouselOptions(
                            //     viewportFraction: 0.98, // الكرت ياخذ 90% من عرض الشاشة
                            //     enlargeCenterPage: true, // يكبر الكرت اللي في النص
                            //     enableInfiniteScroll: false, // بدون سكول لا نهائي
                            //     height: 300, // عدّلها حسب ارتفاع الكرت عندك
                            //     onPageChanged: (index, reason) {
                            //       setState(() {
                            //         _currentTravelerIndex = index;
                            //       });
                            //     },
                            //   ),
                            // ),
            


                            const SizedBox(height: 0),
            
                          ],
            
                          // ======= بيانات الاتصال =======
                          // Padding(padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8), child: _buildContactTile(context)),
                        ],
                      ),
                    ),
                  ),
            
                  // ======= شريط التلخيص + زر التأكيد =======
                  _buildSummaryBar(context, c, cs),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  //  Widgets فرعية
  // ---------------------------------------------------------------------------

  Widget _buildTravelerTile({
    required BuildContext context,
    required int index,
    required TravelerReviewModel traveler,
    required int travelersCount,
  }) {
    final cs = Theme.of(context).colorScheme;
    final p = traveler.passport;

    final ageGroupLabel = p.ageGroupLabel;

    return Card(
      color: cs.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 12, left: 12, right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 👈 عشان نحط الـ dots تحت
          children: [
            // ---------------- معلومات المسافر ----------------
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                   
                  children: [
                    // العنوان: Traveler 1: Adult
                    Row(
                      children: [
                        Icon(CupertinoIcons.person_circle, color: cs.primaryContainer, size: 28,),
                        const SizedBox(width: 8),
                        Text(
                          '${'Traveler'.tr} ${index + 1}: ',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: AppConsts.xlg),
                        ),
                        const SizedBox(width: 8),
                        Text(ageGroupLabel, style: const TextStyle(fontSize: AppConsts.xlg),),
                        const Spacer(),
                        Text('${index + 1} / $travelersCount'),
                      ],
                    ),
                    const SizedBox(height: 8),
                        
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8, end: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [ 
                          ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.person, color: cs.primaryContainer, size: 28,),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Full name'.tr, style: const TextStyle(fontSize: AppConsts.lg, fontWeight: FontWeight.bold),),
                                    Text(p.fullName, style: const TextStyle(fontSize: AppConsts.normal),),
                                  ],
                                ),
                              ],
                            ),
                          ],
                          ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(FontAwesomeIcons.solidIdCard, color: cs.primaryContainer, size: 26,),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Passport number'.tr, style: const TextStyle(fontSize: AppConsts.lg, fontWeight: FontWeight.bold),),
                                    Text(p.documentNumber??'_', style: const TextStyle(fontSize: AppConsts.normal),), 
                                  ],
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 4),
                          Divider(),
                          const SizedBox(height: 4),
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Date of birth'.tr, style: const TextStyle(fontWeight: FontWeight.bold),),  
                                      Text(AppFuns.formatDobPretty(p.dateOfBirth,)), 
                                      const SizedBox(height: 4),
                                      Text('Nationality'.tr, style: const TextStyle(fontWeight: FontWeight.bold),),  
                                      Text(p.nationality?.name['en'] ?? '-',), 
                                    ],
                                  ),
                                ),
                                VerticalDivider(),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.only(start: 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Date of expiry'.tr, style: const TextStyle(fontWeight: FontWeight.bold),),  
                                        Text(AppFuns.formatDobPretty(p.dateOfExpiry)), 
                                        const SizedBox(height: 4), 
                                        Text('Issuing country'.tr, style: const TextStyle(fontWeight: FontWeight.bold),),  
                                        Text(p.issuingCountry?.name['en'] ?? '-'), 
                                      ],
                                    ),
                                  ),
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
            ),
      
      
            // ---------------- الـ dots داخل الكرت ----------------
            Center(
              child: AnimatedSmoothIndicator(
                activeIndex: _currentTravelerIndex, // 👈 من الـ State
                count: travelersCount, // = c.travelers.length
                effect: ExpandingDotsEffect(
                  dotHeight: 6,
                  dotWidth: 6,
                  spacing: 6,
                  activeDotColor: cs.primaryContainer,
                  dotColor: cs.outline.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildContactTile(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final firstName = widget.contact.firstName;
    final lastName = widget.contact.lastName;
    final fullname = (firstName.isEmpty && lastName.isEmpty) ? '-' : '$firstName $lastName';

    final email = widget.contact.email;

    final dialCode = widget.contact.phoneCountry.dialcode;
    final phoneNumber = widget.contact.phone;

    final phoneLabel = (dialCode.isEmpty && phoneNumber.isEmpty) ? '-' : '${dialCode.isNotEmpty ? dialCode + ' ' : ''}$phoneNumber';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        elevation: 2, 
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          tileColor: cs.surfaceContainer,
          onTap: () {},
          title: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.list_alt, color: cs.primaryContainer, size: 28,),
                  const SizedBox(width: 8),
                  Text(
                    'Contact'.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: AppConsts.xlg),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(thickness: 1.5,),
              const SizedBox(height: 8),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2, 
              children: [
                // const SizedBox(height: 4),
                ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.person, 
                        color: cs.primaryContainer,
                        size: 28, 
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Full name'.tr, style: const TextStyle(fontSize: AppConsts.lg, fontWeight: FontWeight.bold),),
                          Text(fullname, style: const TextStyle(fontSize: AppConsts.lg),),
                        ],
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 2),
                Divider(),
                const SizedBox(height: 2),
                ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.email, 
                        color: cs.primaryContainer,
                        size: 28, 
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email'.tr, style: const TextStyle(fontSize: AppConsts.lg, fontWeight: FontWeight.bold),),
                          Text(email.isEmpty ? '-' : email, style: const TextStyle(fontSize: AppConsts.normal),),
                        ],
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 2),
                Divider(),
                const SizedBox(height: 2),
                ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.phone, 
                        color: cs.primaryContainer,
                        size: 28, 
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [ 
                          Text('Phone'.tr, style: const TextStyle(fontSize: AppConsts.lg, fontWeight: FontWeight.bold),),
                          Text('+' + phoneLabel, textDirection: TextDirection.ltr, style: const TextStyle(fontSize: AppConsts.normal),),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );


  }

  Widget _buildSummaryBar(BuildContext context, TravelersReviewController c, ColorScheme cs) {
    final offerDetail = flightDetailApiController.revalidatedDetails.value;
    final currency = offerDetail?.offer.currency ?? 'USD';
    print("c.summary.childCount: ${c.travelers.last.ageGroupLabel}");
    return Container(
      
      width: double.infinity,
      padding: const EdgeInsetsDirectional.only(top: 12, start: 16, end: 16, bottom: 26),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primaryFixed,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ======= تفاصيل الأسعار =======
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Adult
                    Wrap(
                      direction: Axis.horizontal,
                      children: [
                        Text('Adult'.tr + ' ${c.summary.adultCount}', style: const TextStyle(fontSize: AppConsts.lg)),
                        Text(
                          ': ${AppFuns.priceWithCoin(c.summary.adultTotalFare ?? 0.0, currency)}',
                          style: const TextStyle(fontSize: AppConsts.lg),
                        ),
                      ],
                    ),

                    // Child
                    if (c.summary.childTotalFare != null)
                      Wrap(
                        direction: Axis.horizontal,
                        children: [
                          Text('Child'.tr + ' ${c.summary.childCount}', style: const TextStyle(fontSize: AppConsts.lg)),
                          Text(
                            ': ${AppFuns.priceWithCoin(c.summary.childTotalFare ?? 0.0, currency)}',
                            style: const TextStyle(fontSize: AppConsts.lg),
                          ),
                        ],
                      ),

                    // Infant
                    if (c.summary.infantLapTotalFare != null)
                      Wrap(
                        direction: Axis.horizontal,
                        children: [
                          Text('Infant'.tr + ' ${c.summary.infantLapCount}', style: const TextStyle(fontSize: AppConsts.lg)),
                          Text(
                            ': ${AppFuns.priceWithCoin(c.summary.infantLapTotalFare ?? 0.0, currency)}',
                            style: const TextStyle(fontSize: AppConsts.lg),
                          ),
                        ],
                      ),

                    // 🔹 Divider الآن بعرض الـ Column (يعني على قد النص)
                    const SizedBox(height: 8),
                    Divider(color: cs.primaryFixed),

                    // Total
                    Wrap(
                      direction: Axis.horizontal,
                      children: [
                        Text(
                          'Total'.tr,
                          style: TextStyle(color: cs.primaryContainer, fontSize: AppConsts.xxlg, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          ': ${AppFuns.priceWithCoin(c.summary.totalPrice, currency)}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: cs.primaryContainer, fontSize: AppConsts.xxlg),
                        ),
                        Text(" "),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // ======= زر تأكيد الحجز =======
          ElevatedButton.icon(
            onPressed: () async {
              context.loaderOverlay.show(
                progress: "Your reservation is being confirmed".tr,
              );
              final preRes = await c.preBooking(widget.insertId.toString()); 
              if(preRes != null && preRes is Map<String, dynamic>) {
                final booking = BookingDataModel.fromJson(preRes['booking']);
                final flightDetail = FlightDetail.flightDetail(preRes['flight']);

                for (var segment in flightDetail.offer.segments) {
                  print("DepartureTerminal: ${segment.fromTerminal}");
                  print("ArrivalTerminal: ${segment.toTerminal}");
                }

                Get.offNamedUntil( 
                  Routes.prebookingAndIssueing.path,
                  (route) => route.settings.name == Routes.frame.path,
                  arguments: {
                    "offerDetail": flightDetail,
                    "travelers": c.travelers,
                    "contact": widget.contact,
                    "pnr": preRes["PNR"] ?? "",
                    "booking": booking,
                  },
                );
              }
              if(context.mounted) context.loaderOverlay.hide();
            },
            icon: Text('Pre-Booking'.tr),
            label: const Icon(Icons.arrow_forward),
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
