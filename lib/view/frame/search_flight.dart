import 'package:alzajeltravel/controller/class_type_controller.dart';
import 'package:alzajeltravel/utils/widgets/custom_button.dart';
import 'package:alzajeltravel/view/frame/flights/flight_offers_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:alzajeltravel/controller/airline_controller.dart';
import 'package:alzajeltravel/controller/search_flight_controller.dart';
import 'package:alzajeltravel/controller/travelers_controller.dart';
import 'package:alzajeltravel/utils/enums.dart';
import 'package:alzajeltravel/view/frame/search_flight_widgets/flight_tab.dart';
import '../../utils/app_consts.dart';

class SearchFlight extends StatefulWidget {
  /// ✅ لو فتحتها من النتائج (Edit Search) خلّها true
  final bool isEditor;

  /// ✅ لو تريد فتحها على نفس تبويب آخر بحث
  final int? initialTabIndex;

  final ValueChanged<FlightSearchResult>? onResult;

  const SearchFlight({
    super.key,
    this.isEditor = false,
    this.initialTabIndex,
    this.onResult,
  });

  @override
  State<SearchFlight> createState() => _SearchFlightState();
}

class _SearchFlightState extends State<SearchFlight> with SingleTickerProviderStateMixin {
  late final SearchFlightController searchFlightController;
  late final TravelersController travelersController;
  late ClassTypeController classTypeController;
  late final AirlineController airlineController;

  late final TabController _tabController;

  // ✅ FormKeys محلية (حل Duplicate GlobalKey)
  final _oneWayKey = GlobalKey<FormState>();
  final _roundTripKey = GlobalKey<FormState>();
  final _multiCityKey = GlobalKey<FormState>();

  int _journeyToTab(JourneyType t) {
    if (t == JourneyType.oneWay) return 0;
    if (t == JourneyType.roundTrip) return 1;
    return 2;
  }

  GlobalKey<FormState> _keyFor(JourneyType t) {
    if (t == JourneyType.oneWay) return _oneWayKey;
    if (t == JourneyType.roundTrip) return _roundTripKey;
    return _multiCityKey;
  }

@override
void initState() {
  super.initState();

  // ✅ Controller واحد مشترك
  if (!Get.isRegistered<SearchFlightController>()) {
    Get.put(SearchFlightController(), permanent: true);
  }
  if (!Get.isRegistered<TravelersController>()) {
    Get.put(TravelersController(), permanent: true);
  }
  if (!Get.isRegistered<ClassTypeController>()) {
    Get.put(ClassTypeController(), permanent: true);
  }
  if (!Get.isRegistered<AirlineController>()) {
    Get.put(AirlineController(), permanent: true);
  }

  searchFlightController = Get.find<SearchFlightController>();
  travelersController = Get.find<TravelersController>();
  classTypeController = Get.find<ClassTypeController>();
  airlineController = Get.find<AirlineController>();

  // ✅ حدّد initial قبل ما تعمل أي update
  final initial = widget.initialTabIndex ?? _journeyToTab(searchFlightController.journeyType);

  _tabController = TabController(length: 3, vsync: this, initialIndex: initial);

  // ✅ مهم: أي شيء يعمل update() داخل Controller نفذه بعد أول Frame
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (!mounted) return;

    // sync controller journey type with initial tab
    searchFlightController.changeJourneyType(initial);

    // يحدّث txtClassType/txtTravelers (قد يعمل update())
    await searchFlightController.setTxtTravelersAndClassType();
  });

  _tabController.addListener(() {
    if (!_tabController.indexIsChanging) {
      searchFlightController.changeJourneyType(_tabController.index);
    }
  });
}


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
    
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Material(
                color: AppConsts.primaryColor.withValues(alpha: 0.4),
                child: SizedBox(
                  height: 50,
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerHeight: 0,
                    dividerColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    indicator: BoxDecoration(color: AppConsts.primaryColor),
                    labelColor: cs.secondary,
                    unselectedLabelColor: cs.onPrimary,
                    unselectedLabelStyle: TextStyle(
                      fontSize: AppConsts.normal,
                      fontWeight: FontWeight.normal,
                      fontFamily: AppConsts.font,
                    ),
                    labelStyle: TextStyle(
                      fontSize: AppConsts.normal,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppConsts.font,
                    ),
                    tabs: [
                      Tab(text: "One Way".tr),
                      Tab(text: "Round Trip".tr),
                      Tab(text: "Multi City".tr),
                    ],
                  ),
                ),
              ),
            ),
    
            const SizedBox(height: 16),
    
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: FlightTab(
                        tmpJourneyType: JourneyType.oneWay,
                        formKey: _oneWayKey,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: FlightTab(
                        tmpJourneyType: JourneyType.roundTrip,
                        formKey: _roundTripKey,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Center(child: Text("Not currently available".tr)),
                      // لو فعلتها لاحقًا:
                      // child: FlightTab(tmpJourneyType: JourneyType.multiCity, formKey: _multiCityKey),
                    ),
                  ],
                ),
              ),
            ),
    
            const SizedBox(height: 16),
    
            SizedBox(
              width: AppConsts.sizeContext(context).width * 0.9,
              height: 50,
              child: GetBuilder<SearchFlightController>(
                builder: (ctrl) {
    
    
                  return CustomButton(
                    onPressed: (ctrl.isRequesting) ? null : () async {
                      final formKey = _keyFor(ctrl.journeyType);
                      formKey.currentState?.validate();
                      if (!formKey.currentState!.validate()) return;
                      // validate form كما عندك...
                      final FlightSearchResult? result = await ctrl.requestServer(context);
                      if (result == null) return;
    
                      if (widget.isEditor) {
                        Get.off(
                          () => FlightOffersList(flightOffers: result.outbound, searchInputs: result.params), 
                          preventDuplicates: false,
                        ); 
                      } else {
                        // ✅ بحث عادي: افتح صفحة النتائج
                        Get.to(() => FlightOffersList(flightOffers: result.outbound, searchInputs: result.params));
                      }
                    },
    
                    label: ctrl.isRequesting
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator())
                        : Text("Search Flight".tr),
                  );
    
    
                },
              ),
            ),
    
            const SizedBox(height: 16),
          ],
        ),
      );
  }
}
