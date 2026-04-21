// lib/view/frame/flights/filter_offers_page.dart

import 'package:alzajeltravel/controller/flight/filter_offers_controller.dart';
import 'package:alzajeltravel/model/flight/flight_offer_model.dart';
import 'package:alzajeltravel/repo/airline_repo.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FilterOffersPage extends StatefulWidget {
  final List<FlightOfferModel> offers;
  final FilterOffersState state;

  const FilterOffersPage({
    super.key,
    required this.offers,
    required this.state,
  });

  @override
  State<FilterOffersPage> createState() => _FilterOffersPageState();
}

class _FilterOffersPageState extends State<FilterOffersPage> {
  late final String _tag;
  late final FilterOffersController ctrl;

  late final TextEditingController _outRefCtrl;
  late final TextEditingController _inRefCtrl;

  // ✅ يسمح فقط: A-Z 0-9 - ,
  final _refAllowed = FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-,]'));
  final _noSpaces = FilteringTextInputFormatter.deny(RegExp(r'\s'));

  @override
  void initState() {
    super.initState();
    _tag = 'filter_offers_${DateTime.now().microsecondsSinceEpoch}';

    ctrl = Get.put(
      FilterOffersController(
        originalOffers: widget.offers,
        initialState: widget.state,
      ),
      tag: _tag,
    );

    _outRefCtrl = TextEditingController(text: ctrl.outboundRefQuery);
    _inRefCtrl = TextEditingController(text: ctrl.inboundRefQuery);
  }

  @override
  void dispose() {
    _outRefCtrl.dispose();
    _inRefCtrl.dispose();
    Get.delete<FilterOffersController>(tag: _tag, force: true);
    super.dispose();
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 18, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: AppConsts.secondaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title.tr,
              style: t.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// بطاقة أقسام الفلتر: حواف ناعمة، إطار ذهبي خفيف، بدون ارتفاع مبالغ فيه
  Widget _filterCard({required Widget child}) {
    return Builder(
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? cs.surfaceContainerHighest.withValues(alpha: 0.92) : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppConsts.secondaryColor.withValues(alpha: isDark ? 0.28 : 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withValues(alpha: isDark ? 0.28 : 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: child,
            ),
          ),
        );
      },
    );
  }

  String _stopLabel(int s) {
    if (s == 0) return "Direct".tr;
    if (s == 1) return "1 Stop".tr;
    return "2 "+ "Stops".tr;
  }

  Widget _chip({
    required BuildContext context,
    required bool selected,
    required String label,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    final cs = Theme.of(context).colorScheme;
    return FilterChip(
      selected: selected,
      showCheckmark: false,
      avatar: icon != null
          ? Icon(
              icon,
              size: 18,
              color: selected ? AppConsts.primaryColor : cs.onSurfaceVariant,
            )
          : null,
      label: Text(label),
      selectedColor: AppConsts.secondaryColor.withValues(alpha: 0.38),
      backgroundColor: cs.surfaceContainerHighest.withValues(alpha: 0.55),
      side: BorderSide(
        color: selected ? AppConsts.secondaryColor : cs.outline.withValues(alpha: 0.45),
        width: selected ? 1.8 : 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      labelStyle: TextStyle(
        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
        fontSize: AppConsts.sm,
        color: selected ? AppConsts.primaryColor : cs.onSurface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      onSelected: (_) => onTap(),
    );
  }

  Set<TimeBucket> _availableDepartureBuckets(List<FlightOfferModel> offers) {
    final set = <TimeBucket>{};
    for (final o in offers) {
      for (final leg in o.legs) {
        set.add(FilterOffersController.bucketOf(leg.departureDateTime));
      }
    }
    return set;
  }

  Set<TimeBucket> _availableArrivalBuckets(List<FlightOfferModel> offers) {
    final set = <TimeBucket>{};
    for (final o in offers) {
      for (final leg in o.legs) {
        set.add(FilterOffersController.bucketOf(leg.arrivalDateTime));
      }
    }
    return set;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navOverlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: cs.surface,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    );

    return GetBuilder<FilterOffersController>(
      tag: _tag,
      builder: (c) {
        final showInbound = c.hasInboundLeg;

        // ✅ اعرض فقط البكتس المتاحة إن وجدت
        final departureAvailable = _availableDepartureBuckets(widget.offers);
        final arrivalAvailable = _availableArrivalBuckets(widget.offers);

        // ✅ تأكد UI يعكس sanitize دائماً
        if (_outRefCtrl.text != c.outboundRefQuery) {
          _outRefCtrl.value = _outRefCtrl.value.copyWith(text: c.outboundRefQuery);
        }
        if (_inRefCtrl.text != c.inboundRefQuery) {
          _inRefCtrl.value = _inRefCtrl.value.copyWith(text: c.inboundRefQuery);
        }

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: navOverlay,
          child: SafeArea(
            top: false,
            child: Scaffold(
            backgroundColor: cs.surface,
            appBar: AppBar(
              title: Text(
                "Sort & Filter".tr,
                style: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.2),
              ),
              backgroundColor: AppConsts.primaryColor,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              shape: Border(
                bottom: BorderSide(color: AppConsts.secondaryColor.withValues(alpha: 0.35), width: 1),
              ),
            ),
            body: Theme(
              data: Theme.of(context).copyWith(
                radioTheme: RadioThemeData(
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppConsts.secondaryColor;
                    }
                    return cs.onSurfaceVariant;
                  }),
                ),
                checkboxTheme: CheckboxThemeData(
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppConsts.secondaryColor;
                    }
                    return cs.surfaceContainerHighest;
                  }),
                  checkColor: WidgetStateProperty.all(AppConsts.primaryColor),
                  side: BorderSide(color: cs.outline.withValues(alpha: 0.6)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
                sliderTheme: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppConsts.secondaryColor,
                  inactiveTrackColor: cs.outline.withValues(alpha: 0.35),
                  thumbColor: AppConsts.secondaryColor,
                  overlayColor: AppConsts.secondaryColor.withValues(alpha: 0.18),
                  trackHeight: 3.5,
                  rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
                ),
              ),
              child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              children: [
                // =========================
                // ✅ Flight reference (refSegs)
                // =========================
                _sectionTitle(context, "Flight reference"),
                _filterCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _outRefCtrl,
                          inputFormatters: [
                            _refAllowed,
                            _noSpaces,
                            LengthLimitingTextInputFormatter(40),
                          ],
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: showInbound ? TextInputAction.next : TextInputAction.done,
                          style: TextStyle(color: cs.onSurface),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: cs.surface.withValues(alpha: 0.5),
                            labelText: "Flight No Outbound".tr,
                            hintText: "Example: 70,KL- or KL-6070".tr,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.45)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppConsts.secondaryColor, width: 1.6),
                            ),
                          ),
                          onChanged: c.setOutboundRefQuery,
                        ),
                        if (showInbound) ...[
                          const SizedBox(height: 14),
                          TextField(
                            controller: _inRefCtrl,
                            inputFormatters: [
                              _refAllowed,
                              _noSpaces,
                              LengthLimitingTextInputFormatter(40),
                            ],
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.done,
                            style: TextStyle(color: cs.onSurface),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: cs.surface.withValues(alpha: 0.5),
                              labelText: "Flight No Return".tr,
                              hintText: "Example: SV-555 or 55".tr,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.45)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: AppConsts.secondaryColor, width: 1.6),
                              ),
                            ),
                            onChanged: c.setInboundRefQuery,
                          ),
                        ],
                        const SizedBox(height: 10),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            "Search is applied on leg.refSegs (contains)".tr,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  height: 1.35,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          
                // =========================
                // Sort
                // =========================
                _sectionTitle(context, "Sort"),
                _filterCard(
                  child: Column(
                    children: [
                      RadioListTile<SortOffersOption?>(
                        value: null,
                        groupValue: c.selectedSort,
                        title: Text("No sorting".tr, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600)),
                        onChanged: (_) => c.setSort(null),
                      ),
                      Divider(height: 1, color: cs.outline.withValues(alpha: 0.25)),
                      ...SortOffersOption.values.map((opt) {
                        return RadioListTile<SortOffersOption?>(
                          value: opt,
                          groupValue: c.selectedSort,
                          title: Text(
                            FilterOffersController.sortLabel(opt).tr,
                            style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w500),
                          ),
                          onChanged: (v) => c.setSort(v),
                        );
                      }),
                    ],
                  ),
                ),
          
                // =========================
                // Stops
                // =========================
                _sectionTitle(context, "Stops"),
                _filterCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: c.availableStops.map((s) {
                        final selected = c.selectedStops.contains(s);
                        return _chip(
                          context: context,
                          selected: selected,
                          label: _stopLabel(s),
                          icon: Icons.route,
                          onTap: () => c.toggleStop(s),
                        );
                      }).toList(),
                    ),
                  ),
                ),
          
                // =========================
                // ✅ Airlines (بنفس تصميم checkbox + شعار)
                // =========================
                _sectionTitle(context, "Airlines"),
                _filterCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: (c.availableAirlineCodes.isEmpty)
                        ? Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              "No airlines found".tr,
                              style: TextStyle(color: cs.onSurfaceVariant),
                            ),
                          )
                        : Column(
                            children: [
                              for (final code in c.availableAirlineCodes) ...[
                                _AirlineCheckboxRow(
                                  code: code,
                                  value: c.selectedAirlineCodes.contains(code),
                                  onChanged: (_) => c.toggleAirline(code),
                                ),
                                Divider(height: 1, color: cs.outline.withValues(alpha: 0.22)),
                              ],
                            ],
                          ),
                  ),
                ),
          
                // =========================
                // ✅ Departure time (بنفس تصميم tiles grid)
                // =========================
                _sectionTitle(context, "Departure time"),
                _filterCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _TimeBucketTilesGrid(
                      buckets: departureAvailable.isEmpty ? TimeBucket.values : departureAvailable,
                      isSelected: (b) => c.selectedDepartureBuckets.contains(b),
                      onTap: (b) => c.toggleDepartureBucket(b),
                    ),
                  ),
                ),
          
                // =========================
                // ✅ Arrival time (بنفس تصميم tiles grid)
                // =========================
                _sectionTitle(context, "Arrival time"),
                _filterCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _TimeBucketTilesGrid(
                      buckets: arrivalAvailable.isEmpty ? TimeBucket.values : arrivalAvailable,
                      isSelected: (b) => c.selectedArrivalBuckets.contains(b),
                      onTap: (b) => c.toggleArrivalBucket(b),
                    ),
                  ),
                ),
          
                // =========================
                // Price range
                // =========================
                _sectionTitle(context, "Price range"),
                _filterCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "${"From".tr}: ${c.selectedPriceFrom.toStringAsFixed(0)}   •   ${"To".tr}: ${c.selectedPriceTo.toStringAsFixed(0)}",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        RangeSlider(
                          values: RangeValues(c.selectedPriceFrom, c.selectedPriceTo),
                          min: c.minPrice,
                          max: c.sliderPriceMax,
                          onChanged: (v) => c.updatePriceRange(v.start, v.end),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${"Min".tr}: ${c.minPrice.toStringAsFixed(0)}   •   ${"Max".tr}: ${c.maxPrice.toStringAsFixed(0)}",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
          
                // =========================
                // Travel time range
                // =========================
                _sectionTitle(context, "Travel time"),
                _filterCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "${"From".tr}: ${FilterOffersController.minutesToText(c.selectedTravelFrom)}   •   ${"To".tr}: ${FilterOffersController.minutesToText(c.selectedTravelTo)}",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        RangeSlider(
                          values: RangeValues(
                            c.selectedTravelFrom.toDouble(),
                            c.selectedTravelTo.toDouble(),
                          ),
                          min: c.minTravelMinutes.toDouble(),
                          max: c.sliderTravelMax.toDouble(),
                          onChanged: (v) => c.updateTravelRange(v.start.round(), v.end.round()),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${"Min".tr}: ${FilterOffersController.minutesToText(c.minTravelMinutes)}   •   ${"Max".tr}: ${FilterOffersController.minutesToText(c.maxTravelMinutes)}",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
          
                const SizedBox(height: 16),
              ],
            ),
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  border: Border(
                    top: BorderSide(
                      color: AppConsts.secondaryColor.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, -4),
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${"Active filters".tr}: ${c.buildState().countFiltersActive}",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cs.onSurface,
                        side: BorderSide(
                          color: AppConsts.secondaryColor.withValues(alpha: 0.85),
                          width: 1.4,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: (c.buildState().countFiltersActive > 0) ? () => c.clearAll() : null,
                      child: Text("Clear".tr, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConsts.secondaryColor,
                        foregroundColor: AppConsts.primaryColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => c.done(),
                      icon: const Icon(Icons.check_rounded, size: 20),
                      label: Text("Done".tr, style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        );
      },
    );
  }
}

