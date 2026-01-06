// lib/view/frame/flights/filter_offers_page.dart
import 'package:alzajeltravel/repo/airline_repo.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:alzajeltravel/model/flight/flight_offer_model.dart';
import 'package:alzajeltravel/controller/flight/filter_offers_controller.dart';

class FilterOffersPage extends StatelessWidget {
  final List<FlightOfferModel> offers;
  final FilterOffersState state;

  const FilterOffersPage({super.key, required this.offers, required this.state});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FilterOffersController>(
      init: FilterOffersController(originalOffers: offers, initialState: state),
      global: false,
      builder: (c) {
        final theme = Theme.of(context);

        final departureAvailable = _availableDepartureBuckets(offers);
        final arrivalAvailable = _availableArrivalBuckets(offers);

        return SafeArea(
          bottom: true,
          left: false,
          right: false,
          top: false,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Filter'.tr),
              actions: [
                TextButton(onPressed: c.hasAnyFilter ? c.clearAll : null, child: Text('Clear'.tr)),
                TextButton(onPressed: c.done, child: Text('Done'.tr)),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // 0) ===== Sort =====
                _SectionTitle(title: 'Sort'.tr),
                const SizedBox(height: 8),
                DropdownButtonFormField<SortOffersOption?>(
                  value: c.selectedSort,
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
                  onChanged: (v) => c.setSort(v),
                ),

                const SizedBox(height: 22),

                // 1) ===== Stops =====
                _SectionTitle(title: 'Stops'.tr),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: Text('Non-stop'.tr),
                      selected: c.selectedStops.contains(0),
                      onSelected: (_) => c.toggleStop(0),
                    ),
                    FilterChip(
                      label: Text('1 Stop'.tr),
                      selected: c.selectedStops.contains(1),
                      onSelected: (_) => c.toggleStop(1),
                    ),
                    FilterChip(
                      label: Text('2 Stops'.tr),
                      selected: c.selectedStops.contains(2),
                      onSelected: (_) => c.toggleStop(2),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // 2) ===== Price range =====
                _SectionTitle(title: '${'Price range'.tr} ${'USD'.tr}'),
                const SizedBox(height: 8),
                _RangeHeader(
                  left: c.selectedPriceFrom.toStringAsFixed(2),
                  right: c.selectedPriceTo.toStringAsFixed(2),
                ),
                RangeSlider(
                  min: c.minPrice,
                  max: c.sliderPriceMax,
                  values: RangeValues(c.selectedPriceFrom, c.selectedPriceTo),
                  onChanged: (v) => c.updatePriceRange(v.start, v.end),
                ),
                _RangeFooter(
                  left: c.minPrice.toStringAsFixed(2),
                  right: c.maxPrice.toStringAsFixed(2),
                ),

                const SizedBox(height: 22),

                // 3) ===== Travel time =====
                _SectionTitle(title: 'Travel time'.tr),
                const SizedBox(height: 8),
                _RangeHeader(
                  left: FilterOffersController.minutesToText(c.selectedTravelFrom),
                  right: FilterOffersController.minutesToText(c.selectedTravelTo),
                ),
                RangeSlider(
                  min: c.minTravelMinutes.toDouble(),
                  max: c.sliderTravelMax.toDouble(),
                  values: RangeValues(c.selectedTravelFrom.toDouble(), c.selectedTravelTo.toDouble()),
                  onChanged: (v) => c.updateTravelRange(v.start.round(), v.end.round()),
                ),
                _RangeFooter(
                  left: FilterOffersController.minutesToText(c.minTravelMinutes),
                  right: FilterOffersController.minutesToText(c.maxTravelMinutes),
                ),

                const SizedBox(height: 22),

                // 4) ===== Departure time =====
                _SectionTitle(title: 'Departure time'.tr),
                const SizedBox(height: 10),
                _TimeBucketTilesGrid(
                  buckets: departureAvailable.isEmpty ? TimeBucket.values.toList() : departureAvailable,
                  isSelected: (b) => c.selectedDepartureBuckets.contains(b),
                  onTap: (b) => c.toggleDepartureBucket(b),
                ),

                const SizedBox(height: 22),

                // 5) ===== Arrival time =====
                _SectionTitle(title: 'Arrival time'.tr),
                const SizedBox(height: 10),
                _TimeBucketTilesGrid(
                  buckets: arrivalAvailable.isEmpty ? TimeBucket.values.toList() : arrivalAvailable,
                  isSelected: (b) => c.selectedArrivalBuckets.contains(b),
                  onTap: (b) => c.toggleArrivalBucket(b),
                ),

                const SizedBox(height: 22),

                // 6) ===== Airlines =====
                _SectionTitle(title: 'Airlines'.tr),
                const SizedBox(height: 8),
                if (c.availableAirlineCodes.isEmpty)
                  Text('No airlines found'.tr, style: theme.textTheme.bodyMedium)
                else
                  Column(
                    children: [
                      for (final code in c.availableAirlineCodes) ...[
                        _AirlineCheckboxRow(
                          code: code,
                          value: c.selectedAirlineCodes.contains(code),
                          onChanged: (_) => c.toggleAirline(code),
                        ),
                        const Divider(),
                      ],
                    ],
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
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
}

// =================== Widgets ===================

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800));
  }
}

class _AirlineCheckboxRow extends StatelessWidget {
  final String code;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _AirlineCheckboxRow({required this.code, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          children: [
            Checkbox(value: value, onChanged: onChanged),
            const SizedBox(width: 6),
            SizedBox(width: 30, height: 30, child: CacheImg(AppFuns.airlineImgURL(code))),
            const SizedBox(width: 12),
            if (AirlineRepo.searchByCode(code) != null)
              Expanded(
                child: Text(
                  AirlineRepo.searchByCode(code)!.name[AppVars.lang] + ' (${code})',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            if (AirlineRepo.searchByCode(code) == null)
              Expanded(
                child: Text(code, style: theme.textTheme.titleMedium),
              ),
          ],
        ),
      ),
    );
  }
}

class _TimeBucketTilesGrid extends StatelessWidget {
  final Iterable<TimeBucket> buckets;
  final bool Function(TimeBucket) isSelected;
  final void Function(TimeBucket) onTap;

  const _TimeBucketTilesGrid({required this.buckets, required this.isSelected, required this.onTap});

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
                child: _TimeBucketTile(bucket: b, selected: isSelected(b), onTap: () => onTap(b)),
              ),
          ],
        );
      },
    );
  }

  List<TimeBucket> _orderBuckets(Iterable<TimeBucket> buckets) {
    final set = buckets.toSet();
    final order = <TimeBucket>[TimeBucket.earlyMorning, TimeBucket.morning, TimeBucket.afternoon, TimeBucket.evening];
    return order.where(set.contains).toList();
  }
}

class _TimeBucketTile extends StatelessWidget {
  final TimeBucket bucket;
  final bool selected;
  final VoidCallback onTap;

  const _TimeBucketTile({required this.bucket, required this.selected, required this.onTap});

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

class _RangeHeader extends StatelessWidget {
  final String left;
  final String right;

  const _RangeHeader({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        Text(right, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _RangeFooter extends StatelessWidget {
  final String left;
  final String right;

  const _RangeFooter({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left, style: theme.textTheme.bodySmall),
        Text(right, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
