// lib/view/frame/flights/flight_offers_list.dart
import 'dart:math' as math;

import 'package:alzajeltravel/controller/flight/filter_offers_controller.dart';
import 'package:alzajeltravel/controller/flight/other_prices_controller.dart';
import 'package:alzajeltravel/repo/airline_repo.dart';
import 'package:alzajeltravel/repo/airport_repo.dart';
import 'package:alzajeltravel/utils/widgets/custom_button.dart';
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
  final List<dynamic> flightOffers;

  const FlightOffersList({super.key, required this.flightOffers});

  @override
  State<FlightOffersList> createState() => _FlightOffersListState();
}

class _FlightOffersListState extends State<FlightOffersList> {
  final ScrollController scrollController = ScrollController();

  late final FlightDetailApiController detailCtrl;
  late final OtherPricesController otherPricesCtrl;

  FilterOffersState filterState = const FilterOffersState();

  late List<FlightOfferModel> allOffers;
  List<FlightOfferModel> offers = [];

  @override
  void initState() {
    super.initState();

    detailCtrl = Get.put(FlightDetailApiController(), );
    otherPricesCtrl = Get.put(OtherPricesController(),);

    allOffers = widget.flightOffers.map((e) => FlightOfferModel.fromJson(e)).toList();
    offers = List<FlightOfferModel>.from(allOffers);

    _rebuildOffersFromState();
  }

  @override
  void dispose() {
    // if (Get.isRegistered<FlightDetailApiController>()) {
    //   Get.delete<FlightDetailApiController>();
    // }
    // if (Get.isRegistered<OtherPricesController>()) {
    //   Get.delete<OtherPricesController>();
    // }
    super.dispose();
  }

  // =========================
  // Filtering + Sorting (same logic as FilterOffersController)
  // =========================

  int? _parseDurationToMinutes(String text) {
    final s = text.trim();
    if (s.isEmpty) return null;

    final m = RegExp(r'(\d+)\s*h\s*:\s*(\d+)\s*m', caseSensitive: false).firstMatch(s);
    if (m == null) return null;

    final h = int.tryParse(m.group(1) ?? '');
    final mm = int.tryParse(m.group(2) ?? '');
    if (h == null || mm == null) return null;

    return (h * 60) + mm;
  }

  int? _offerTotalDurationMinutes(FlightOfferModel offer) {
    int sum = 0;
    for (final leg in offer.legs) {
      final m = _parseDurationToMinutes(leg.totalDurationText);
      if (m == null) return null;
      sum += m;
    }
    return sum;
  }

  bool _matchStops(FlightOfferModel offer) {
    if (filterState.stops.isEmpty) return true;

    // OR between legs
    for (final leg in offer.legs) {
      final normalized = leg.stops >= 2 ? 2 : leg.stops;
      if (filterState.stops.contains(normalized)) return true;
    }
    return false;
  }

  bool _matchAirlines(FlightOfferModel offer) {
    if (filterState.airlineCodes.isEmpty) return true;

    final codesInOffer = offer.segments
        .map((s) => s.marketingAirlineCode.trim())
        .where((c) => c.isNotEmpty)
        .toSet();

    return codesInOffer.intersection(filterState.airlineCodes).isNotEmpty;
  }

  bool _matchDepartureBuckets(FlightOfferModel offer) {
    if (filterState.departureBuckets.isEmpty) return true;

    for (final leg in offer.legs) {
      final b = FilterOffersController.bucketOf(leg.departureDateTime);
      if (filterState.departureBuckets.contains(b)) return true;
    }
    return false;
  }

  bool _matchArrivalBuckets(FlightOfferModel offer) {
    if (filterState.arrivalBuckets.isEmpty) return true;

    for (final leg in offer.legs) {
      final b = FilterOffersController.bucketOf(leg.arrivalDateTime);
      if (filterState.arrivalBuckets.contains(b)) return true;
    }
    return false;
  }

  bool _matchPrice(FlightOfferModel offer) {
    final from = filterState.priceFrom;
    final to = filterState.priceTo;
    if (from == null && to == null) return true;

    final v = offer.totalAmount;
    if (from != null && v < from) return false;
    if (to != null && v > to) return false;
    return true;
  }