// =================== Widgets (Airlines) ===================

class _AirlineCheckboxRow extends StatelessWidget {
  final String code;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _AirlineCheckboxRow({
    required this.code,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final a = AirlineRepo.searchByCode(code);
    final title = a != null ? '${a.name[AppVars.lang]} ($code)' : code;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              Checkbox(value: value, onChanged: onChanged),
              const SizedBox(width: 4),
              SizedBox(
                width: 44,
                height: 44,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CacheImg(
                    AppFuns.airlineImgURL(code),
                    boxFit: BoxFit.contain,
                    sizeCircleLoading: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
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

// =================== Widgets (Time buckets grid) ===================

class _TimeBucketTilesGrid extends StatelessWidget {
  final Iterable<TimeBucket> buckets;
  final bool Function(TimeBucket) isSelected;
  final void Function(TimeBucket) onTap;

  const _TimeBucketTilesGrid({
    required this.buckets,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ordered = _orderBuckets(buckets);

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final tileW = (constraints.maxWidth) / 2.3;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.center,
          children: [
            for (final b in ordered)
              SizedBox(
                width: tileW,
                child: _TimeBucketTile(
                  bucket: b,
                  selected: isSelected(b),
                  onTap: () => onTap(b),
                ),
              ),
          ],
        );
      },
    );
  }

  List<TimeBucket> _orderBuckets(Iterable<TimeBucket> buckets) {
    final set = buckets.toSet();
    final order = <TimeBucket>[
      TimeBucket.earlyMorning,
      TimeBucket.morning,
      TimeBucket.afternoon,
      TimeBucket.evening,
    ];
    return order.where(set.contains).toList();
  }
}

class _TimeBucketTile extends StatelessWidget {
  final TimeBucket bucket;
  final bool selected;
  final VoidCallback onTap;

  const _TimeBucketTile({
    required this.bucket,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final borderColor = selected ? AppConsts.secondaryColor : cs.outline.withValues(alpha: 0.45);
    final borderWidth = selected ? 2.2 : 1.0;
    final bg = selected
        ? AppConsts.secondaryColor.withValues(alpha: 0.14)
        : cs.surface.withValues(alpha: 0.4);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: bg,
            border: Border.all(width: borderWidth, color: borderColor),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppConsts.secondaryColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _bucketIcon(bucket),
                size: 32,
                color: selected ? AppConsts.primaryColor : cs.onSurfaceVariant,
              ),
              const SizedBox(height: 10),
              Text(
                _bucketTitle(bucket).tr,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: selected ? AppConsts.primaryColor : cs.onSurface,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                _bucketRange(bucket).tr,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _bucketIcon(TimeBucket b) {
    switch (b) {
      case TimeBucket.earlyMorning:
        return Icons.wb_twilight_outlined;
      case TimeBucket.morning:
        return Icons.wb_sunny_outlined;
      case TimeBucket.afternoon:
        return Icons.wb_sunny;
      case TimeBucket.evening:
        return Icons.nights_stay_outlined;
    }
  }

  String _bucketTitle(TimeBucket b) {
    switch (b) {
      case TimeBucket.earlyMorning:
        return 'Early Morning';
      case TimeBucket.morning:
        return 'Morning';
      case TimeBucket.afternoon:
        return 'Afternoon';
      case TimeBucket.evening:
        return 'Evening';
    }
  }

  String _bucketRange(TimeBucket b) {
    switch (b) {
      case TimeBucket.earlyMorning:
        return '(12:00am - 4:59am)';
      case TimeBucket.morning:
        return '(5:00am - 11:59am)';
      case TimeBucket.afternoon:
        return '(12:00pm - 5:59pm)';
      case TimeBucket.evening:
        return '(6:00pm - 11:59pm)';
    }
  }
}
