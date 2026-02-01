// lib/controller/flight/filter_offers_controller.dart
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:alzajeltravel/model/flight/flight_offer_model.dart';

enum TimeBucket { earlyMorning, morning, afternoon, evening }

// Sort options (nullable in state/controller means: no sort)
enum SortOffersOption {
  priceLow,
  priceHigh,
  travelTimeLow,
  travelTimeHigh,
}


enum OfferQuickOption {
  none,

  // sort
  priceLow,
  travelTimeLow,

  // stops
  stops0,
  stops1,
  stops2,
}

extension OfferQuickOptionX on OfferQuickOption {
  String get label {
    switch (this) {
      case OfferQuickOption.none:
        return 'No selection';

      case OfferQuickOption.priceLow:
        return FilterOffersController.sortLabel(SortOffersOption.priceLow);

      case OfferQuickOption.travelTimeLow:
        return FilterOffersController.sortLabel(SortOffersOption.travelTimeLow);

      case OfferQuickOption.stops0:
        return 'Non-stop';

      case OfferQuickOption.stops1:
        return '1 stop';

      case OfferQuickOption.stops2:
        return '2+ stops';
    }
  }
}


class FilterOffersState {
  final Set<int> stops; // 0,1,2 (2 = 2+)
  final Set<String> airlineCodes;
  final Set<TimeBucket> departureBuckets;
  final Set<TimeBucket> arrivalBuckets;

  // Range filters (null => no filter => full bounds)
  final double? priceFrom;
  final double? priceTo;

  // minutes
  final int? travelTimeFrom;
  final int? travelTimeTo;

  // sorting
  final SortOffersOption? sort;

  bool get isFilter =>
      stops.isNotEmpty ||
      airlineCodes.isNotEmpty ||
      departureBuckets.isNotEmpty ||
      arrivalBuckets.isNotEmpty ||
      priceFrom != null ||
      priceTo != null ||
      travelTimeFrom != null ||
      travelTimeTo != null ||
      sort != null;

  int get countFiltersActive =>
      stops.length +
      airlineCodes.length +
      departureBuckets.length +
      arrivalBuckets.length +
      (priceFrom != null ? 1 : 0) +
      (priceTo != null ? 1 : 0) +
      (travelTimeFrom != null ? 1 : 0) +
      (travelTimeTo != null ? 1 : 0) +
      (sort != null ? 1 : 0);

  const FilterOffersState({
    this.stops = const <int>{},
    this.airlineCodes = const <String>{},
    this.departureBuckets = const <TimeBucket>{},
    this.arrivalBuckets = const <TimeBucket>{},
    this.priceFrom,
    this.priceTo,
    this.travelTimeFrom,
    this.travelTimeTo,
    this.sort,
  });

  FilterOffersState copyWith({
    Set<int>? stops,
    Set<String>? airlineCodes,
    Set<TimeBucket>? departureBuckets,
    Set<TimeBucket>? arrivalBuckets,
    double? priceFrom,
    double? priceTo,
    int? travelTimeFrom,
    int? travelTimeTo,
    SortOffersOption? sort,
    bool setPriceNull = false,
    bool setTravelTimeNull = false,
    bool setSortNull = false,
  }) {
    return FilterOffersState(
      stops: stops ?? this.stops,
      airlineCodes: airlineCodes ?? this.airlineCodes,
      departureBuckets: departureBuckets ?? this.departureBuckets,
      arrivalBuckets: arrivalBuckets ?? this.arrivalBuckets,
      priceFrom: setPriceNull ? null : (priceFrom ?? this.priceFrom),
      priceTo: setPriceNull ? null : (priceTo ?? this.priceTo),
      travelTimeFrom: setTravelTimeNull ? null : (travelTimeFrom ?? this.travelTimeFrom),
      travelTimeTo: setTravelTimeNull ? null : (travelTimeTo ?? this.travelTimeTo),
      sort: setSortNull ? null : (sort ?? this.sort),
    );
  }
}

class FilterOffersResult {
  final List<FlightOfferModel> filteredOffers;
  final FilterOffersState state;

  const FilterOffersResult({
    required this.filteredOffers,
    required this.state,
  });
}

class FilterOffersController extends GetxController {
  final List<FlightOfferModel> originalOffers;
  final FilterOffersState initialState;

  // available stops in current search results: 0,1,2 (2 = 2+)
  late final List<int> availableStops;

  FilterOffersController({
    required this.originalOffers,
    required this.initialState,
  });