  bool _matchTravelTime(FlightOfferModel offer) {
    final from = filterState.travelTimeFrom;
    final to = filterState.travelTimeTo;
    if (from == null && to == null) return true;

    // match if ANY leg duration is within range
    for (final leg in offer.legs) {
      final m = _parseDurationToMinutes(leg.totalDurationText);
      if (m == null) continue;
      if ((from == null || m >= from) && (to == null || m <= to)) return true;
    }
    return false;
  }

  void _applySort(List<FlightOfferModel> list) {
    final s = filterState.sort; // requires sort in FilterOffersState
    if (s == null) return;

    int cmpNullableInt(int? a, int? b, {required bool asc}) {
      if (a == null && b == null) return 0;
      if (a == null) return 1; // null last
      if (b == null) return -1;
      return asc ? a.compareTo(b) : b.compareTo(a);
    }

    list.sort((a, b) {
      switch (s) {
        case SortOffersOption.priceLow:
          final r = a.totalAmount.compareTo(b.totalAmount);
          if (r != 0) return r;
          return cmpNullableInt(_offerTotalDurationMinutes(a), _offerTotalDurationMinutes(b), asc: true);

        case SortOffersOption.priceHigh:
          final r = b.totalAmount.compareTo(a.totalAmount);
          if (r != 0) return r;
          return cmpNullableInt(_offerTotalDurationMinutes(a), _offerTotalDurationMinutes(b), asc: false);

        case SortOffersOption.travelTimeLow:
          return cmpNullableInt(_offerTotalDurationMinutes(a), _offerTotalDurationMinutes(b), asc: true);

        case SortOffersOption.travelTimeHigh:
          return cmpNullableInt(_offerTotalDurationMinutes(a), _offerTotalDurationMinutes(b), asc: false);
      }
    });
  }

