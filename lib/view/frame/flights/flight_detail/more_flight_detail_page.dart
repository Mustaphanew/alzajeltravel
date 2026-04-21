import 'package:alzajeltravel/controller/travelers_controller.dart';
import 'package:alzajeltravel/model/flight/flight_segment_model.dart';
import 'package:alzajeltravel/repo/airline_repo.dart';
import 'package:alzajeltravel/repo/airport_repo.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
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
  final bool showJustBody;

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
    this.showJustBody = false,
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

    if(showJustBody == true) {
      return detailBody(context, theme, cs, offer, legs, timeFormat, dateFormat);
    }

    final isLight = theme.brightness == Brightness.light;

    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        // نهاري: خلفية كريمية كالمرجع | ليلي: سطح الثيم الداكن
        backgroundColor: isLight ? const Color(0xFFFDFBF7) : cs.surface,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppConsts.primaryColor,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'Flight details'.tr,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        body: detailBodyAndBottomSection(context, theme, cs, offer, legs, timeFormat, dateFormat),
      ),
    );
  }

  Column detailBodyAndBottomSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    FlightOfferModel offer,
    List<FlightLegModel> legs,
    DateFormat timeFormat,
    DateFormat dateFormat,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: detailBody(context, theme, cs, offer, legs, timeFormat, dateFormat),
          ),
        ),

        Container(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 14, top: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppConsts.primaryColor,
                Color.lerp(AppConsts.primaryColor, const Color(0xFF1a3278), 0.4)!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppConsts.primaryColor.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: BottomSection(offer: offer, fareRules: fareRules, showContinueButton: showContinueButton, parent: this),
        ),
      ],
    );
  }

  Column detailBody(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    FlightOfferModel offer,
    List<FlightLegModel> legs,
    DateFormat timeFormat,
    DateFormat dateFormat,
  ) {
    final isLight = theme.brightness == Brightness.light;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        // ---------- عرض المسارات (ذهاب / عودة) ----------
        _buildLegSections(context: context, theme: theme, cs: cs, offer: offer, legs: legs, timeFormat: timeFormat, dateFormat: dateFormat),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Card(
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            color: isLight ? Colors.white : cs.surfaceContainerHighest,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: AppConsts.secondaryColor.withValues(alpha: isLight ? 0.42 : 0.55),
                width: 1.1,
              ),
            ),
            child: Theme(
              data: theme.copyWith(dividerColor: cs.outlineVariant.withValues(alpha: 0.35)),
              child: ExpansionTile(
                initiallyExpanded: true,
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                childrenPadding: EdgeInsets.zero,
                iconColor: AppConsts.secondaryColor,
                collapsedIconColor: AppConsts.secondaryColor,
                shape: const RoundedRectangleBorder(),
                collapsedShape: const RoundedRectangleBorder(),
                backgroundColor: Colors.transparent,
                collapsedBackgroundColor: Colors.transparent,
                title: Text(
                  "Other info".tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isLight ? AppConsts.primaryColor : Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    decoration: BoxDecoration(
                      color: isLight
                          ? Colors.white
                          : Color.lerp(cs.surfaceContainerHighest, cs.surface, 0.45)!,
                      border: Border(
                        top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.35)),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 12),
                        _InfoRow(label: "Baggage".tr + " (${"Adult".tr})", value: "10" + " " + "kg".tr),
                        const SizedBox(height: 14),
                        _InfoRow(label: "Exchange fee".tr, value: AppFuns.priceWithCoin(20, "USD")),
                        const SizedBox(height: 14),
                        _InfoRow(label: "Cancelation fee".tr, value: AppFuns.priceWithCoin(10, "USD")),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        if (fareRules.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Card(
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              color: isLight ? Colors.white : cs.surfaceContainerHighest,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: AppConsts.secondaryColor.withValues(alpha: isLight ? 0.42 : 0.55),
                  width: 1.1,
                ),
              ),
              child: Theme(
                data: theme.copyWith(dividerColor: cs.outlineVariant.withValues(alpha: 0.35)),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  iconColor: AppConsts.secondaryColor,
                  collapsedIconColor: AppConsts.secondaryColor,
                  shape: const RoundedRectangleBorder(),
                  collapsedShape: const RoundedRectangleBorder(),
                  backgroundColor: Colors.transparent,
                  collapsedBackgroundColor: Colors.transparent,
                  title: Text(
                    "Fare rules".tr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isLight ? AppConsts.primaryColor : Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  children: fareRules.map((rule) => FareRuleTile(rule: rule)).toList(),
                ),
              ),
            ),
          ),

        const SizedBox(height: 15),
      ],
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
              final String pathTitle =
                  '${"Trip route".tr}: '
                  '${legIndex == 0 ? "Departure".tr : "Return".tr}';

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

    final isLight = theme.brightness == Brightness.light;

    return Card(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      color: isLight ? Colors.white : cs.surfaceContainerHighest,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppConsts.secondaryColor.withValues(alpha: isLight ? 0.42 : 0.55),
          width: 1.1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            alignment: AlignmentDirectional.centerStart,
            decoration: const BoxDecoration(
              color: AppConsts.primaryColor,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Text(
              pathTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: AppConsts.lg,
                color: Colors.white,
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
              if (offer.baggagePerSegment.length > globalIndex && offer.baggagePerSegment[globalIndex].isNotEmpty) {
                final raw = offer.baggagePerSegment[globalIndex];
                segmentBaggage = raw.replaceAll('Piece', 'Piece'.tr).replaceAll('KG', 'KG'.tr);
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

              final isDark = theme.brightness == Brightness.dark;
              final Color layoverText =
                  isDark ? Colors.white : AppConsts.primaryColor;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppConsts.secondaryColor.withValues(alpha: isDark ? 0.14 : 0.16),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppConsts.secondaryColor.withValues(alpha: 0.55),
                          width: 1.1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 20,
                            color: AppConsts.secondaryColor,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${"layover in".tr} $cityName ${"for".tr} $layText',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: layoverText,
                                letterSpacing: 0.2,
                              ),
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    // نهاري: تسمية رمادية + قيمة كحلية | ليلي: تسمية رمادية فاتحة + قيمة ذهبية (كالمرجع)
    final labelColor = cs.onSurfaceVariant;
    final valueColor = isDark ? AppConsts.secondaryColor : AppConsts.primaryColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: labelColor,
              height: 1.25,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor,
              height: 1.25,
            ),
          ),
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final primaryText = isDark ? Colors.white : AppConsts.primaryColor;
    final metaStyle = theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant);

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
              SizedBox(height: 28, width: 28, child: CacheImg(AppFuns.airlineImgURL(seg.marketingAirlineCode), sizeCircleLoading: 14)),
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
                            (AirlineRepo.searchByCode(seg.marketingAirlineCode) != null)
                                ? AirlineRepo.searchByCode(seg.marketingAirlineCode)!.name[AppVars.lang]
                                : "",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: primaryText,
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
                          style: metaStyle,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppConsts.secondaryColor.withValues(alpha: isDark ? 0.14 : 0.18),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppConsts.secondaryColor.withValues(alpha: 0.55),
                              width: 1.1,
                            ),
                          ),
                          child: Text(
                            seg.ref,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppConsts.secondaryColor,
                              letterSpacing: 0.3,
                            ),
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
          Divider(color: cs.outlineVariant.withValues(alpha: 0.4), height: 1),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(depDate, textAlign: TextAlign.center, style: metaStyle),
                    const SizedBox(height: 2),
                    Text(
                      depTime,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: primaryText,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fromName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(fromCode, style: metaStyle),
                  ],
                ),
              ),

              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      AppFuns.formatHourMinuteSecond(seg.journeyText ?? '_'),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontFamily: AppConsts.font,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppConsts.secondaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const DividerLine(),
                              RotatedBox(
                                quarterTurns: (AppVars.lang == 'en') ? 1 : -1,
                                child: const Icon(Icons.flight, color: AppConsts.secondaryColor, size: 28),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppConsts.secondaryColor,
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
                          color: AppConsts.secondaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppConsts.secondaryColor.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          "Baggage".tr + ": " + segmentBaggage!,
                          style: const TextStyle(
                            fontFamily: AppConsts.font,
                            fontSize: AppConsts.sm,
                            fontWeight: FontWeight.w700,
                            height: 0,
                            color: AppConsts.secondaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  children: [
                    Text(arrDate, textAlign: TextAlign.center, style: metaStyle),
                    const SizedBox(height: 2),
                    Text(
                      arrTime,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: primaryText,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      toName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(toCode, style: metaStyle),
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
  const BottomSection({super.key, required this.offer, required this.fareRules, required this.showContinueButton, this.parent});

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // اليسار: السعر + ملخص
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Trip total".tr,
                    style: textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppFuns.priceWithCoin(widget.offer.totalAmount, widget.offer.currency),
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppConsts.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  InkWell(
                    onTap: () {
                      // BottomSheet لملخص السعر لاحقاً
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        "View price summary".tr,
                        style: TextStyle(
                          color: AppConsts.secondaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: textTheme.bodySmall?.fontSize ?? 13,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
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

                    Get.to(() => PassportsFormsPage(adultsCounter: adults, childrenCounter: children, infantsInLapCounter: infantsInLap));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConsts.secondaryColor,
                    foregroundColor: AppConsts.primaryColor,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                  ),
                  label: const Icon(Icons.arrow_forward),
                  icon: Text("Continue".tr),
                ),
              ),
          ],
        ),

        if (widget.parent != null && (widget.parent!.onBook != null || widget.parent!.onOtherPrices != null)) const SizedBox(height: 10),
        // ====== الأزرار ======
        if (widget.parent != null && (widget.parent!.onBook != null || widget.parent!.onOtherPrices != null))
          Row(
            children: [
              if (widget.parent!.onBook != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.parent!.onBook!,
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
                    icon: const Icon(Icons.flight_takeoff, size: 18),
                    label: Text("Book now".tr),
                  ),
                ),
              if (widget.parent!.onBook != null && widget.parent!.onOtherPrices != null) ...[const SizedBox(width: 8)],
              if (widget.parent!.onOtherPrices != null) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.parent!.onOtherPrices,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConsts.secondaryColor,
                      side: const BorderSide(color: AppConsts.secondaryColor, width: 1.4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(
                        fontSize: AppConsts.normal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    icon: const Icon(Icons.attach_money, size: 18),
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
