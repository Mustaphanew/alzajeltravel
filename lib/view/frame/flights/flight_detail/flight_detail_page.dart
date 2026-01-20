import 'package:alzajeltravel/repo/airline_repo.dart';
import 'package:alzajeltravel/repo/airport_repo.dart';
import 'package:alzajeltravel/utils/app_vars.dart'; 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:alzajeltravel/controller/travelers_controller.dart';
import 'package:alzajeltravel/model/flight/flight_offer_model.dart';
import 'package:alzajeltravel/model/flight/flight_leg_model.dart';
import 'package:alzajeltravel/model/flight/revalidated_flight_model.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/widgets.dart';

import 'package:alzajeltravel/view/frame/flights/flight_detail/more_flight_detail_page.dart';
import 'package:alzajeltravel/view/frame/passport/passports_forms.dart';

class FlightDetailPage extends StatefulWidget {
  final VoidCallback? onBook;
  final VoidCallback? onOtherPrices;

  const FlightDetailPage({super.key, required this.detail, required this.showContinueButton, this.onBook, this.onOtherPrices});

  final RevalidatedFlightModel detail;
  final bool showContinueButton;

  @override
  State<FlightDetailPage> createState() => _FlightDetailPageState();
}

class _FlightDetailPageState extends State<FlightDetailPage> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final offer = widget.detail.offer;

    return Scaffold(
      appBar: AppBar(title: Text("Flight details".tr)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // الكرت الرئيسي: يلخّص الذهاب + العودة (إن وجدت)
                    FlightMainCard(revalidatedDetails: widget.detail),
                    const SizedBox(height: 8),

                    // تفاصيل إضافية
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        title: Text("Flight details".tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                        childrenPadding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
                        children: [_FlightExtraDetails(offer: offer, detail: widget.detail)],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // قواعد السعر
                    if (widget.detail.fareRules.isNotEmpty)
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ExpansionTile(
                          title: Text("Fare rules".tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                          childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          children: widget.detail.fareRules.map((rule) => FareRuleTile(rule: rule)).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // شريط السعر في الأسفل
            Container(
              width: double.infinity,
              // height: 150,
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                border: Border(top: BorderSide(color: cs.outlineVariant, width: 0.7)),
              ),
              child: _TripTotalSection(
                parent: widget,
                offer: offer, fareRules: widget.detail.fareRules, showContinueButton: widget.showContinueButton),
            ),
          ],
        ),
      ),
    );
  }
}

/// كرت الملخّص الرئيسي:
/// - يعرض اتجاه الذهاب دائماً (outbound)
/// - لو الرحلة Roundtrip وفيها inbound، يعرض اتجاه العودة تحته مع Divider
/// - السعر وزر Details مرّة واحدة فقط
class FlightMainCard extends StatelessWidget {
  const FlightMainCard({super.key, required this.revalidatedDetails});

  final RevalidatedFlightModel revalidatedDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final FlightOfferModel offer = revalidatedDetails.offer;
    final FlightLegModel outbound = offer.outbound;
    final FlightLegModel? inbound = offer.inbound; // null في حالة one-way

    // فورمات الوقت والتاريخ
    final timeFormat = DateFormat('hh:mm a');
    final dateFormat = DateFormat('EEE, dd MMM');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // شركة التذكرة (validating airline)
            // Row(
            //   children: [
            //     Container(
            //       height: 24,
            //       width: 24,
            //       alignment: Alignment.center,
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(6),
            //       ),
            //       child: CacheImg(
            //         "http://172.16.0.66/newhorizon/storage/images/airline/${offer.airlineCode}.png",
            //       ),
            //     ),
            //     const SizedBox(width: 8),
            //     Expanded(
            //       child: Text(
            //         offer.airlineName,
            //         style: textTheme.titleMedium?.copyWith(
            //           fontWeight: FontWeight.w600,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 16),

            // مسار الذهاب
            _LegSummary(title: "Departure".tr, leg: outbound, timeFormat: timeFormat, dateFormat: dateFormat),

            // مسار العودة إن وجد
            if (inbound != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              _LegSummary(title: "Return".tr, leg: inbound, timeFormat: timeFormat, dateFormat: dateFormat),
            ],

            const SizedBox(height: 8),

