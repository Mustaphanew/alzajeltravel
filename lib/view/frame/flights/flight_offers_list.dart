// lib/view/frame/flights/flight_offers_list.dart
import 'dart:math' as math;

import 'package:alzajeltravel/controller/flight/filter_offers_controller.dart';
import 'package:alzajeltravel/controller/flight/other_prices_controller.dart';
import 'package:alzajeltravel/repo/airline_repo.dart';
import 'package:alzajeltravel/repo/airport_repo.dart';
import 'package:alzajeltravel/view/frame/flights/filter_offers_page.dart';
import 'package:alzajeltravel/view/frame/flights/other_prices/other_prices_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:loader_overlay/loader_overlay.dart';
import 'package:alzajeltravel/controller/flight/flight_detail_controller.dart';
import 'package:alzajeltravel/model/flight/flight_offer_model.dart';
import 'package:alzajeltravel/model/flight/flight_leg_model.dart';
import 'package:alzajeltravel/model/flight/revalidated_flight_model.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/widgets.dart';
import 'package:alzajeltravel/view/frame/flights/flight_detail/flight_detail_page.dart';
import 'package:alzajeltravel/view/frame/flights/flight_detail/more_flight_detail_page.dart';

class FlightOffersList extends StatefulWidget {
  final List flightOffers;

  const FlightOffersList({super.key, required this.flightOffers});

  @override
  State<FlightOffersList> createState() => _FlightOffersListState();
}

class _FlightOffersListState extends State<FlightOffersList> {
  ScrollController scrollController = ScrollController();

  late final FlightDetailApiController detailCtrl;
  late final OtherPricesController otherPricesCtrl;

  FilterOffersState filterState = const FilterOffersState();
  late List<FlightOfferModel> allOffers;
  List<FlightOfferModel> offers = [];

  @override
  void initState() {
    super.initState();
    detailCtrl = Get.put(FlightDetailApiController(), permanent: false);
    otherPricesCtrl = Get.put(OtherPricesController(), permanent: false);

    allOffers = widget.flightOffers.map((e) => FlightOfferModel.fromJson(e)).toList();
    offers = allOffers;
  }

  @override
  void dispose() {
    if (Get.isRegistered<FlightDetailApiController>()) {
      Get.delete<FlightDetailApiController>();
    }
    if (Get.isRegistered<OtherPricesController>()) {
      Get.delete<OtherPricesController>();
    }
    super.dispose();
  }

