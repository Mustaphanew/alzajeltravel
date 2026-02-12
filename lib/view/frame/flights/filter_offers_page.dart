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
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 14, bottom: 8),
      child: Text(
        title.tr,
        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  String _stopLabel(int s) {
    if (s == 0) return "Direct".tr;
    if (s == 1) return "1 Stop".tr;
    return "2 "+ "Stops".tr;
  }

  Widget _chip({
    required bool selected,
    required String label,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return ChoiceChip(
      selected: selected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16),
            const SizedBox(width: 6),
          ],
          Text(label),
        ],
      ),
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

        return SafeArea(
          top: false,
          child: Scaffold(
            appBar: AppBar(
              title: Text("Sort & Filter".tr),

            ),
            body: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // =========================
                // ✅ Flight reference (refSegs)
                // =========================
                _sectionTitle(context, "Flight reference"),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
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
                          decoration: InputDecoration(
                            labelText: "Flight No Outbound".tr,
                            hintText: "Example: 70,KL- or KL-6070".tr,
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: c.setOutboundRefQuery,
                        ),
                        if (showInbound) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _inRefCtrl,
                            inputFormatters: [
                              _refAllowed,
                              _noSpaces,
                              LengthLimitingTextInputFormatter(40),
                            ],
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: "Flight No Return".tr,
                              hintText: "Example: SV-555 or 55".tr,
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: c.setInboundRefQuery,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            "Search is applied on leg.refSegs (contains)".tr,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
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
                Card(
                  child: Column(
                    children: [
                      RadioListTile<SortOffersOption?>(
                        value: null,
                        groupValue: c.selectedSort,
                        title: Text("No sorting".tr),
                        onChanged: (_) => c.setSort(null),
                      ),
                      const Divider(height: 1),
                      ...SortOffersOption.values.map((opt) {
                        return RadioListTile<SortOffersOption?>(
                          value: opt,
                          groupValue: c.selectedSort,
                          title: Text(FilterOffersController.sortLabel(opt).tr),
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: c.availableStops.map((s) {
                        final selected = c.selectedStops.contains(s);
                        return _chip(
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: (c.availableAirlineCodes.isEmpty)
                        ? Text("No airlines found".tr)
                        : Column(
                            children: [
                              for (final code in c.availableAirlineCodes) ...[
                                _AirlineCheckboxRow(
                                  code: code,
                                  value: c.selectedAirlineCodes.contains(code),
                                  onChanged: (_) => c.toggleAirline(code),
                                ),
                                const Divider(height: 1),
                              ],
                            ],
                          ),
                  ),
                ),
          
                // =========================
                // ✅ Departure time (بنفس تصميم tiles grid)
                // =========================
                _sectionTitle(context, "Departure time"),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
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
            bottomNavigationBar: Container(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(
                  top: BorderSide(
                    color: cs.outline,
                    width: 1,
                  ),
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Text(
                    "${"Active filters".tr}: ${c.buildState().countFiltersActive}",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: AppConsts.lg),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onPressed: () => c.done(),
                    icon: const Icon(Icons.check),
                    label: Text("Done".tr),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onPressed: (c.buildState().countFiltersActive > 0) ? () => c.clearAll() : null,
                    child: Text("Clear".tr),
                  ),
                  const SizedBox(width: 8),
                  const SizedBox(width: 12),
                ],
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

    final a = AirlineRepo.searchByCode(code);
    final title = a != null ? '${a.name[AppVars.lang]} ($code)' : code;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          children: [
            Checkbox(value: value, onChanged: onChanged),
            const SizedBox(width: 6),
            SizedBox(
              width: 30,
              height: 30,
              child: CacheImg(AppFuns.airlineImgURL(code), sizeCircleLoading: 10),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
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

    final borderColor = selected ? theme.colorScheme.primary : theme.dividerColor;
    final borderWidth = selected ? 2.0 : 1.0;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(width: borderWidth, color: borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_bucketIcon(bucket), size: 34),
            const SizedBox(height: 10),
            Text(
              _bucketTitle(bucket).tr,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              _bucketRange(bucket).tr,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