            // زر التفاصيل (مرة واحدة)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.to(() => MoreFlightDetailPage(
                    flightOffer: revalidatedDetails.offer, 
                    revalidatedDetails: revalidatedDetails,
                    fareRules: revalidatedDetails.fareRules,
                  ));
                },
                icon: const Icon(Icons.info_outline),
                label: Text("More Details".tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ويدجت صغيرة تعيد استخدام نفس تصميم مسار الرحلة (من → إلى + الوقت + المدة + الـ stops)
/// وتعرض شعارات وأسماء شركات هذا المسار (outbound / inbound)
class _LegSummary extends StatefulWidget {
  const _LegSummary({required this.title, required this.leg, required this.timeFormat, required this.dateFormat});

  final String title;
  final FlightLegModel leg;
  final DateFormat timeFormat;
  final DateFormat dateFormat;

  @override
  State<_LegSummary> createState() => _LegSummaryState();
}

class _LegSummaryState extends State<_LegSummary> {


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final cs = theme.colorScheme;
    final depTime = AppFuns.replaceArabicNumbers(widget.timeFormat.format(widget.leg.departureDateTime).toUpperCase());
    final arrTime = AppFuns.replaceArabicNumbers(widget.timeFormat.format(widget.leg.arrivalDateTime).toUpperCase());
    final depDate = AppFuns.replaceArabicNumbers(widget.dateFormat.format(widget.leg.departureDateTime));
    final arrDate = AppFuns.replaceArabicNumbers(widget.dateFormat.format(widget.leg.arrivalDateTime));

    // ===== شركات هذا المسار (بدون تكرار) =====
    final legCodes = _uniqueMarketingCodesForLeg(widget.leg);
    final legNames = legCodes.map((c) => (AirlineRepo.searchByCode(c) != null) ? AirlineRepo.searchByCode(c)!.name[AppVars.lang] + " ($c)" : "").where((name) {
      if (name.isNotEmpty) {
        return true;
      }
      return false;
    }).toList();
    final legNamesText = legNames.join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // صف شعارات + أسماء المسار (ذهاب أو عودة)
        if (legCodes.isNotEmpty) ...[
          Row(
            children: [
              // شعارات (أقصى شيء شعارين مثل قائمة العروض)
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: CacheImg(AppFuns.airlineImgURL(legCodes.first), sizeCircleLoading: 12),
                  ),
                  if (legCodes.length > 1) ...[
                    const SizedBox(width: 4),
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: CacheImg(AppFuns.airlineImgURL(legCodes[1]), sizeCircleLoading: 12),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  legNamesText,
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all()),
                child: Text(widget.title),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        // بقية ملخص المسار (نفس التصميم القديم تقريباً)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // العمود الرأسي (خط المسار)
              Column(
                children: [
                  Container(width: 2, height: 18, color: cs.secondary),
                  Container(
                    width: 8, 
                    height: 8,
                    decoration: BoxDecoration(color: cs.secondary, shape: BoxShape.circle),
                  ),
                  Expanded(child: Container(width: 2, color: cs.secondary)),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: cs.secondary, shape: BoxShape.circle),
                  ),
                  Container(width: 2, height: 32, color: cs.secondary),
                ],
              ),
              const SizedBox(width: 8),

              // بيانات المسار
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عنوان المسار (Departure / Return)
                    // Align(
                    //   alignment: AlignmentDirectional.centerStart,
                    //   child: Text(
                    //     title,
                    //     style: textTheme.bodySmall
                    //         ?.copyWith(fontWeight: FontWeight.w600),
                    //   ),
                    // ),
                    const SizedBox(height: 8),

                    // من
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AirportRepo.searchByCode(widget.leg.fromCode)!.name[AppVars.lang], style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),  
                              const SizedBox(height: 4),
                              Text(widget.leg.fromCode, style: textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(depTime, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(depDate, style: textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // المدة + التوقفات
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${"Travel time".tr}: ${widget.leg.totalDurationText}", style: textTheme.bodyMedium),
                        Text(widget.leg.stops == 0 ? "Direct".tr : "${widget.leg.stops} ${"Stops".tr}", style: textTheme.bodySmall),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // إلى
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AirportRepo.searchByCode(widget.leg.toCode).name[AppVars.lang], style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(widget.leg.toCode, style: textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(arrTime, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(arrDate, style: textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -------------------- باقي الويجدت كما هي تقريباً --------------------

class _FlightExtraDetails extends StatelessWidget {
  const _FlightExtraDetails({required this.offer, required this.detail});

  final FlightOfferModel offer;
  final RevalidatedFlightModel detail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final hasBaggage = offer.baggageInfo != null && !offer.baggageInfo!.toLowerCase().startsWith('0');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LabelValueRow(label: "Cabin".tr, value: offer.cabinClassText),
        const SizedBox(height: 8),

        if (int.tryParse(offer.seatsRemaining.toString()) != null && int.parse(offer.seatsRemaining.toString()) <= 6) ...[
          _LabelValueRow(label: "Booking class".tr, value: offer.bookingClassCode),
          const SizedBox(height: 8),
          _LabelValueRow(label: "Seats left".tr, value: offer.seatsRemaining),
          const SizedBox(height: 8),
        ],

        _LabelValueRow(label: "Baggage".tr, value: hasBaggage ? (offer.baggageInfo ?? '_').split(',').first : "No checked baggage".tr),
        const SizedBox(height: 8),

        _LabelValueRow(label: "Cancelation fee".tr, value: AppFuns.priceWithCoin(20, "\$")),
        const SizedBox(height: 8),

        _LabelValueRow(label: "Exchange fee".tr, value: AppFuns.priceWithCoin(25, "\$")),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _LabelValueRow extends StatelessWidget {
  const _LabelValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(child: Text(label, style: textTheme.bodyMedium)),
        const SizedBox(width: 8),
        Text(value, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class FareRuleTile extends StatelessWidget {
  const FareRuleTile({super.key, required this.rule});

  final FareRule rule;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(rule.category.tr, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(rule.rule, style: textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _TripTotalSection extends StatefulWidget {
  const _TripTotalSection({
    required this.offer,
    required this.fareRules,
    required this.showContinueButton,
    this.parent,
  });

  final FlightOfferModel offer;
  final List<FareRule> fareRules;
  final bool showContinueButton;
  final FlightDetailPage? parent;

  @override
  State<_TripTotalSection> createState() => _TripTotalSectionState();
}

class _TripTotalSectionState extends State<_TripTotalSection> {
  final TravelersController travelersController = Get.find();

  String _formatTotal(num value) {
    final formatter = NumberFormat('#,##0.00', 'en');
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                    "${widget.offer.currency} ${_formatTotal(widget.offer.totalAmount)}",
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
                  child: OutlinedButton.icon(
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

/// نفس الهيلبر المستخدم في flight_offers_list لمسار واحد
List<String> _uniqueMarketingCodesForLeg(FlightLegModel leg) {
  final seen = <String>{};
  final codes = <String>[];
  for (final seg in leg.segments) {
    if (seg.marketingAirlineCode.isNotEmpty && seen.add(seg.marketingAirlineCode)) {
      codes.add(seg.marketingAirlineCode);
    }
  }
  return codes;
}