  bool isFilter = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Flight Offers'.tr + " (${offers.length})"),
        actions: [
          OutlinedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: isFilter ? cs.secondary : Colors.transparent,
            ),
            icon: const Icon(Icons.filter_alt_outlined),
            label: Text('Filter'.tr + (isFilter ? " (${filterState.countFiltersActive})" : ""), style: TextStyle(fontSize: AppConsts.lg)),
            onPressed: () async {
             
              try {
                final result = await Get.to<FilterOffersResult>(() => FilterOffersPage(offers: allOffers, state: filterState));

                if (result != null) {
                  setState(() {
                    isFilter = result.state.isFilter;
                    filterState = result.state;
                    offers = result.filteredOffers; // لو ما في فلاتر -> يرجع allOffers تلقائيًا
                  });
                  if(result.filteredOffers.isNotEmpty){
                    await Future.delayed(const Duration(milliseconds: 250));
                    scrollController.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
                  }
                
                }
              } catch (e) {
                Get.snackbar('Error', e.toString());
              } finally {
               
              }
            },
          ),

          const SizedBox(width: 12),
        ],
      ),
      body: (offers.isNotEmpty)
          ? CupertinoScrollbar(
              controller: scrollController,
              child: ListView.separated(
                controller: scrollController,
                itemCount: offers.length,
                separatorBuilder: (_, __) => const SizedBox.shrink(),
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  // final offerModel = FlightOfferModel.fromJson(offer);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: FlightOfferCard(
                      offer: offer,
                      onBook: () async {
                        context.loaderOverlay.show();
                        await detailCtrl.revalidateAndOpen(offer: offer);
                        if (context.mounted) context.loaderOverlay.hide();
                      },
                      onOtherPrices: () async {
                        context.loaderOverlay.show();
                        try {
                          final ok = await otherPricesCtrl.fetchOtherPrices(offer: offer);
                          if (!ok) {
                            Get.snackbar('Error', '${otherPricesCtrl.errorMessage}');
                          } else {
                            Get.to(() => OtherPricesPage());
                          }
                        } finally {
                          if (context.mounted) context.loaderOverlay.hide();
                        }
                      },
                      onDetails: () {
                        Get.to(
                          () => FlightDetailPage(
                            detail: RevalidatedFlightModel(
                              offer: offer,
                              isRefundable: offer.isRefundable,
                              isPassportMandatory: false,
                              firstNameCharacterLimit: 0,
                              lastNameCharacterLimit: 0,
                              paxNameCharacterLimit: 0,
                              fareRules: const [],
                            ),
                            showContinueButton: false,
                            onBook: () async {
                              context.loaderOverlay.show();
                              await detailCtrl.revalidateAndOpen(offer: offer);
                              if (context.mounted) context.loaderOverlay.hide();
                            },
                            onOtherPrices: () async {
                              context.loaderOverlay.show();
                              try {
                                final ok = await otherPricesCtrl.fetchOtherPrices(offer: offer);
                                if (!ok) {
                                  Get.snackbar('Error', '${otherPricesCtrl.errorMessage}');
                                } else {
                                  // Get.to(() => OtherPricesPage());
                                }
                              } finally {
                                if (context.mounted) context.loaderOverlay.hide();
                              }
                            },
                          ),
                        );
                      },
                      onMoreDetails: () {
                        Get.to(() => MoreFlightDetailPage(flightOffer: offer));
                      },
                    ),
                  );
                },
              ),
            )
          : Center(child: Text('No offers found'.tr)),
    );
  }
}

class FlightOfferCard extends StatefulWidget {
  final FlightOfferModel offer;
  final VoidCallback? onBook;
  final VoidCallback? onDetails;
  final VoidCallback? onMoreDetails;
  final VoidCallback? onOtherPrices;
  final bool? showFare;
  final bool showSeatLeft;
  final bool showBaggage;

  const FlightOfferCard({
    super.key,
    required this.offer,
    this.onBook,
    this.onDetails,
    this.onMoreDetails,
    this.onOtherPrices,
    this.showFare = true,
    this.showSeatLeft = true,
    this.showBaggage = true,
  });

  @override
  State<FlightOfferCard> createState() => _FlightOfferCardState();
}

class _FlightOfferCardState extends State<FlightOfferCard> {
  // final AirlineController airlineController = Get.find();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final offer = widget.offer;

    final timeFormat = DateFormat('hh:mm a', AppVars.lang);
    final dateFormat = DateFormat('EEE, dd MMM', AppVars.lang);

    // ===== شركات طيران مسار الذهاب فقط (للهيدر) =====
    final outboundLeg = offer.outbound;
    final outboundCodes = _uniqueMarketingCodesForLeg(outboundLeg);
    final headerCodes = outboundCodes.isNotEmpty ? outboundCodes : <String>[offer.airlineCode];

    final primaryCode = headerCodes.first;
    String primaryName = "";
    if (AirlineRepo.searchByCode(primaryCode) != null) {
      final airline = AirlineRepo.searchByCode(primaryCode);
      primaryName = airline!.name[AppVars.lang] + " ($primaryCode)";
    }

    String? secondaryCode;
    if (headerCodes.length > 1) secondaryCode = headerCodes[1];
    final String? secondaryName = secondaryCode != null
        ? AirlineRepo.searchByCode(secondaryCode)!.name[AppVars.lang] + " ($secondaryCode)"
        : null;

    final String airlineNamesText = secondaryName == null ? primaryName : '$primaryName, $secondaryName';

    // final String airlineNamesTextWithCode = secondaryName == null ? '$primaryName ($primaryCode)' : '$primaryName ($primaryCode), $secondaryName ($secondaryCode)';

