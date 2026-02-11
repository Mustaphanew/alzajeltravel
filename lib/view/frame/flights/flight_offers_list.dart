// lib/view/frame/flights/flight_offers_list.dart
import 'dart:async';
import 'dart:math' as math;

import 'package:alzajeltravel/controller/flight/filter_offers_controller.dart';
import 'package:alzajeltravel/controller/flight/flight_detail_controller.dart';
import 'package:alzajeltravel/controller/flight/other_prices_controller.dart';
import 'package:alzajeltravel/model/flight/flight_leg_model.dart';
import 'package:alzajeltravel/model/flight/flight_offer_model.dart';
import 'package:alzajeltravel/model/flight/flight_search_params.dart';
import 'package:alzajeltravel/model/flight/revalidated_flight_model.dart';
import 'package:alzajeltravel/repo/airline_repo.dart';
import 'package:alzajeltravel/repo/airport_repo.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/enums.dart';
import 'package:alzajeltravel/utils/widgets.dart';
import 'package:alzajeltravel/utils/widgets/custom_button.dart';
import 'package:alzajeltravel/utils/widgets/gradient_bg_container.dart';
import 'package:alzajeltravel/view/frame/flights/filter_offers_page.dart';
import 'package:alzajeltravel/view/frame/flights/flight_detail/more_flight_detail_page.dart';
import 'package:alzajeltravel/view/frame/flights/other_prices/other_prices_page.dart';
import 'package:alzajeltravel/view/frame/search_flight.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:loader_overlay/loader_overlay.dart';

class FlightOffersList extends StatefulWidget {
  final List<dynamic> flightOffers;
  final FlightSearchParams searchInputs;

  const FlightOffersList({
    super.key,
    required this.flightOffers,
    required this.searchInputs,
  });

  @override
  State<FlightOffersList> createState() => _FlightOffersListState();
}

class _FlightOffersListState extends State<FlightOffersList> {
  final ScrollController scrollController = ScrollController();
  final ScrollController scrollController2 = ScrollController();
  final ExpansibleController expansionController = ExpansibleController();

  late final FlightDetailApiController detailCtrl;
  late final OtherPricesController otherPricesCtrl;

  FilterOffersState filterState = const FilterOffersState();

  late List<FlightOfferModel> allOffers;
  List<FlightOfferModel> offers = [];

  late FlightSearchParams searchInputs;

  // ✅ لمنع setState المتكرر أثناء أنيميشن ExpansionTile
  bool _lastExpanded = false;

  @override
  void initState() {
    super.initState();

    searchInputs = widget.searchInputs;

    detailCtrl = Get.put(FlightDetailApiController());
    otherPricesCtrl = Get.put(OtherPricesController());

    allOffers = widget.flightOffers.map((e) => FlightOfferModel.fromJson(e)).toList();
    offers = List<FlightOfferModel>.from(allOffers);

    _rebuildOffersFromState();

    _lastExpanded = expansionController.isExpanded;
    expansionController.addListener(_handleExpansion);
  }

  void _handleExpansion() {
    final v = expansionController.isExpanded;
    if (v == _lastExpanded) return; // ✅ يمنع rebuild أثناء الأنيميشن
    _lastExpanded = v;
    setState(() {});
  }

