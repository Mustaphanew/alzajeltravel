import 'package:alzajeltravel/controller/travelers_controller.dart';
import 'package:alzajeltravel/model/flight/flight_segment_model.dart';
import 'package:alzajeltravel/repo/airline_repo.dart';
import 'package:alzajeltravel/repo/airport_repo.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/widgets/gradient_bg_container.dart';
import 'package:alzajeltravel/view/frame/flights/flight_detail/flight_detail_page.dart';
import 'package:alzajeltravel/view/frame/passport/passports_forms.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:alzajeltravel/model/flight/flight_offer_model.dart';
import 'package:alzajeltravel/model/flight/flight_leg_model.dart';
import 'package:alzajeltravel/model/flight/revalidated_flight_model.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/widgets.dart';

class MoreFlightDetailPage extends StatelessWidget {
  final VoidCallback? onBook;
  final VoidCallback? onOtherPrices;
  final bool showContinueButton;

  final FlightOfferModel flightOffer;
  final RevalidatedFlightModel? revalidatedDetails;
  final List<FareRule> fareRules;

  const MoreFlightDetailPage({
    super.key,
    this.onBook,
    this.onOtherPrices,
    required this.flightOffer,
    this.revalidatedDetails,
    required this.fareRules,
    this.showContinueButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final timeFormat = DateFormat('hh:mm a', AppVars.lang);
    final dateFormat = DateFormat('EEE, dd MMM', AppVars.lang); // Wed, 10 Dec

    // لو فيه revalidated نشتغل عليه، غير كذا نستخدم flightOffer العادي
    final FlightOfferModel offer = revalidatedDetails?.offer ?? flightOffer;

    // legs = [outbound, inbound?]
    final List<FlightLegModel> legs = offer.legs;

    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Flight details'.tr),
          centerTitle: true,
        ),
        body: Column( 
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // ---------- عرض المسارات (ذهاب / عودة) ----------
                    _buildLegSections(
                      context: context,
                      theme: theme,
                      cs: cs,
                      offer: offer,
                      legs: legs,
                      timeFormat: timeFormat,
                      dateFormat: dateFormat,
                    ),
              
                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          title: Text("Other info".tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: Color(0xffe4e4e4),
                          // childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              color: Theme.of(context).cardTheme.color,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 8),
                                  _InfoRow(
                                    label: "Exchange".tr,
                                    value: AppFuns.priceWithCoin(20, "USD"),
                                  ),
                                  const SizedBox(height: 8),
                                  _InfoRow(
                                    label: "Cancel".tr,
                                    value: AppFuns.priceWithCoin(10, "USD"),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),  
                    
                    if (fareRules.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ExpansionTile(
                            title: Text("Fare rules".tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            children: fareRules.map((rule) => FareRuleTile(rule: rule)).toList(),
                          ),
                        ),
                      ),

                    const SizedBox(height: 30),
              
              
              
                  ],
                ),
              ),
            ),
          
            Container( 
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32, top: 15),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withOpacity(0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                borderRadius: BorderRadius.circular(12),
              ),
              child: BottomSection(
                offer: offer,
                fareRules: fareRules,
                showContinueButton: showContinueButton,
                parent: this,
              ),
            ),

          ],
        ),
      ),
    );
  }

  /// يبني كل المسارات (ذهاب + عودة إن وجدت) مع ربط صحيح للأمتعة لكل سيجمنت
  Widget _buildLegSections({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme cs,
    required FlightOfferModel offer,
    required List<FlightLegModel> legs,
    required DateFormat timeFormat,
    required DateFormat dateFormat,
  }) {
    int globalSegmentOffset = 0; // index في baggagePerSegment

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int legIndex = 0; legIndex < legs.length; legIndex++) ...[
          const SizedBox(height: 4),

          // عنوان المسار
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 0),
          //   child: GradientBgContainer(
          //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          //     width: double.infinity,
          //     child: Text( 
          //       '${"Trip route".tr}: ' '${legIndex == 0 ? "Departure".tr : "Return".tr}', 
          //       style: theme.textTheme.titleMedium?.copyWith(
          //         fontWeight: FontWeight.w700,
          //         fontSize: AppConsts.xlg,
          //       ),
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 8),

          // نحدد startOffset لهذا الـ leg ثم نحدّث offset للـ leg اللي بعده
          Builder(
            builder: (_) {
              final leg = legs[legIndex];
              final startOffsetForLeg = globalSegmentOffset;
              globalSegmentOffset += leg.segments.length;
              final String pathTitle = '${"Trip route".tr}: ' '${legIndex == 0 ? "Departure".tr : "Return".tr}';

              return _buildSingleLegList(
                context: context,
                theme: theme,
                cs: cs,
                offer: offer,
                leg: leg,
                legIndex: legIndex,
                startOffset: startOffsetForLeg,
                timeFormat: timeFormat,
                dateFormat: dateFormat,
                pathTitle: pathTitle,
              );
            },
          ),

          const SizedBox(height: 16),
        ],
      ],
    );
  }

  /// يبني ListView لسجمنتات leg واحد (ذهاب أو عودة)
  Widget _buildSingleLegList({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme cs,
    required FlightOfferModel offer,
    required FlightLegModel leg,
    required int legIndex,
    required int startOffset, // من هنا نبدأ نقرأ baggagePerSegment
    required DateFormat timeFormat,
    required DateFormat dateFormat,
    required String pathTitle,
  }) {
    final segments = leg.segments;

    return Card(
      // color: cs.error,
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

              GradientBgContainer(
                padding: const EdgeInsets.all(8.0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                width: double.infinity,
                height: 40,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  pathTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: AppConsts.lg,
                  ),
                ),
              ),

          ListView.separated(
            itemCount: segments.length,
            padding: EdgeInsets.symmetric(horizontal: 0),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final seg = segments[index];
              final depTime = AppFuns.replaceArabicNumbers(timeFormat.format(seg.departureDateTime));
              final arrTime = AppFuns.replaceArabicNumbers(timeFormat.format(seg.arrivalDateTime));
              final depDate = AppFuns.replaceArabicNumbers(dateFormat.format(seg.departureDateTime));
              final arrDate = AppFuns.replaceArabicNumbers(dateFormat.format(seg.arrivalDateTime));
          
              String fromName = "";
              String toName = "";
          
              if (AirportRepo.searchByCode(seg.fromCode) != null) {
                fromName = AirportRepo.searchByCode(seg.fromCode)!.name[AppVars.lang];
              } else {
                fromName = seg.fromName;
              }
              if (AirportRepo.searchByCode(seg.toCode) != null) {
                toName = AirportRepo.searchByCode(seg.toCode)!.name[AppVars.lang];
              } else {
                toName = seg.toName;
              }
          
              // index العالمي في مصفوفة الأمتعة
              final int globalIndex = startOffset + index;
          
              // الأمتعة لهذه السجمنت
              String? segmentBaggage;
              if (offer.baggagePerSegment.length > globalIndex &&
                  offer.baggagePerSegment[globalIndex].isNotEmpty) {
                final raw = offer.baggagePerSegment[globalIndex];
                segmentBaggage = raw
                    .replaceAll('Piece', 'Piece'.tr)
                    .replaceAll('KG', 'KG'.tr);
              }
          
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // لو في أكثر من سيجمنت في هذا المسار نعرض رقم السجمنت
                  // if (segments.length > 1)
                  //   Padding(
                  //     padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                  //     child: Text(
                  //       "Flight".tr + " " + (index + 1).toString() + " " + "of".tr + " " + segments.length.toString(),
                  //       style: theme.textTheme.bodyMedium?.copyWith(
                  //         fontWeight: FontWeight.w600,
                  //       ),
                  //     ),
                  //   ),
          
          
          
                  SegCard(
                    seg: seg,
                    fromCode: seg.fromCode,
                    fromName: fromName, 
                    depTime: depTime, 
                    depDate: depDate,
                    toCode: seg.toCode,
                    toName: toName, 
                    arrTime: arrTime, 
                    arrDate: arrDate, 
                    segmentBaggage: segmentBaggage,
                    cabin: (seg.cabinClassText.replaceAll("Standard", "")).tr,
                  ),
          
                  const SizedBox(height: 0),
                  
                ],
              );
            },
            separatorBuilder: (context, index) {
              // index هنا بين 0 و segments.length - 2 داخل هذا الـ leg
              final seg = segments[index];
              final nextSeg = segments[index + 1];
          
              final layText = AppFuns.formatHourMinuteSecond(seg.layoverText);
              if (layText == null || layText.isEmpty) {
                return const SizedBox(height: 16);
              }
          
              final cityName = AirportRepo.searchByCode(nextSeg.fromCode).name[AppVars.lang];
          
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 20,
                            color: cs.surfaceContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${"layover in".tr} $cityName ${"for".tr} $layText',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.surfaceContainer,
                            ),
                          ),
                        ],
                      ),
                    ),              
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(child: Text(label, style: textTheme.bodyMedium)),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        
      ],
    );
  }
}



