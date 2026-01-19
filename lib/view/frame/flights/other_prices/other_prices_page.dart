// other_prices_page.dart
import 'package:alzajeltravel/controller/airline_controller.dart';
import 'package:alzajeltravel/model/flight/flight_offer_model.dart';
import 'package:alzajeltravel/repo/airline_repo.dart';
import 'package:alzajeltravel/repo/airport_repo.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/widgets.dart';
import 'package:alzajeltravel/view/frame/flights/flight_detail/more_flight_detail_page.dart';
import 'package:alzajeltravel/view/frame/flights/flight_offers_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:alzajeltravel/controller/flight/other_prices_controller.dart';
import 'package:alzajeltravel/model/flight/other_prices_model.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';

class OtherPricesPage extends StatefulWidget {
  const OtherPricesPage({super.key,});

  @override
  State<OtherPricesPage> createState() => _OtherPricesPageState();
}

class _OtherPricesPageState extends State<OtherPricesPage> {
  int selectedIndex = 0;

  String _formatDate(DateTime dt) {
    final localeTag = Get.locale?.toLanguageTag() ?? Intl.getCurrentLocale();
    return DateFormat('EEE, MMM d', localeTag).format(dt); // Wed, Dec 31
  }

  String _formatTime(BuildContext context, DateTime dt) {
    final always24 = MediaQuery.of(context).alwaysUse24HourFormat;
    return MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(dt), alwaysUse24HourFormat: always24);
  }

  String _stopsLabel(int stops) {
    if (stops <= 0) return 'Nonstop'.tr;
    if (stops == 1) return '1 stop'.tr;
    if (stops == 2) return '2 stops'.tr;
    return '${stops.toString()} ${'stops'.tr}';
  }

  double carouselHeight() { 
    final double height = 300;
    final offers = Get.find<OtherPricesController>().offers;
    if (offers.isEmpty) return 0;
    int maxLengthMeals = 0;
    for (var offer in offers) {
      final int lengthMeals = offer.familyFeatures?.meals.length ?? 0;
      if (lengthMeals > maxLengthMeals) {
        maxLengthMeals = lengthMeals;
      }
    }
    return height + (maxLengthMeals * 26);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: GetBuilder<OtherPricesController>(
          builder: (ctrl) {
            final FlightOfferModel? flight = ctrl.currentOffer;

            if (flight == null) {
              return _StateMessage(title: 'No flight data'.tr, subtitle: 'Please go back and try again'.tr, onClose: () => Get.back());
            }

            if (ctrl.errorMessage != null && (ctrl.offers.isEmpty)) {
              return _StateMessage(title: ctrl.errorMessage!, subtitle: 'Please try again'.tr, onClose: () => Get.back());
            }

            final offers = ctrl.offers;

            final firstSeg = flight.segments.isNotEmpty ? flight.segments.first : null;
            final airlineCode = firstSeg?.marketingAirlineCode ?? flight.airlineCode;

            String airlineName = "";
            if (AirlineRepo.searchByCode(airlineCode) != null) {
              airlineName = AirlineRepo.searchByCode(airlineCode)!.name[AppVars.lang];
            } else {
              airlineName = flight.airlineName;
            }

            String titleFrom = "";
            if (AirportRepo.searchByCode(flight.fromCode) != null) {
              titleFrom = AirportRepo.searchByCode(flight.fromCode)!.name[AppVars.lang];
            } else {
              titleFrom = flight.fromName;
            }

            String titleTo = "";
            if (AirportRepo.searchByCode(flight.toCode) != null) {
              titleTo = AirportRepo.searchByCode(flight.toCode)!.name[AppVars.lang];
            } else {
              titleTo = flight.toName;
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header (X + title)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: Row(
                      children: [
                        IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.arrow_back)),
                        const SizedBox(width: 0),
                        Expanded(
                          child: Text('Other prices'.tr, style: theme.textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
              
                  // Flight info (Date + time + route + airline row)
                  ExpansionTile(
                    title: Text('Flight'.tr),
                    collapsedBackgroundColor: theme.colorScheme.surfaceContainer,
                    childrenPadding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 8,
                    ),
                    children: [
                      FlightOfferCard(
                        offer: flight,
                        onDetails: () {
                          Get.to(() => MoreFlightDetailPage(
                            flightOffer: flight,
                            fareRules: [],
                          ));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
              
                  // Cards
                  Container(
                    child: offers.isEmpty
                        ? Center(child: Text('No other prices found'.tr, style: theme.textTheme.bodyMedium))
                        : CarouselSlider.builder(
                            itemCount: offers.length,
                            itemBuilder: (context, index, realIndex) {
                              final option = offers[index];
                              final isSelected = selectedIndex == index;
                              
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: _OtherPriceCard(
                                  option: option,
                                  isSelected: isSelected,
                                  onSelect: () async {
                                    context.loaderOverlay.show();
                                    await ctrl.selectAndOpen(option);
                                    if(context.mounted) context.loaderOverlay.hide();
                                  },
                                ),
                              );
                            },
                            options: CarouselOptions(
                              viewportFraction: 0.84,
                              enlargeCenterPage: true,
                              enableInfiniteScroll: false,
                              enlargeFactor: 0.18,
                              height: carouselHeight(),
                              onPageChanged: (index, reason) {
                                setState(() => selectedIndex = index);
                                ctrl.select(offers[index]);
                              },
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OtherPriceCard extends StatefulWidget {
  const _OtherPriceCard({required this.option, required this.isSelected, required this.onSelect});

  final OtherPriceOffer option;
  final bool isSelected;
  final VoidCallback onSelect;

  @override
  State<_OtherPriceCard> createState() => _OtherPriceCardState();
}

class _OtherPriceCardState extends State<_OtherPriceCard> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final title = (widget.option.familyFeatures?.label?.trim().isNotEmpty ?? false)
        ? widget.option.familyFeatures!.label!.trim()
        : (widget.option.familyName?.trim().isNotEmpty ?? false)
        ? widget.option.familyName!.trim()
        : 'Fare'.tr;

    final currency = (widget.option.currency ?? '').trim().isEmpty ? 'USD' : widget.option.currency!.trim();
    final total = widget.option.total ?? 0;

    final bookingClass = widget.option.bookingClass;
    final cabinName = AppFuns.cabinNameFromBookingClass(bookingClass);

    // ✅ meals = flexibility
    final meals = widget.option.familyFeatures?.meals ?? const <String>[];

    return Card(
      elevation: widget.isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: widget.isSelected ? cs.primary : cs.outline, width: widget.isSelected ? 2 : 1),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppFuns.priceWithCoin(total, currency), style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),

            // ✅ removed: "for 1 traveler"
            // Text(AppFuns.priceWithCoin(total, currency), style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),

            Text(title.tr, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),

            // ✅ cabin from bookingClass mapping
            Text('${'Cabin:'.tr} ${cabinName}', style: theme.textTheme.bodyMedium),

            const SizedBox(height: 16),

            // ✅ Seat/Bags removed, merged into Flexibility (meals)
            Text('Flexibility'.tr, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            if (meals.isEmpty)
              Text('No details available'.tr, style: theme.textTheme.bodyMedium)
            else
              Expanded(
                child: CupertinoScrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        ...meals.map(
                          (m) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle, size: 18),
                                const SizedBox(width: 8),
                                Expanded(child: Text(m.tr, style: theme.textTheme.bodyMedium)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: widget.isSelected ? widget.onSelect : null, child: Text('Select'.tr)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.title, required this.subtitle, required this.onClose});

  final String title;
  final String subtitle;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(subtitle, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onClose, child: Text('Close'.tr)),
            ],
          ),
        ),
      ),
    );
  }
}