  @override
  void dispose() {
    expansionController.removeListener(_handleExpansion);
    scrollController.dispose();
    scrollController2.dispose();
    expansionController.dispose();
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

    final codesInOffer =
        offer.segments.map((s) => s.marketingAirlineCode.trim()).where((c) => c.isNotEmpty).toSet();

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

    // ✅ حماية: لا تعمل animateTo إلا إذا الـ controller مرتبط (hasClients)
    if (scrollTop && filtered.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  // =========================
  // UI
  // =========================

  static List<int> _extractStops(List<FlightOfferModel> offers) {
    final set = <int>{};

    for (final o in offers) {
      for (final leg in o.legs) {
        final s = leg.stops;
        final normalized = s >= 2 ? 2 : s;
        set.add(normalized);
      }
    }

    final list = set.toList()..sort(); // 0,1,2
    return list;
  }

  OfferQuickOption _quickOptionFromState(FilterOffersState s) {
    if (s.sort == SortOffersOption.priceLow) return OfferQuickOption.priceLow;
    if (s.sort == SortOffersOption.travelTimeLow) return OfferQuickOption.travelTimeLow;

    if (s.stops.length == 1) {
      final v = s.stops.first;
      if (v == 0) return OfferQuickOption.stops0;
      if (v == 1) return OfferQuickOption.stops1;
      if (v == 2) return OfferQuickOption.stops2;
    }

    return OfferQuickOption.none;
  }

  String formatDateStr(String dateStr) {
    if (dateStr.trim().isEmpty) return '';

    DateTime dt;
    try {
      dt = DateTime.parse(dateStr).toLocal();
    } catch (_) {
      dt = DateFormat('yyyy-MM-dd').parse(dateStr);
    }

    return AppFuns.replaceArabicNumbers(DateFormat('EEEE، d MMMM', 'ar').format(dt));
  }

  @override
  Widget build(BuildContext context) {
    final bool isFilter = filterState.isFilter;
    final cs = Theme.of(context).colorScheme;
    final availableStops = _extractStops(allOffers);
    final bool isExpanded = expansionController.isExpanded;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final ok = await AppFuns.confirmExit(
          title: "Exit".tr,
          message: "Are you sure you want to exit?".tr,
        );

        if (ok && context.mounted) {
          Navigator.of(context).pop(result);
        }
      },
      child: SafeArea(
        bottom: true,
        top: false,
        left: false,
        right: false,
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Row(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    height: 40,
                    child: DropdownButtonFormField<OfferQuickOption>(
                      initialValue: _quickOptionFromState(filterState),
                      icon: const SizedBox.shrink(),
                      iconSize: 0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      isDense: true,
                      style: TextStyle(fontFamily: AppConsts.font, color: cs.primaryFixed),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsetsDirectional.only(start: 8),
                        filled: false,
                        hintText: 'Select option'.tr,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        isDense: true,
                      ),
                      items: <DropdownMenuItem<OfferQuickOption>>[
                        DropdownMenuItem(
                          value: OfferQuickOption.none,
                          child: Text(
                            'Smart filtering'.tr + " ...",
                            style: TextStyle(fontSize: AppConsts.lg, color: cs.tertiary),
                          ),
                        ),
                        DropdownMenuItem(
                          value: OfferQuickOption.priceLow,
                          child: Text(OfferQuickOption.priceLow.label.tr, style: TextStyle(fontSize: AppConsts.lg)),
                        ),
                        DropdownMenuItem(
                          value: OfferQuickOption.travelTimeLow,
                          child:
                              Text(OfferQuickOption.travelTimeLow.label.tr, style: TextStyle(fontSize: AppConsts.lg)),
                        ),
                        if (availableStops.contains(0))
                          DropdownMenuItem(
                            value: OfferQuickOption.stops0,
                            child: Text(OfferQuickOption.stops0.label.tr, style: TextStyle(fontSize: AppConsts.lg)),
                          ),
                        if (availableStops.contains(1))
                          DropdownMenuItem(
                            value: OfferQuickOption.stops1,
                            child: Text(OfferQuickOption.stops1.label.tr, style: TextStyle(fontSize: AppConsts.lg)),
                          ),
                        if (availableStops.contains(2))
                          DropdownMenuItem(
                            value: OfferQuickOption.stops2,
                            child: Text(OfferQuickOption.stops2.label.tr, style: TextStyle(fontSize: AppConsts.lg)),
                          ),
                      ],
                      onChanged: (v) async {
                        if (v == null) return;

                        switch (v) {
                          case OfferQuickOption.none:
                            filterState = filterState.copyWith(stops: <int>{}, sort: null, setSortNull: true);
                            break;

                          case OfferQuickOption.priceLow:
                            filterState = filterState.copyWith(stops: <int>{}, sort: SortOffersOption.priceLow);
                            break;

                          case OfferQuickOption.travelTimeLow:
                            filterState = filterState.copyWith(stops: <int>{}, sort: SortOffersOption.travelTimeLow);
                            break;

                          case OfferQuickOption.stops0:
                            filterState = filterState.copyWith(stops: <int>{0}, sort: null, setSortNull: true);
                            break;

                          case OfferQuickOption.stops1:
                            filterState = filterState.copyWith(stops: <int>{1}, sort: null, setSortNull: true);
                            break;

                          case OfferQuickOption.stops2:
                            filterState = filterState.copyWith(stops: <int>{2}, sort: null, setSortNull: true);
                            break;
                        }

                        await _rebuildOffersFromState(scrollTop: true);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            actions: [
              SizedBox(
                height: 40,
                child: OutlinedButton.icon(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                  icon: const Icon(Icons.filter_alt_outlined),
                  label: Text(
                    'Sort & Filter'.tr + (isFilter ? ' (${filterState.countFiltersActive})' : ''),
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
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade400)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ExpansionTile(
                        controller: expansionController,
                        title: Text(
                          (isExpanded) ? "Hide edit Search".tr : "Edit Search".tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppConsts.font,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: [
                          GradientBgContainer(
                            width: double.infinity,
                            child: Row(
                              children: [
                                const SizedBox(width: 8),
                                const Icon(FontAwesomeIcons.route,
                                    color: Color.fromARGB(255, 211, 163, 60), size: 24),
                                Expanded(
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        child: RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontFamily: AppConsts.font,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: cs.shadow,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: AirportRepo.searchByCode(searchInputs.from).name[AppVars.lang] +
                                                    " (${searchInputs.from})" +
                                                    ", " +
                                                    AirportRepo.searchByCode(searchInputs.from).body[AppVars.lang],
                                              ),
                                              WidgetSpan(
                                                alignment: PlaceholderAlignment.middle,
                                                child: Container(
                                                  margin: const EdgeInsets.only(left: 4, right: 4),
                                                  child: Icon(
                                                    (searchInputs.journeyEnum == JourneyType.roundTrip)
                                                        ? Icons.sync_alt
                                                        : Icons.arrow_forward,
                                                    size: 20,
                                                    color: cs.shadow,
                                                  ),
                                                ),
                                              ),
                                              TextSpan(
                                                text: AirportRepo.searchByCode(searchInputs.to).name[AppVars.lang] +
                                                    " (${searchInputs.to})" +
                                                    ", " +
                                                    AirportRepo.searchByCode(searchInputs.to).body[AppVars.lang],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xfff7f0de),
                                          borderRadius: BorderRadius.circular(99),
                                        ),
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontFamily: AppConsts.font,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: cs.shadow,
                                            ),
                                            children: [
                                              TextSpan(text: formatDateStr(searchInputs.departureDate)),
                                              WidgetSpan(
                                                alignment: PlaceholderAlignment.middle,
                                                child: Container(
                                                  margin: const EdgeInsets.only(left: 4, right: 4, top: 2),
                                                  width: 6,
                                                  height: 6,
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(0xff9ea1a9),
                                                  ),
                                                ),
                                              ),
                                              TextSpan(text: "${searchInputs.adt} " + "Adult".tr),
                                              if (searchInputs.chd > 0) TextSpan(text: ", ${searchInputs.chd} " + "Child".tr),
                                              if (searchInputs.inf > 0) TextSpan(text: ", ${searchInputs.inf} " + "Infant".tr),
                                              WidgetSpan(
                                                alignment: PlaceholderAlignment.middle,
                                                child: Container(
                                                  margin: const EdgeInsets.only(left: 4, right: 4, top: 2),
                                                  width: 6,
                                                  height: 6,
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(0xff9ea1a9),
                                                  ),
                                                ),
                                              ),
                                              TextSpan(
                                                text: " (${AppFuns.cabinNameFromBookingClass(searchInputs.cabin)})",
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
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

              // ============ Edit Search Expanded ============
              if (isExpanded) ...[
                Expanded(
                  child: SearchFlight(
                    isEditor: true,
                    onResult: (result) async {
                      setState(() {
                        filterState = const FilterOffersState();
                        searchInputs = result.params;

                        allOffers = result.outbound.map((e) => FlightOfferModel.fromJson(e)).toList();
                        offers = List<FlightOfferModel>.from(allOffers);
                      });

                      expansionController.collapse();

                      await Future.delayed(const Duration(milliseconds: 250));
                      if (!mounted) return;

                      await _rebuildOffersFromState(scrollTop: true);

                      // (اختياري) تأكيد الإغلاق
                      expansionController.collapse();
                    },
                  ),
                ),
              ],

              // ============ Results ============
              if (!isExpanded) ...[
                if (offers.isNotEmpty)
                  Expanded(
                    child: CupertinoScrollbar(
                      controller: scrollController,
                      child: CustomScrollView(
                        controller: scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                            child: FlightFareCalendar(
                              scrollController2: scrollController2,
                              selectedIndex: 4,
                            ),
                          ),

                          // ✅ SliverList = lazy build (أسرع بكثير من shrinkWrap داخل SingleChildScrollView)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final offer = offers[index];

                                return RepaintBoundary(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: FlightOfferCard(
                                      offer: offer,
                                      onBook: () async {
                                        context.loaderOverlay.show(progress: "Switching to passenger data".tr);
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
                                          () => MoreFlightDetailPage(
                                            flightOffer: offer,
                                            fareRules: const [],
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
                                            revalidatedDetails: RevalidatedFlightModel(
                                              offer: offer,
                                              isRefundable: offer.isRefundable,
                                              isPassportMandatory: false,
                                              firstNameCharacterLimit: 0,
                                              lastNameCharacterLimit: 0,
                                              paxNameCharacterLimit: 0,
                                              fareRules: const [],
                                            ),
                                          ),
                                        );
                                      },
                                      onMoreDetails: () {
                                        Get.to(() => MoreFlightDetailPage(flightOffer: offer, fareRules: []));
                                      },
                                    ),
                                  ),
                                );
                              },
                              childCount: offers.length,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (offers.isEmpty) Center(child: Text('No offers found'.tr)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class FlightOfferCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isUpsellEnabled = AppFuns.isUpsellEnabledAirline(offer.airlineCode);

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
      onTap: () {},
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
                  if (showFare ?? true)
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
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 6),

              Row(
                children: [
                  if (showSeatLeft)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(Icons.event_seat, size: 18),
                          const SizedBox(width: 2),
                          Text(
                            '${offer.seatsRemaining} ${'Seats left'.tr}',
                            style: theme.textTheme.bodySmall!.copyWith(
                              fontSize: 12,
                              color: Colors.red[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (showBaggage)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.luggage,
                            size: 18,
                            color: (offer.baggageInfo != null) ? Colors.blue[900]!.withOpacity(0.8) : Colors.red,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            (offer.baggageInfo ?? 'N/A'.tr).split(',').first,
                            style: theme.textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: (offer.baggageInfo == null) ? Colors.red : cs.primaryFixed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (showSeatLeft && showBaggage)
                    Expanded(
                      child: Text(
                        (offer.cabinClassText.replaceAll("Standard", "").trim()).tr,
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodySmall!.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              if (onBook != null || onOtherPrices != null)
                Row(
                  children: [
                    if (onBook != null)
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: CustomButton(
                            onPressed: onBook!,
                            icon: const Icon(Icons.flight_takeoff),
                            label: Text('Book now'.tr),
                          ),
                        ),
                      ),
                    if (onBook != null && onOtherPrices != null) ...[const SizedBox(width: 8)],
                    if (onOtherPrices != null)
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              backgroundColor: cs.secondary,
                              foregroundColor: cs.shadow,
                            ),
                            onPressed: (isUpsellEnabled) ? onOtherPrices! : null,
                            icon: const Icon(Icons.attach_money),
                            label: Text('Other Prices'.tr),
                          ),
                        ),
                      ),
                  ],
                ),

              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 0)),
                    onPressed: onDetails,
                    icon: const Icon(Icons.info),
                    label: Text('View flight details'.tr),
                  ),
                ),
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
class _LegRow extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final from = AirportRepo.searchByCode(leg.fromCode);
    final fromName = from.name[AppVars.lang];

    final to = AirportRepo.searchByCode(leg.toCode);
    final toName = to.name[AppVars.lang];

    final depTimeFull = AppFuns.replaceArabicNumbers(timeFormat.format(leg.departureDateTime));
    final arrTimeFull = AppFuns.replaceArabicNumbers(timeFormat.format(leg.arrivalDateTime));
    final depDate = AppFuns.replaceArabicNumbers(dateFormat.format(leg.departureDateTime));
    final arrDate = AppFuns.replaceArabicNumbers(dateFormat.format(leg.arrivalDateTime));

    final justDepTime = depTimeFull.split(' ')[0];
    final periodDepTime = depTimeFull.split(' ')[1];
    final justArrTime = arrTimeFull.split(' ')[0];
    final periodArrTime = arrTimeFull.split(' ')[1];

    String stopsText;
    if (leg.stops == 0) {
      stopsText = 'Direct'.tr;
    } else if (leg.stops == 1) {
      stopsText = '1 ${'Stop'.tr}';
    } else {
      stopsText = '${leg.stops} ${'Stops'.tr}';
    }

    final legCodes = _uniqueMarketingCodesForLeg(leg);
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
    final cs = Theme.of(context).colorScheme;

    // (غير مستخدم بصريًا لكنه كان موجود عندك)
    // final double planeAngle = isArabic ? -math.pi / 2 : math.pi / 2;
    // ignore: unused_local_variable
    final double planeAngle = isArabic ? -math.pi / 2 : math.pi / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showLegAirlinesHeader) ...[
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Departure
            Column(
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
                      Text(justDepTime, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          periodDepTime,
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 2),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(leg.fromCode, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(fromName, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
              ],
            ),

            // Middle
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12),
                    child: Text(
                      AppFuns.formatHourMinuteSecond(leg.totalDurationText),
                      textAlign: TextAlign.start,
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        height: 12,
                        width: 12,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primaryFixed),
                      ),
                      Expanded(
                        child: Padding(padding: const EdgeInsets.only(top: 6), child: DividerLine()),
                      ),
                      Transform.flip(flipX: !isArabic, child: Image.asset(AppConsts.plane, width: 44)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFf7efe9), borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        stopsText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF9c5627),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Arrival
            Column(
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
                      Text(justArrTime, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          periodArrTime,
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 2),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(leg.toCode, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
          ],
        ),
      ],
    );
  }
}

class FlightFareCalendar extends StatefulWidget {
  const FlightFareCalendar({
    super.key,
    required this.scrollController2,
    required this.selectedIndex,
    this.itemCount = 7,
    this.onTap,
  });

  final ScrollController scrollController2;
  final int selectedIndex;
  final int itemCount;
  final ValueChanged<int>? onTap;

  @override
  State<FlightFareCalendar> createState() => _FlightFareCalendarState();
}

class _FlightFareCalendarState extends State<FlightFareCalendar> {
  late List<GlobalKey> _itemKeys;

  @override
  void initState() {
    super.initState();
    _itemKeys = List.generate(widget.itemCount, (_) => GlobalKey());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected(animated: false);
    });
  }

  @override
  void didUpdateWidget(covariant FlightFareCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.itemCount != widget.itemCount) {
      _itemKeys = List.generate(widget.itemCount, (_) => GlobalKey());
    }

    if (oldWidget.selectedIndex != widget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelected(animated: true);
      });
    }
  }

  void _scrollToSelected({required bool animated}) {
    if (!widget.scrollController2.hasClients) return;

    final idx = widget.selectedIndex.clamp(0, _itemKeys.length - 1);
    final ctx = _itemKeys[idx].currentContext;
    if (ctx == null) return;

    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: animated ? const Duration(milliseconds: 350) : Duration.zero,
      curve: Curves.easeOutCubic,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return CupertinoScrollbar(
      controller: widget.scrollController2,
      thumbVisibility: true,
      thickness: 6,
      child: SingleChildScrollView(
        controller: widget.scrollController2,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 18),
        child: Row(
          spacing: 8,
          children: List.generate(widget.itemCount, (index) {
            final isSelected = widget.selectedIndex == index;

            return Container(
              key: _itemKeys[index],
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  backgroundColor: isSelected ? const Color(0xFFe2e6f9) : cs.onPrimary,
                  foregroundColor: cs.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                ),
                onPressed: () => widget.onTap?.call(index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Saturday".tr),
                        const SizedBox(width: 4),
                        Container(
                          height: 6,
                          width: 6,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF687489)),
                        ),
                        const SizedBox(width: 4),
                        Text("12 ${"Feb".tr}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "117",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF4fa054)),
                        ),
                        SizedBox(width: 4),
                        Text(
                          "USD",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF687489)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