  // selections (multi)
  final Set<int> selectedStops = <int>{}; // 0,1,2 (2=2+)
  final Set<String> selectedAirlineCodes = <String>{};
  final Set<TimeBucket> selectedDepartureBuckets = <TimeBucket>{};
  final Set<TimeBucket> selectedArrivalBuckets = <TimeBucket>{};

  // sorting
  SortOffersOption? selectedSort;

  // available airlines (codes)
  late final List<String> availableAirlineCodes;

  // bounds
  late final double minPrice;
  late final double maxPrice;
  late final int minTravelMinutes;
  late final int maxTravelMinutes;

  // slider values
  late double selectedPriceFrom;
  late double selectedPriceTo;
  late int selectedTravelFrom;
  late int selectedTravelTo;

  // slider ranges (safe for UI even if equal)
  late final double sliderPriceMax;
  late final int sliderTravelMax;

  @override
  void onInit() {
    super.onInit();

    // init multi selections from previous state
    selectedStops.addAll(initialState.stops);
    selectedAirlineCodes.addAll(initialState.airlineCodes);
    selectedDepartureBuckets.addAll(initialState.departureBuckets);
    selectedArrivalBuckets.addAll(initialState.arrivalBuckets);

    selectedSort = initialState.sort;

    // airlines from any segment (out+in)
    availableAirlineCodes = _extractAirlineCodes(originalOffers);

    // bounds
    final priceBounds = _calcPriceBounds(originalOffers);
    minPrice = priceBounds.$1;
    maxPrice = priceBounds.$2;

    final travelBounds = _calcTravelBounds(originalOffers);
    minTravelMinutes = travelBounds.$1;
    maxTravelMinutes = travelBounds.$2;

    // available stops in current search results: 0,1,2 (2 = 2+)
    availableStops = _extractStops(originalOffers);

    // safe max for sliders (avoid min==max issues)
    sliderPriceMax = (maxPrice <= minPrice) ? (minPrice + 1) : maxPrice;
    sliderTravelMax = (maxTravelMinutes <= minTravelMinutes) ? (minTravelMinutes + 1) : maxTravelMinutes;

    // selected ranges:
    selectedPriceFrom = (initialState.priceFrom ?? minPrice).clamp(minPrice, sliderPriceMax);
    selectedPriceTo = (initialState.priceTo ?? maxPrice).clamp(minPrice, sliderPriceMax);
    if (selectedPriceFrom > selectedPriceTo) {
      final tmp = selectedPriceFrom;
      selectedPriceFrom = selectedPriceTo;
      selectedPriceTo = tmp;
    }

    selectedTravelFrom = _clampInt(initialState.travelTimeFrom ?? minTravelMinutes, minTravelMinutes, sliderTravelMax);
    selectedTravelTo = _clampInt(initialState.travelTimeTo ?? maxTravelMinutes, minTravelMinutes, sliderTravelMax);
    if (selectedTravelFrom > selectedTravelTo) {
      final tmp = selectedTravelFrom;
      selectedTravelFrom = selectedTravelTo;
      selectedTravelTo = tmp;
    }
  }

  // ===== labels =====
  static String bucketLabel(TimeBucket b) {
    switch (b) {
      case TimeBucket.earlyMorning:
        return 'Early Morning (12:00 am - 4:59 am)';
      case TimeBucket.morning:
        return 'Morning (5:00 am - 11:59 am)';
      case TimeBucket.afternoon:
        return 'Afternoon (12:00 pm - 5:59 pm)';
      case TimeBucket.evening:
        return 'Evening (6:00 pm - 11:59 pm)';
    }
  }

  static TimeBucket bucketOf(DateTime dt) {
    final h = dt.hour;
    if (h >= 0 && h <= 4) return TimeBucket.earlyMorning;
    if (h >= 5 && h <= 11) return TimeBucket.morning;
    if (h >= 12 && h <= 17) return TimeBucket.afternoon;
    return TimeBucket.evening;
  }

  static String minutesToText(int minutes) {
    final m = minutes < 0 ? 0 : minutes;
    final h = m ~/ 60;
    final r = m % 60;
    if (h == 0) return '${r}m';
    if (r == 0) return '${h}h';
    return '${h}h ${r}m';
  }

  static String sortLabel(SortOffersOption o) {
    switch (o) {
      case SortOffersOption.priceLow:
        return 'Price (Lowest)';
      case SortOffersOption.priceHigh:
        return 'Price (Highest)';
      case SortOffersOption.travelTimeLow:
        return 'Travel time (Lowest)';
      case SortOffersOption.travelTimeHigh:
        return 'Travel time (Highest)';
    }
  }