class SegCard extends StatelessWidget {
  const SegCard({
    super.key,
    required this.seg,
    required this.fromName,
    required this.fromCode,
    required this.depTime,
    required this.depDate,
    required this.toName,
    required this.toCode,
    required this.arrTime,
    required this.arrDate,
    required this.segmentBaggage,
    required this.cabin,
  });

  final FlightSegmentModel seg;
  final String fromName;
  final String fromCode;
  final String depTime;
  final String depDate;
  final String toName;
  final String toCode;
  final String arrTime;
  final String arrDate;
  final String? segmentBaggage;
  final String cabin;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          // السطر العلوي (شعار الشركة + اسم + رقم الرحلة)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 28,
                width: 28,
                child: CacheImg(
                  AppFuns.airlineImgURL(seg.marketingAirlineCode,),
                  sizeCircleLoading: 14,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [ 
                        Expanded(
                          child: Text( 
                            (AirlineRepo.searchByCode(seg.marketingAirlineCode) != null) ?
                            AirlineRepo.searchByCode(seg.marketingAirlineCode)!.name[AppVars.lang] : "",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
    
                      ], 
                    ),
                    const SizedBox(height: 2),
                    // Aircraft
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text( 
                          "Aircraft".tr + ": " + seg.equipmentNumber,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${seg.marketingAirlineCode}-${seg.marketingAirlineNumber}',
                          ),
                        ),
                      
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
      
          const SizedBox(height: 6),
          const Divider(),
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  child: Column(
                    children: [
                      Text(depDate, textAlign: TextAlign.center,),
                      const SizedBox(height: 2),
                      Text(
                        depTime,
                        style: TextStyle(
                          fontSize: AppConsts.xlg,
                          fontWeight: FontWeight.w600,
                          height: 0
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fromName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppConsts.normal,
                          fontWeight: FontWeight.w600,
                          height: 0
                        ),
                      ),
                      const SizedBox(height: 4), 
                      Text(fromCode),
                    ],
                  ),
                ),
              ),
              
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      AppFuns.formatHourMinuteSecond(seg.journeyText ?? '_'),
                      style: TextStyle(
                        fontFamily: AppConsts.font,
                        fontSize: AppConsts.sm,
                        fontWeight: FontWeight.w600,
                        height: 0
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              DividerLine(),
                              RotatedBox(
                                quarterTurns: (AppVars.lang == 'en')? 1: -1,
                                child: Icon(
                                  Icons.flight,
                                  color: cs.primary,
                                  size: 28,
                                ),
                              ),
                            ],
                          ), 
                        ),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (segmentBaggage != null && segmentBaggage!.isNotEmpty) 
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: cs.secondaryFixed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          "Baggage".tr + ": " + segmentBaggage!,
                          style: TextStyle(
                            fontFamily: AppConsts.font,
                            fontSize: AppConsts.sm,
                            fontWeight: FontWeight.w600,
                            height: 0
                          ),
                        ),
                      ),
                    ],
                  ),
              ),
    
              Expanded(
                child: Column(
                  children: [
                    Text(arrDate, textAlign: TextAlign.center,),
                    const SizedBox(height: 2),
                    Text(
                      arrTime,
                      style: TextStyle(
                        fontSize: AppConsts.xlg,
                        fontWeight: FontWeight.w600,
                        height: 0
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      toName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppConsts.normal,
                        fontWeight: FontWeight.w600,
                        height: 0
                      ),
                    ),
                    const SizedBox(height: 4), 
                    Text(toCode),
                  ],
                ),
              ),
    
            ],
          ),
    
          // الخط الزمني (من → إلى)
          // IntrinsicHeight(
          //   child: Row(
          //     crossAxisAlignment: CrossAxisAlignment.stretch,
          //     children: [
          //       // نصوص المدن / الأوقات
          //       Expanded(
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             // ===== من =====
          //             Row(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 Expanded(
          //                   child: Column(
          //                     crossAxisAlignment:
          //                         CrossAxisAlignment.start,
          //                     children: [
          //                       // اسم المطار (من)
          //                       Text(
          //                         fromName,
          //                         style: theme.textTheme.titleMedium
          //                             ?.copyWith(
          //                           fontWeight: FontWeight.w600,
          //                         ),
          //                         maxLines: 2,
          //                         overflow: TextOverflow.ellipsis,
          //                       ),
          //                       const SizedBox(height: 4),
          //                       // كود المطار (من)
          //                       Text(
          //                         seg.fromCode,
          //                         style: theme.textTheme.bodyMedium,
          //                       ),
          //                       Text(
          //                         "Terminal".tr + ": " + (seg.fromTerminal?? '_'),
          //                         style: theme.textTheme.bodyMedium,
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //                 const SizedBox(width: 8),
          //                 Column(
          //                   crossAxisAlignment:
          //                       CrossAxisAlignment.end,
          //                   children: [
          //                     Text(
          //                       depTime,
          //                       style: theme
          //                           .textTheme.titleLarge
          //                           ?.copyWith(
          //                         fontWeight: FontWeight.w600,
          //                       ),
          //                     ),
          //                     const SizedBox(height: 4),
          //                     Text(
          //                       depDate,
          //                       style: theme.textTheme.bodySmall,
          //                       maxLines: 2,
          //                       overflow: TextOverflow.ellipsis,
          //                     ),
          //                   ],
          //                 ),
          //               ],
          //             ),
          //             const SizedBox(height: 16),
          //             // Travel time
          //             Text(
          //               '${"Travel time".tr}: ${seg.journeyText ?? '_'}',
          //               style: theme.textTheme.bodyMedium?.copyWith( 
          //                 color: theme.textTheme.bodyMedium?.color
          //                     ?.withOpacity(0.8),
          //               ),
          //             ),
          //             const SizedBox(height: 16),
          //             // ===== إلى =====
          //             Row(
          //               crossAxisAlignment: CrossAxisAlignment.start,          
          //               children: [
          //                 Expanded(
          //                   child: Column(
          //                     crossAxisAlignment:
          //                         CrossAxisAlignment.start,
          //                     children: [
          //                       // اسم المطار (إلى)
          //                       Text(
          //                         toName,
          //                         style: theme.textTheme.titleMedium
          //                             ?.copyWith(
          //                           fontWeight: FontWeight.w600,
          //                         ),
          //                         maxLines: 2,
          //                         overflow: TextOverflow.ellipsis,
          //                       ),
          //                       const SizedBox(height: 4),
          //                       // كود المطار (إلى)
          //                       Text(
          //                         seg.toCode,
          //                         style: theme.textTheme.bodyMedium,
          //                       ),
          //                       Text(
          //                         "Terminal".tr + ": " + (seg.toTerminal?? '_'),
          //                         style: theme.textTheme.bodyMedium,
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //                 const SizedBox(width: 8),
          //                 Column(
          //                   crossAxisAlignment:
          //                       CrossAxisAlignment.end,
          //                   children: [
          //                     Text(
          //                       arrTime,
          //                       style: theme
          //                           .textTheme.titleLarge
          //                           ?.copyWith(
          //                         fontWeight: FontWeight.w600,
          //                       ),
          //                     ),
          //                     const SizedBox(height: 4),
          //                     Text(
          //                       arrDate,
          //                       style: theme.textTheme.bodySmall,
          //                       maxLines: 1,
          //                       overflow: TextOverflow.ellipsis,
          //                     ),
          //                   ],
          //                 ),
          //               ],
          //             ),           
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          
          
          // لو حاب تضيف عرض للأمتعة الخاصة بهذه السجمنت
          // if (segmentBaggage != null && segmentBaggage!.isNotEmpty) ...[
          //   const SizedBox(height: 12),
          //   _InfoRow(
          //     label: "Baggage".tr,
          //     value: segmentBaggage!,
          //   ),
          // ],
          
          
        ],
      ),
    );
  }
}



