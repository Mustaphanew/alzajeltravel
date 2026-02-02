// lib/view/frame/flights/flight_offers_list.dart
import 'dart:async';
import 'dart:math' as math;

import 'package:alzajeltravel/controller/flight/filter_offers_controller.dart';
import 'package:alzajeltravel/controller/flight/other_prices_controller.dart';
import 'package:alzajeltravel/controller/search_flight_controller.dart';
import 'package:alzajeltravel/model/flight/flight_search_params.dart';
import 'package:alzajeltravel/repo/airline_repo.dart';
import 'package:alzajeltravel/repo/airport_repo.dart';
import 'package:alzajeltravel/utils/enums.dart';
import 'package:alzajeltravel/utils/widgets/custom_button.dart';
import 'package:alzajeltravel/view/frame/flights/filter_offers_page.dart';
import 'package:alzajeltravel/view/frame/flights/other_prices/other_prices_page.dart';
import 'package:alzajeltravel/view/frame/search_flight.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  final FlightSearchParams searchInputs;

  const FlightOffersList({super.key, required this.flightOffers, required this.searchInputs});

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

  late FlightSearchParams searchInputs;

  @override
  void initState() {
    super.initState();

    searchInputs = widget.searchInputs;

    detailCtrl = Get.put(FlightDetailApiController(), );
    otherPricesCtrl = Get.put(OtherPricesController(),);

    allOffers = widget.flightOffers.map((e) => FlightOfferModel.fromJson(e)).toList();
    offers = List<FlightOfferModel>.from(allOffers);

    _rebuildOffersFromState();

    scrollController.addListener(_handleScroll);

  }

  void _handleScroll() {
  if (!scrollController.hasClients) return;

  final dir = scrollController.position.userScrollDirection;

  if (dir == ScrollDirection.reverse && _showFab) {
    setState(() => _showFab = false);
  } else if (dir == ScrollDirection.forward && !_showFab) {
    setState(() => _showFab = true);
  }
}

  bool _showFab = true;
  Timer? _showTimer;

  @override
  void dispose() {
    scrollController.removeListener(_handleScroll);
    scrollController.dispose();
    _showTimer?.cancel();
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

  int? _stopsToDropdownValue(Set<int> stops) {
    // null = All stops (no filter)
    if (stops.isEmpty) return null;
    if (stops.length == 1) return stops.first;
    // لو كانت multi-selection (غير مستخدم هنا) اعتبرها All
    return null;
  }

  OfferQuickOption _quickOptionFromState(FilterOffersState s) {
    // إذا فيه sort (ومن الخيارات المسموحة)
    if (s.sort == SortOffersOption.priceLow) return OfferQuickOption.priceLow;
    if (s.sort == SortOffersOption.travelTimeLow) return OfferQuickOption.travelTimeLow;

    // إذا فيه stops محدد (اختيار واحد)
    if (s.stops.length == 1) {
      final v = s.stops.first;
      if (v == 0) return OfferQuickOption.stops0;
      if (v == 1) return OfferQuickOption.stops1;
      if (v == 2) return OfferQuickOption.stops2;
    }

    return OfferQuickOption.none;
  }

  

  @override
  Widget build(BuildContext context) {

    final bool isFilter = filterState.isFilter;
    final cs = Theme.of(context).colorScheme;
    final availableStops = _extractStops(allOffers); // ترجع List<int> مثل [0,1,2]

    return PopScope(

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
      

      child: SafeArea(
        bottom: true,
        top: false,
        left: false,
        right: false,
        child: Scaffold(
          appBar: AppBar(
            // title: Text('${'Flight Offers'.tr} (${offers.length})'),
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
                      icon: SizedBox.shrink(),
                      iconSize: 0,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      isDense: true,
                      style: TextStyle(
                        fontFamily: AppConsts.font,
                        color: cs.primaryFixed,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsetsDirectional.only(start: 8),
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
                            style: TextStyle(
                              fontSize: AppConsts.lg,
                              color: cs.tertiary
                            ),
                          ),
                        ),
                    
                        // sort options (فقط المطلوبين)
                        DropdownMenuItem(
                          value: OfferQuickOption.priceLow,
                          child: Text(OfferQuickOption.priceLow.label.tr, style: TextStyle(fontSize: AppConsts.lg)),
                        ),
                        DropdownMenuItem(
                          value: OfferQuickOption.travelTimeLow,
                          child: Text(OfferQuickOption.travelTimeLow.label.tr, style: TextStyle(fontSize: AppConsts.lg)),
                        ),
                    
                        // stops options (ديناميكي حسب نتائج allOffers)
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
                    
                        setState(() {
                          switch (v) {
                            case OfferQuickOption.none:
                              // لا شيء: امسح sort + امسح stops (no filter)
                              filterState = filterState.copyWith(
                                stops: <int>{},
                                sort: null,
                                setSortNull: true,
                              );
                              break;
                    
                            case OfferQuickOption.priceLow:
                              // sort فقط + امسح stops
                              filterState = filterState.copyWith(
                                stops: <int>{},
                                sort: SortOffersOption.priceLow,
                              );
                              break;
                    
                            case OfferQuickOption.travelTimeLow:
                              // sort فقط + امسح stops
                              filterState = filterState.copyWith(
                                stops: <int>{},
                                sort: SortOffersOption.travelTimeLow,
                              );
                              break;
                    
                            case OfferQuickOption.stops0:
                              // stops فقط + امسح sort
                              filterState = filterState.copyWith(
                                stops: <int>{0},
                                sort: null,
                                setSortNull: true,
                              );
                              break;
                    
                            case OfferQuickOption.stops1:
                              filterState = filterState.copyWith(
                                stops: <int>{1},
                                sort: null,
                                setSortNull: true,
                              );
                              break;
                    
                            case OfferQuickOption.stops2:
                              filterState = filterState.copyWith(
                                stops: <int>{2},
                                sort: null,
                                setSortNull: true,
                              );
                              break;
                          }
                        });
                    
                        await _rebuildOffersFromState(scrollTop: true);
                      },
                    ),
                  ),
                ),



                SizedBox(width: 8),

              
              ],
            ),
            actions: [
              SizedBox(
                height: 40,
                child: OutlinedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
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
          body: (offers.isNotEmpty)
              ? Column(
                  children: [

                       // ===== Sort dropdown (same value synced with FilterOffersPage) =====
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade400, 
                            ),
                          ),
                        ),
                        child: Row(
                          children: [

                  // edit search ______________
                  Expanded(
                    child: Container(
                      height: 55,
                      // padding: EdgeInsetsDirectional.only(end: 12),
                      child: ElevatedButton( 
                        style: ElevatedButton.styleFrom(
                          padding:  EdgeInsets.symmetric(horizontal: 12),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final result = await Get.to<FlightSearchResult>(
                            () => SearchFlight(
                              // frameContext: context,
                              isEditor: true,
                              // initialTabIndex: ... إذا تحتاج
                            ),
                            transition: Transition.downToUp,
                          );
                          if (!mounted || result == null) return;
                          // ✅ حدث نفس الصفحة لتصبح "النتائج الجديدة"
                          AppVars.apiSessionId = result.apiSessionId;
                          // setState(() {
                            searchInputs = result.params;
                            filterState = const FilterOffersState(); // اختياري: تصفير الفلاتر
                            allOffers = result.outbound.map((e) => FlightOfferModel.fromJson(e)).toList();
                            offers = List<FlightOfferModel>.from(allOffers);
                          // }); 
                          await _rebuildOffersFromState(scrollTop: true);
                          setState(() {});
                        },
                        
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    AirportRepo.searchByCode(searchInputs.from).name[AppVars.lang] + " (${searchInputs.from})",
                                    textAlign: TextAlign.end,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                if(searchInputs.journeyEnum == JourneyType.oneWay)
                                  Icon(Icons.arrow_forward), 
                                if(searchInputs.journeyEnum == JourneyType.roundTrip)
                                  Icon(Icons.sync_alt), 
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    AirportRepo.searchByCode(searchInputs.to).name[AppVars.lang] + " (${searchInputs.to})",
                                    textAlign: TextAlign.start,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: AppConsts.font,
                                  fontSize: 12,
                                ),
                                children: [
                                  TextSpan(text: "${searchInputs.adt} " + "Adult".tr),
                                  if(searchInputs.chd > 0)
                                    TextSpan(text: ", ${searchInputs.chd} " + "Child".tr),
                                  if(searchInputs.inf > 0)
                                    TextSpan(text: ", ${searchInputs.inf} " + "Infant".tr),
                                  TextSpan(text: " (${AppFuns.cabinNameFromBookingClass(searchInputs.cabin)})"),
                                ],
                              ),
                            )
                          ],
                        ),

                      ),
                    ),
                  ),
             
            


                          ],
                        ),
                      ),


                    Expanded(
                      child: CupertinoScrollbar(
                        controller: scrollController,
                        child: ListView.separated(
                          padding: EdgeInsets.only(top: 8),
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
        
          // floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
          // floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterTop,
          // floatingActionButton: AnimatedOpacity(
          //   duration: const Duration(milliseconds: 180),
          //   opacity: (_showFab == false) ? 1.0 : 0.0,
          //   child: Container(
          //     // height appbar
          //     padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top - 5),
          //     width: double.infinity,
          //     child: ElevatedButton.icon( 
          //       icon: const Icon(Icons.edit),
          //       style: ElevatedButton.styleFrom(
          //         shape: const RoundedRectangleBorder(
          //           borderRadius: BorderRadius.zero,
          //         ),
          //         backgroundColor: Colors.blue[800],
          //         foregroundColor: Colors.white,
          //       ),
          // onPressed: () async {
          //   final result = await Get.to<FlightSearchResult>(
          //     () => SearchFlight(
          //       // frameContext: context,
          //       isEditor: true,
          //       // initialTabIndex: ... إذا تحتاج
          //     ),
          //     transition: Transition.downToUp,
          //   );
          //   if (!mounted || result == null) return;
          //   // ✅ حدث نفس الصفحة لتصبح "النتائج الجديدة"
          //   AppVars.apiSessionId = result.apiSessionId;
          //   // setState(() {
          //     filterState = const FilterOffersState(); // اختياري: تصفير الفلاتر
          //     allOffers = result.outbound.map((e) => FlightOfferModel.fromJson(e)).toList();
          //     offers = List<FlightOfferModel>.from(allOffers);
          //   // }); 
          //   await _rebuildOffersFromState(scrollTop: true);
          //   setState(() {});
          // },
          //       label: Text('Edit Search'.tr),
          //     ),
          //   ),
          // ),
        
        ),
      ),
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

              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 6),

              Row(
                children: [
                  if (widget.showSeatLeft)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(Icons.event_seat, size: 18,),
                          const SizedBox(width: 2),
                          Text(
                            '${offer.seatsRemaining} ${'Seats left'.tr}', style: theme.textTheme.bodySmall!.copyWith(
                              fontSize: 12, color: Colors.red[800], fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  // const Spacer(),
                  if (widget.showBaggage)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.luggage, size: 18, color: (offer.baggageInfo != null) ? Colors.blue[900]!.withOpacity(0.8) : Colors.red),
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
                  if (widget.showSeatLeft && widget.showBaggage) 
                    // const Spacer(),
                  Expanded(
                    child: Text(
                      (offer.cabinClassText.replaceAll("Standard", "").trim()).tr, 
                      textAlign: TextAlign.end,
                      style: theme.textTheme.bodySmall!.copyWith(
                        fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              if (widget.onBook != null || widget.onOtherPrices != null)
                Row(
                  children: [
                    if (widget.onBook != null)
                      Expanded(
                        child: SizedBox( 
                          height: 40,
                          child: CustomButton(
                            onPressed: widget.onBook!,
                            icon: const Icon(Icons.flight_takeoff),
                            label: Text('Book now'.tr),
                          ),
                        ),
                      ),
                    if (widget.onBook != null && widget.onOtherPrices != null) ...[const SizedBox(width: 8)],
                    if (widget.onOtherPrices != null)
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric( vertical: 0),
                              backgroundColor: cs.secondary,
                              foregroundColor: Colors.black,
                            ),
                            onPressed: widget.onOtherPrices!,
                          icon: const Icon(Icons.attach_money),
                          label: Text('Other Prices'.tr),
                        ),
                        ),
                      ),
                  ],
                ),

              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric( vertical: 0),
                    ),
                    onPressed: widget.onDetails!,
                    icon: Icon(Icons.info),
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final from = AirportRepo.searchByCode(widget.leg.fromCode);
    fromName = from.name[AppVars.lang];

    final to = AirportRepo.searchByCode(widget.leg.toCode);
    toName = to.name[AppVars.lang];

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
                Text(widget.leg.fromCode, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(fromName, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
              ],
            ),
            
            // Middle
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.leg.totalDurationText,
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                  ),

                  Row(
                    children: [
                      const SizedBox(width: 12),
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        height: 12,
                        width: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primaryFixed,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: DividerLine(),
                        ),
                      ),
                      Transform.flip(
                        flipX: !isArabic,
                        child: Image.asset(AppConsts.plane, width: 44,),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                  
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 12),
                  //   child: Stack(
                  //     alignment: AlignmentDirectional.centerEnd,
                  //     children: [
                  //       Padding(
                  //         padding: const EdgeInsetsDirectional.only(end: 40),
                  //         child: DividerLine(),
                  //       ), 
                  //       // Transform.rotate(angle: planeAngle, child: const Icon(Icons.airplanemode_active, size: 27)),
                  //       Image.asset(AppConsts.plane, width: 44,),
                  //     ],
                  //   ),
                  // ),


                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Color(0xFFf7efe9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(stopsText, style: theme.textTheme.bodySmall?.copyWith(color: Color(0xFF9c5627), fontWeight: FontWeight.bold, fontSize: 13))),
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
          ],
        ),
      ],
    );
  }
}