  // ===== filter activity =====
  bool get _priceIsFiltered => (selectedPriceFrom > minPrice + 1e-9) || (selectedPriceTo < maxPrice - 1e-9);
  bool get _travelIsFiltered => (selectedTravelFrom > minTravelMinutes) || (selectedTravelTo < maxTravelMinutes);

  bool get hasAnyFilter =>
      selectedStops.isNotEmpty ||
      selectedAirlineCodes.isNotEmpty ||
      selectedDepartureBuckets.isNotEmpty ||
      selectedArrivalBuckets.isNotEmpty ||
      _priceIsFiltered ||
      _travelIsFiltered ||
      selectedSort != null;

  // ===== toggles =====
  void toggleStop(int stop) {
    if (selectedStops.contains(stop)) {
      selectedStops.remove(stop);
    } else {
      selectedStops.add(stop);
    }
    update();
  }

  void toggleAirline(String code) {
    if (selectedAirlineCodes.contains(code)) {
      selectedAirlineCodes.remove(code);
    } else {
      selectedAirlineCodes.add(code);
    }
    update();
  }

  void toggleDepartureBucket(TimeBucket b) {
    if (selectedDepartureBuckets.contains(b)) {
      selectedDepartureBuckets.remove(b);
    } else {
      selectedDepartureBuckets.add(b);
    }
    update();
  }

  void toggleArrivalBucket(TimeBucket b) {
    if (selectedArrivalBuckets.contains(b)) {
      selectedArrivalBuckets.remove(b);
    } else {
      selectedArrivalBuckets.add(b);
    }
    update();
  }

  void updatePriceRange(double from, double to) {
    selectedPriceFrom = from.clamp(minPrice, sliderPriceMax);
    selectedPriceTo = to.clamp(minPrice, sliderPriceMax);
    if (selectedPriceFrom > selectedPriceTo) {
      final tmp = selectedPriceFrom;
      selectedPriceFrom = selectedPriceTo;
      selectedPriceTo = tmp;
    }
    update();
  }

  void updateTravelRange(int from, int to) {
    selectedTravelFrom = _clampInt(from, minTravelMinutes, sliderTravelMax);
    selectedTravelTo = _clampInt(to, minTravelMinutes, sliderTravelMax);
    if (selectedTravelFrom > selectedTravelTo) {
      final tmp = selectedTravelFrom;
      selectedTravelFrom = selectedTravelTo;
      selectedTravelTo = tmp;
    }
    update();
  }

  void setSort(SortOffersOption? option) {
    selectedSort = option;
    update();
  }

  void clearAll() {
    selectedStops.clear();
    selectedAirlineCodes.clear();
    selectedDepartureBuckets.clear();
    selectedArrivalBuckets.clear();

    selectedSort = null;

    // reset sliders to full bounds
    selectedPriceFrom = minPrice;
    selectedPriceTo = maxPrice.clamp(minPrice, sliderPriceMax);
    selectedTravelFrom = minTravelMinutes;
    selectedTravelTo = maxTravelMinutes.clamp(minTravelMinutes, sliderTravelMax);

    update();
  }

  FilterOffersState buildState() {
    // store null when range == full bounds (so it's considered "no filter")
    final double? priceFromState = _priceIsFiltered ? selectedPriceFrom : null;
    final double? priceToState = _priceIsFiltered ? selectedPriceTo : null;

    final int? travelFromState = _travelIsFiltered ? selectedTravelFrom : null;
    final int? travelToState = _travelIsFiltered ? selectedTravelTo : null;

    return FilterOffersState(
      stops: Set<int>.from(selectedStops),
      airlineCodes: Set<String>.from(selectedAirlineCodes),
      departureBuckets: Set<TimeBucket>.from(selectedDepartureBuckets),
      arrivalBuckets: Set<TimeBucket>.from(selectedArrivalBuckets),
      priceFrom: priceFromState,
      priceTo: priceToState,
      travelTimeFrom: travelFromState,
      travelTimeTo: travelToState,
      sort: selectedSort,
    );
  }

  // ===== matching logic (one-way + round-trip) =====

  bool _matchStops(FlightOfferModel offer) {
    if (selectedStops.isEmpty) return true;

    // OR between legs
    for (final leg in offer.legs) {
      final s = leg.stops;
      final normalized = s >= 2 ? 2 : s;
      if (selectedStops.contains(normalized)) return true;
    }
    return false;
  }

  bool _matchAirlines(FlightOfferModel offer) {
    if (selectedAirlineCodes.isEmpty) return true;

    final codesInOffer = offer.segments
        .map((s) => s.marketingAirlineCode.trim())
        .where((c) => c.isNotEmpty)
        .toSet();

    return codesInOffer.intersection(selectedAirlineCodes).isNotEmpty;
  }