    return GestureDetector(
      onTap: widget.onDetails,
      child: Card(
        // margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ====== الهيدر: شعارات + أسماء الذهاب + السعر ======
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // شعارات + أسماء الذهاب
                  Expanded(
                    child: Row(
                      children: [
                        SizedBox(height: 32, width: 32, child: CacheImg(AppFuns.airlineImgURL(primaryCode), sizeCircleLoading: 14)),
                        const SizedBox(width: 4),
                        if (secondaryCode != null) ...[
                          SizedBox(height: 32, width: 32, child: CacheImg(AppFuns.airlineImgURL(secondaryCode), sizeCircleLoading: 14)),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            airlineNamesText,
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // السعر
                  if (widget.showFare ?? true)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppFuns.priceWithCoin(offer.totalAmount, offer.currency),
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: cs.error),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // ====== مسار الذهاب ======
              _LegRow(
                leg: outboundLeg,
                type: "departure".tr,
                dateFormat: dateFormat,
                timeFormat: timeFormat,
                showLegAirlinesHeader: false, // شعارات الذهاب موجودة في الهيدر
              ),

              // ====== مسار العودة (إن وجد) مع شعارات خاصة به ======
              if (offer.isRoundTrip && offer.inbound != null) ...[
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                _LegRow(
                  leg: offer.inbound!,
                  type: "return",
                  dateFormat: dateFormat,
                  timeFormat: timeFormat,
                  showLegAirlinesHeader: true, // نعرض شعارات وأسماء العودة هنا
                ),
              ],

              const SizedBox(height: 12),

              // ====== المعلومات أسفل الكرت ======
              Row(
                children: [
                  if (widget.showSeatLeft)
                    Row(
                      children: [
                        const Icon(Icons.event_seat, size: 18),
                        const SizedBox(width: 4),
                        Text("${offer.seatsRemaining} ${"Seats left".tr}", style: theme.textTheme.bodySmall),
                      ],
                    ),
                  const SizedBox(width: 12),
                  if (widget.showBaggage)
                    Row(
                      children: [
                        const Icon(Icons.luggage, size: 18),
                        const SizedBox(width: 4),

                        Text((offer.baggageInfo ?? '').split(',').first, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  if (widget.showSeatLeft && widget.showBaggage) const Spacer(),
                  Text(offer.cabinClassText.tr, style: theme.textTheme.bodySmall),
                ],
              ),

              const SizedBox(height: 12),

              // ====== الأزرار ======
              if (widget.onBook != null || widget.onOtherPrices != null)
                Row(
                  children: [
                    if (widget.onBook != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.onBook!,
                          icon: const Icon(Icons.flight_takeoff),
                          label: Text("Book now".tr),
                        ),
                      ),
                    if (widget.onBook != null && widget.onOtherPrices != null) ...[const SizedBox(width: 8)],
                    if (widget.onOtherPrices != null) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onOtherPrices!,
                          icon: const Icon(Icons.attach_money),
                          label: Text("Other Prices".tr),
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// شركات التسويق بدون تكرار لمسار واحد
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

/// مسار واحد (ذهاب أو عودة)
class _LegRow extends StatefulWidget {
  final FlightLegModel leg;
  final DateFormat dateFormat;
  final DateFormat timeFormat;
  final String type;

  /// هل نعرض شعارات وأسماء شركات هذا المسار؟
  final bool showLegAirlinesHeader;

  const _LegRow({
    required this.leg,
    required this.dateFormat,
    required this.timeFormat,
    required this.showLegAirlinesHeader,
    required this.type,
  });

  @override
  State<_LegRow> createState() => _LegRowState();
}

class _LegRowState extends State<_LegRow> {
  String fromName = "";
  String toName = "";

  @override
  void initState() {
    super.initState();

    if (AirportRepo.searchByCode(widget.leg.fromCode) != null) {
      fromName = AirportRepo.searchByCode(widget.leg.fromCode)!.name[AppVars.lang];
    } else {
      fromName = widget.leg.fromCode;
    }
    if (AirportRepo.searchByCode(widget.leg.toCode) != null) {
      toName = AirportRepo.searchByCode(widget.leg.toCode)!.name[AppVars.lang];
    } else {
      toName = widget.leg.toCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final depTimeFull = AppFuns.replaceArabicNumbers(widget.timeFormat.format(widget.leg.departureDateTime));
    final arrTimeFull = AppFuns.replaceArabicNumbers(widget.timeFormat.format(widget.leg.arrivalDateTime));
    final depDate = AppFuns.replaceArabicNumbers(widget.dateFormat.format(widget.leg.departureDateTime));
    final arrDate = AppFuns.replaceArabicNumbers(widget.dateFormat.format(widget.leg.arrivalDateTime));

    final justDepTime = depTimeFull.split(' ')[0];
    final periodDepTime = depTimeFull.split(' ')[1];
    final justArrTime = arrTimeFull.split(' ')[0];
    final periodArrTime = arrTimeFull.split(' ')[1];

    // نص التوقفات
    String stopsText;
    if (widget.leg.stops == 0) {
      stopsText = "Direct".tr;
    } else if (widget.leg.stops == 1) {
      stopsText = "1 " + "Stop".tr;
    } else {
      stopsText = "${widget.leg.stops} ${"Stops".tr}";
    }

    // شركات هذا المسار (بدون تكرار)
    final legCodes = _uniqueMarketingCodesForLeg(widget.leg);
    final legNames = legCodes
        .map((c) => (AirlineRepo.searchByCode(c) != null) ? AirlineRepo.searchByCode(c)!.name[AppVars.lang] + " ($c)" : "")
        .where((name) => name.isNotEmpty)
        .toList();
    final legNamesText = legNames.join(', ');

    // اتجاه الطائرة ثابت حسب اللغة (نفسه في الذهاب والعودة)
    final bool isArabic = AppVars.lang == "ar";
    final double planeAngle = isArabic ? -math.pi / 2 : math.pi / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ===== صف شعارات وأسماء شركات هذا المسار (يظهر فقط في العودة) =====
        if (widget.showLegAirlinesHeader) ...[
          Row(
            children: [
              // الشعارات بحجم 32 مثل الهيدر
              Row(
                children: [
                  if (legCodes.isNotEmpty)
                    SizedBox(height: 32, width: 32, child: CacheImg(AppFuns.airlineImgURL(legCodes.first), sizeCircleLoading: 14)),
                  if (legCodes.length > 1) ...[
                    const SizedBox(width: 4),
                    SizedBox(height: 32, width: 32, child: CacheImg(AppFuns.airlineImgURL(legCodes[1]), sizeCircleLoading: 14)),
                  ],
                ],
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  legNamesText,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],

        // ===== الصف الرئيسي (من / مدة / إلى) =====
        // return Directionality inverted
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // المغادرة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(depDate, style: theme.textTheme.bodySmall),
                  Row(
                    children: [
                      if (AppVars.lang == "en") ...[
                        Text(justDepTime, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 2),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            periodDepTime,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ] else ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            periodDepTime,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(justDepTime, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(widget.leg.fromCode, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(fromName, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
                ],
              ),
            ),

            // المنتصف (مدة الرحلة + الخط + الطائرة فوقه)
            Column(
              children: [
                Text(widget.leg.totalDurationText, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
                // const SizedBox(height: 4),
                SizedBox(
                  width: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox.shrink(),
                      DividerLine(),
                      Transform.rotate(angle: planeAngle, child: const Icon(Icons.airplanemode_active, size: 27)),
                    ],
                  ),
                ),

                const SizedBox(height: 4),
                Text(stopsText, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 26),
              ],
            ),

            // الوصول
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(arrDate, style: theme.textTheme.bodySmall),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (AppVars.lang == "en") ...[
                        Text(justArrTime, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 2),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            periodArrTime,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ] else ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            periodArrTime,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(justArrTime, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(widget.leg.toCode, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(toName, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