class BottomSection extends StatefulWidget {
  const BottomSection({
    super.key, 
    required this.offer,
    required this.fareRules,
    required this.showContinueButton,
    this.parent,
  });

  final FlightOfferModel offer;
  final List<FareRule> fareRules;
  final bool showContinueButton;
  final MoreFlightDetailPage? parent;

  @override
  State<BottomSection> createState() => _BottomSectionState();
}

class _BottomSectionState extends State<BottomSection> {
  final TravelersController travelersController = Get.find();

  String _formatTotal(num value) {
    final formatter = NumberFormat('#,##0.00', 'en');
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // اليسار: السعر + ملخص
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Trip total".tr, style: textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    AppFuns.priceWithCoin(widget.offer.totalAmount, widget.offer.currency),
                    style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () {
                      // BottomSheet لملخص السعر لاحقاً
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text("View price summary".tr),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // اليمين: زر Check out
            if (widget.showContinueButton)
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final adults = travelersController.adultsCounter;
                    final children = travelersController.childrenCounter;
                    final infantsInLap = travelersController.infantsInLapCounter;

                    Get.to(() => PassportsFormsPage(
                      adultsCounter: adults, childrenCounter: children, infantsInLapCounter: infantsInLap,
                    ));
                  },
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 28)),
                  label: const Icon(Icons.arrow_forward),
                  icon: Text("Continue".tr),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),
        // ====== الأزرار ======
        if (widget.parent != null && (widget.parent!.onBook != null || widget.parent!.onOtherPrices != null))
          Row(
            children: [ 
              if (widget.parent!.onBook != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.parent!.onBook!,
                    icon: const Icon(Icons.flight_takeoff),
                    label: Text("Book now".tr),
                  ),
                ),
              if (widget.parent!.onBook != null && widget.parent!.onOtherPrices != null) ...[const SizedBox(width: 8)],
              if (widget.parent!.onOtherPrices != null) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.secondary,
                      foregroundColor: cs.shadow,
                    ),
                    onPressed: widget.parent!.onOtherPrices,
                    icon: const Icon(Icons.attach_money),
                    label: Text("Other Prices".tr),
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }
}