  Future<void> _rebuildOffersFromState({bool scrollTop = false}) async {
    final filtered = allOffers.where((offer) {
      if (!_matchStops(offer)) return false;
      if (!_matchPrice(offer)) return false;
      if (!_matchTravelTime(offer)) return false;
      if (!_matchDepartureBuckets(offer)) return false;
      if (!_matchArrivalBuckets(offer)) return false;
      if (!_matchAirlines(offer)) return false;
      return true;
    }).toList();

    _applySort(filtered);

    setState(() {
      offers = filtered;
    });

    if (scrollTop && filtered.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    final bool isFilter = filterState.isFilter;

    return Scaffold(
      appBar: AppBar(
        title: Text('${'Flight Offers'.tr} (${offers.length})'),
        actions: [
          OutlinedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            icon: const Icon(Icons.filter_alt_outlined),
            label: Text(
              'Filter'.tr + (isFilter ? ' (${filterState.countFiltersActive})' : ''),
              style: TextStyle(fontSize: AppConsts.lg),
            ),
            onPressed: () async {
              try {
                final result = await Get.to<FilterOffersResult>(
                  () => FilterOffersPage(offers: allOffers, state: filterState),
                );

                if (result != null) {
                  filterState = result.state;
                  await _rebuildOffersFromState(scrollTop: true);
                }
              } catch (e) {
                Get.snackbar('Error'.tr, e.toString());
              }
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: (offers.isNotEmpty)
          ? Column(
              children: [
                // ===== Sort dropdown (same value synced with FilterOffersPage) =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: DropdownButtonFormField<SortOffersOption?>(
                    value: filterState.sort,
                    decoration: InputDecoration(
                      hintText: 'Select sort'.tr,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                    items: <DropdownMenuItem<SortOffersOption?>>[
                      DropdownMenuItem<SortOffersOption?>(
                        value: null,
                        child: Text('No sorting'.tr),
                      ),
                      DropdownMenuItem(
                        value: SortOffersOption.priceLow,
                        child: Text(FilterOffersController.sortLabel(SortOffersOption.priceLow).tr),
                      ),
                      DropdownMenuItem(
                        value: SortOffersOption.priceHigh,
                        child: Text(FilterOffersController.sortLabel(SortOffersOption.priceHigh).tr),
                      ),
                      DropdownMenuItem(
                        value: SortOffersOption.travelTimeLow,
                        child: Text(FilterOffersController.sortLabel(SortOffersOption.travelTimeLow).tr),
                      ),
                      DropdownMenuItem(
                        value: SortOffersOption.travelTimeHigh,
                        child: Text(FilterOffersController.sortLabel(SortOffersOption.travelTimeHigh).tr),
                      ),
                    ],
                    onChanged: (v) async {
                      setState(() {
                        // requires copyWith supports sort + setSortNull
                        filterState = filterState.copyWith(sort: v, setSortNull: v == null);
                      });
                      await _rebuildOffersFromState(scrollTop: true);
                    },
                  ),
                ),

                Expanded(
                  child: CupertinoScrollbar(
                    controller: scrollController,
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: offers.length,
                      separatorBuilder: (_, __) => const SizedBox.shrink(),
                      itemBuilder: (context, index) {
                        final offer = offers[index];

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
                                  Get.snackbar('Error'.tr, '${otherPricesCtrl.errorMessage}');
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
                                        Get.snackbar('Error'.tr, '${otherPricesCtrl.errorMessage}');
                                      }
                                    } finally {
                                      if (context.mounted) context.loaderOverlay.hide();
                                    }
                                  },
                                ),
                              );
                            },
                            onMoreDetails: () {
                              Get.to(() => MoreFlightDetailPage(
                                flightOffer: offer,
                                fareRules: [],
                              ));
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final offer = widget.offer;

    final timeFormat = DateFormat('hh:mm a', AppVars.lang);
    final dateFormat = DateFormat('EEE, dd MMM', AppVars.lang);

    // ===== شركات طيران مسار الذهاب فقط (للهيدر) =====
    final outboundLeg = offer.outbound;
    final outboundCodes = _uniqueMarketingCodesForLeg(outboundLeg);
    final headerCodes = outboundCodes.isNotEmpty ? outboundCodes : <String>[offer.airlineCode];

    final primaryCode = headerCodes.first;

    final a1 = AirlineRepo.searchByCode(primaryCode);
    final primaryName = a1 != null ? '${a1.name[AppVars.lang]} ($primaryCode)' : primaryCode;

    String? secondaryCode;
    if (headerCodes.length > 1) secondaryCode = headerCodes[1];

    String? secondaryName;
    if (secondaryCode != null) {
      final a2 = AirlineRepo.searchByCode(secondaryCode);
      if (a2 != null) secondaryName = '${a2.name[AppVars.lang]} ($secondaryCode)';
    }

    final String airlineNamesText = secondaryName == null ? primaryName : '$primaryName, $secondaryName';
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: widget.onDetails,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ====== header ======
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        SizedBox(
                          height: 32,
                          width: 32,
                          child: CacheImg(AppFuns.airlineImgURL(primaryCode), sizeCircleLoading: 14),
                        ),
                        const SizedBox(width: 4),
                        if (secondaryCode != null) ...[
                          SizedBox(
                            height: 32,
                            width: 32,
                            child: CacheImg(AppFuns.airlineImgURL(secondaryCode), sizeCircleLoading: 14),
                          ),
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
                  if (widget.showFare ?? true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue[900]!.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column( 
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppFuns.priceWithCoin(offer.totalAmount, offer.currency),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              _LegRow(
                leg: outboundLeg,
                type: 'departure'.tr,
                dateFormat: dateFormat,
                timeFormat: timeFormat,
                showLegAirlinesHeader: false,
              ),

              if (offer.isRoundTrip && offer.inbound != null) ...[
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                _LegRow(
                  leg: offer.inbound!,
                  type: 'return'.tr,
                  dateFormat: dateFormat,
                  timeFormat: timeFormat,
                  showLegAirlinesHeader: true,
                ),
              ],

              const SizedBox(height: 12),

              Row(
                children: [
                  if (widget.showSeatLeft)
                    Row(
                      children: [
                        const Icon(Icons.event_seat, size: 20,),
                        const SizedBox(width: 0),
                        Text(
                          '${offer.seatsRemaining} ${'Seats left'.tr}', style: theme.textTheme.bodySmall!.copyWith(
                            fontSize: 14, color: Colors.red[800], fontWeight: FontWeight.w600)),
                      ],
                    ),
                  const Spacer(),
                  if (widget.showBaggage)
                    Row(
                      children: [
                        Icon(Icons.luggage, size: 20, color: Colors.blue[900]!.withOpacity(0.8)),
                        const SizedBox(width: 0),
                        Text((offer.baggageInfo ?? '').split(',').first, style: theme.textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
                      ],
                    ),
                  if (widget.showSeatLeft && widget.showBaggage) const Spacer(),
                  Text(
                    (offer.cabinClassText.replaceAll("Standard", "")).tr, 
                    style: theme.textTheme.bodySmall!.copyWith(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (widget.onBook != null || widget.onOtherPrices != null)
                Row(
                  children: [
                    if (widget.onBook != null)
                      Expanded(
                        child: CustomButton(
                          onPressed: widget.onBook!,
                          icon: const Icon(Icons.flight_takeoff),
                          label: Text('Book now'.tr),
                        ),
                      ),
                    if (widget.onBook != null && widget.onOtherPrices != null) ...[const SizedBox(width: 8)],
                    if (widget.onOtherPrices != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onOtherPrices!,
                          icon: const Icon(Icons.attach_money),
                          label: Text('Other Prices'.tr),
                        ),
                      ),
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
  String fromName = '';
  String toName = '';

  @override
  void initState() {
    super.initState();

    final from = AirportRepo.searchByCode(widget.leg.fromCode);
    fromName = from != null ? from.name[AppVars.lang] : widget.leg.fromCode;

    final to = AirportRepo.searchByCode(widget.leg.toCode);
    toName = to != null ? to.name[AppVars.lang] : widget.leg.toCode;
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

    String stopsText;
    if (widget.leg.stops == 0) {
      stopsText = 'Direct'.tr;
    } else if (widget.leg.stops == 1) {
      stopsText = '1 ${'Stop'.tr}';
    } else {
      stopsText = '${widget.leg.stops} ${'Stops'.tr}';
    }

    final legCodes = _uniqueMarketingCodesForLeg(widget.leg);
    final legNames = legCodes
        .map((c) {
          final a = AirlineRepo.searchByCode(c);
          if (a == null) return '';
          return '${a.name[AppVars.lang]} ($c)';
        })
        .where((name) => name.isNotEmpty)
        .toList();
    final legNamesText = legNames.join(', ');

    final bool isArabic = AppVars.lang == 'ar';
    final double planeAngle = isArabic ? -math.pi / 2 : math.pi / 2;
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showLegAirlinesHeader) ...[
          Row(
            children: [
              Row(
                children: [
                  if (legCodes.isNotEmpty)
                    SizedBox(
                      height: 32,
                      width: 32,
                      child: CacheImg(AppFuns.airlineImgURL(legCodes.first), sizeCircleLoading: 14),
                    ),
                  if (legCodes.length > 1) ...[
                    const SizedBox(width: 4),
                    SizedBox(
                      height: 32,
                      width: 32,
                      child: CacheImg(AppFuns.airlineImgURL(legCodes[1]), sizeCircleLoading: 14),
                    ),
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

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Departure
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(depDate, style: theme.textTheme.bodySmall),
                  Row(
                    children: [
                      if (AppVars.lang == 'en') ...[
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

            // Middle
            Column(
              children: [
                Text(
                  widget.leg.totalDurationText,
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                ),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Color(0xFFf7efe9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(stopsText, style: theme.textTheme.bodySmall?.copyWith(color: Color(0xFF9c5627), fontWeight: FontWeight.bold, fontSize: 13))),
                const SizedBox(height: 26),
              ],
            ),

            // Arrival
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(arrDate, style: theme.textTheme.bodySmall),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (AppVars.lang == 'en') ...[
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
                  Text(
                    toName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
