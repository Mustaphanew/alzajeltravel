import 'package:alzajeltravel/repo/airline_repo.dart';
import 'package:alzajeltravel/repo/airport_repo.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/view/frame/flights/flight_detail/flight_detail_page.dart';
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
  final FlightOfferModel flightOffer;
  final RevalidatedFlightModel? revalidatedDetails;
  final List<FareRule> fareRules;

  const MoreFlightDetailPage({
    super.key,
    required this.flightOffer,
    this.revalidatedDetails,
    required this.fareRules,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final timeFormat = DateFormat('hh:mm a', 'en');
    final dateFormat = DateFormat('EEE, MMM dd', 'en'); // Wed, Dec 10

    // لو فيه revalidated نشتغل عليه، غير كذا نستخدم flightOffer العادي
    final FlightOfferModel offer = revalidatedDetails?.offer ?? flightOffer;

    // legs = [outbound, inbound?]
    final List<FlightLegModel> legs = offer.legs;

    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        appBar: AppBar(title: Text('More Flight details'.tr)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
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

              // ---------- معلومات عامة مشتركة ----------
              const SizedBox(height: 16),
              _InfoRow(label: "Cabin".tr, value: offer.cabinClassText),
              const SizedBox(height: 4),
              _InfoRow(
                label: "Baggage".tr,
                value: (offer.baggageInfo ?? '_').split(',').first,
              ),
              const SizedBox(height: 12),
              _InfoRow(
                label: "Cancellation fee".tr,
                value: AppFuns.priceWithCoin(20, "\$"),
              ),
              const SizedBox(height: 4),
              _InfoRow(
                label: "Change fee".tr,
                value: AppFuns.priceWithCoin(15, "\$"),
              ),

              const SizedBox(height: 30),
              
              if (fareRules.isNotEmpty)
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    title: Text("Fare rules".tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: fareRules!.map((rule) => FareRuleTile(rule: rule)).toList(),
                  ),
                ),
              
              const SizedBox(height: 30),

            ],
          ),
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
          Text(
            '${"Trip route".tr}: '
            '${legIndex == 0 ? "Departure".tr : "Return".tr}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: AppConsts.xlg,
            ),
          ),
          const SizedBox(height: 8),

          // نحدد startOffset لهذا الـ leg ثم نحدّث offset للـ leg اللي بعده
          Builder(
            builder: (_) {
              final leg = legs[legIndex];
              final startOffsetForLeg = globalSegmentOffset;
              globalSegmentOffset += leg.segments.length;

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
  }) {
    final segments = leg.segments;

    return ListView.separated(
      itemCount: segments.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final seg = segments[index];
        final depTime = timeFormat.format(seg.departureDateTime);
        final arrTime = timeFormat.format(seg.arrivalDateTime);
        final depDate = dateFormat.format(seg.departureDateTime);
        final arrDate = dateFormat.format(seg.arrivalDateTime);

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
            if (segments.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  "Flight".tr + " " + (index + 1).toString() + " " + "of".tr + " " + segments.length.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: cs.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // السطر العلوي (شعار الشركة + اسم + رقم الرحلة)
                    Row(
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
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [ 
                                Text( 
                                  (AirlineRepo.searchByCode(seg.marketingAirlineCode) != null) ?
                                  AirlineRepo.searchByCode(seg.marketingAirlineCode)!.name[AppVars.lang] : "",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${seg.marketingAirlineCode}${seg.marketingAirlineNumber}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            // Aircraft
                            Text("Aircraft".tr + ": " + seg.equipmentNumber),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // الخط الزمني (من → إلى)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // الخط العمودي
                          Column(
                            children: [
                              Container(
                                  width: 2, height: 12, color: cs.primary),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: cs.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: cs.primary.withOpacity(0.5),
                                ),
                              ),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: cs.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                  width: 2, height: 12, color: cs.primary),
                            ],
                          ),
                          const SizedBox(width: 12),

                          // نصوص المدن / الأوقات
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ===== من =====
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // اسم المطار (من)
                                          Text(
                                            fromName,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          // كود المطار (من)
                                          Text(
                                            seg.fromCode,
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                          Text(
                                            "Terminal".tr + ": " + (seg.fromTerminal?? '_'),
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          depTime,
                                          style: theme
                                              .textTheme.titleLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          depDate,
                                          style: theme.textTheme.bodySmall,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Travel time
                                Text(
                                  '${"Travel time:".tr} ${seg.journeyText ?? '_'}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.textTheme.bodyMedium?.color
                                        ?.withOpacity(0.8),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // ===== إلى =====
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // اسم المطار (إلى)
                                          Text(
                                            toName,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          // كود المطار (إلى)
                                          Text(
                                            seg.toCode,
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                          Text(
                                            "Terminal".tr + ": " + (seg.toTerminal?? '_'),
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          arrTime,
                                          style: theme
                                              .textTheme.titleLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          arrDate,
                                          style: theme.textTheme.bodySmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // لو حاب تضيف عرض للأمتعة الخاصة بهذه السجمنت
                                if (segmentBaggage != null &&
                                    segmentBaggage.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  _InfoRow(
                                    label: "Baggage".tr,
                                    value: segmentBaggage,
                                  ),
                                ],

                                
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

            const SizedBox(height: 0),
            
          ],
        );
      },
      separatorBuilder: (context, index) {
        // index هنا بين 0 و segments.length - 2 داخل هذا الـ leg
        final seg = segments[index];
        final nextSeg = segments[index + 1];

        final layText = seg.layoverText;
        if (layText == null || layText.isEmpty) {
          return const SizedBox(height: 16);
        }

        final cityName = nextSeg.fromName.split(',').first;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$layText ${"layover in".tr} $cityName',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              const Divider(),
              
            ],
          ),
        );
      },
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