  bool _matchDepartureTime(FlightOfferModel offer) {
    if (selectedDepartureBuckets.isEmpty) return true;

    for (final leg in offer.legs) {
      final b = bucketOf(leg.departureDateTime);
      if (selectedDepartureBuckets.contains(b)) return true;
    }
    return false;
  }

  bool _matchArrivalTime(FlightOfferModel offer) {
    if (selectedArrivalBuckets.isEmpty) return true;

    for (final leg in offer.legs) {
      final b = bucketOf(leg.arrivalDateTime);
      if (selectedArrivalBuckets.contains(b)) return true;
    }
    return false;
  }

  bool _matchPrice(FlightOfferModel offer) {
    if (!_priceIsFiltered) return true;
    final v = offer.totalAmount;
    return v >= selectedPriceFrom && v <= selectedPriceTo;
  }

  bool _matchTravelTime(FlightOfferModel offer) {
    if (!_travelIsFiltered) return true;

    // match if ANY leg duration is within range (as you already decided)
    for (final leg in offer.legs) {
      final minutes = _parseDurationToMinutes(leg.totalDurationText);
      if (minutes == null) continue;
      if (minutes >= selectedTravelFrom && minutes <= selectedTravelTo) return true;
    }
    return false;
  }

  // ===== sorting =====

  int? _offerTotalDurationMinutes(FlightOfferModel offer) {
    // total duration for whole itinerary = sum of each leg totalDurationText
    int sum = 0;
    for (final leg in offer.legs) {
      final m = _parseDurationToMinutes(leg.totalDurationText);
      if (m == null) return null;
      sum += m;
    }
    return sum;
  }

  List<FlightOfferModel> _applySort(List<FlightOfferModel> list) {
    final s = selectedSort;
    if (s == null) return list;

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

    return list;
  }

  List<FlightOfferModel> applyFilters() {
    // even if no filters, we may still sort
    final base = List<FlightOfferModel>.from(originalOffers);

    final filtered = base.where((offer) {
      if (!_matchStops(offer)) return false;
      if (!_matchAirlines(offer)) return false;
      if (!_matchDepartureTime(offer)) return false;
      if (!_matchArrivalTime(offer)) return false;
      if (!_matchPrice(offer)) return false;
      if (!_matchTravelTime(offer)) return false;
      return true;
    }).toList();

    return _applySort(filtered);
  }

  void done() {
    final filtered = applyFilters();
    final state = buildState();
    Get.back(result: FilterOffersResult(filteredOffers: filtered, state: state));
  }

  // ===== helpers =====

  static (double, double) _calcPriceBounds(List<FlightOfferModel> offers) {
    if (offers.isEmpty) return (0.0, 0.0);
    double mn = offers.first.totalAmount;
    double mx = offers.first.totalAmount;
    for (final o in offers) {
      mn = math.min(mn, o.totalAmount);
      mx = math.max(mx, o.totalAmount);
    }
    return (mn, mx);
  }

  static (int, int) _calcTravelBounds(List<FlightOfferModel> offers) {
    if (offers.isEmpty) return (0, 0);

    int? mn;
    int? mx;

    for (final o in offers) {
      for (final leg in o.legs) {
        final minutes = _parseDurationToMinutes(leg.totalDurationText);
        if (minutes == null) continue;

        mn = (mn == null) ? minutes : math.min(mn, minutes);
        mx = (mx == null) ? minutes : math.max(mx, minutes);
      }
    }

    return (mn ?? 0, mx ?? 0);
  }

  static List<String> _extractAirlineCodes(List<FlightOfferModel> offers) {
    final set = <String>{};
    for (final o in offers) {
      for (final s in o.segments) {
        final c = s.marketingAirlineCode.trim();
        if (c.isNotEmpty) set.add(c);
      }
    }
    final list = set.toList();
    list.sort();
    return list;
  }

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

  static int _clampInt(int v, int min, int max) {
    if (v < min) return min;
    if (v > max) return max;
    return v;
  }

  /// Parses formats like:
  /// "01h: 30m", "8h: 45m", "10h: 25m", "00h: 00m"
  static int? _parseDurationToMinutes(String text) {
    final s = text.trim();
    if (s.isEmpty) return null;

    final m = RegExp(r'(\d+)\s*h\s*:\s*(\d+)\s*m', caseSensitive: false).firstMatch(s);
    if (m == null) return null;

    final h = int.tryParse(m.group(1) ?? '');
    final mm = int.tryParse(m.group(2) ?? '');
    if (h == null || mm == null) return null;

    return (h * 60) + mm;
  }
}
