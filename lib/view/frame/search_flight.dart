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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color cardBg = isDark ? const Color(0xFF121A38) : Colors.white;
    final Color tabBarBg = isDark
        ? const Color(0xFF0E1530)
        : AppConsts.primaryColor.withValues(alpha: 0.12);

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
    
            // ───── Tab bar ─────
            Container(
              decoration: BoxDecoration(
                color: tabBarBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppConsts.secondaryColor.withValues(
                    alpha: isDark ? 0.35 : 0.28,
                  ),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppConsts.primaryColor.withValues(
                      alpha: isDark ? 0.35 : 0.08,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                height: 48,
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerHeight: 0,
                  dividerColor: Colors.transparent,
                  padding: const EdgeInsets.all(4),
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppConsts.primaryColor,
                        Color(0xFF1B2F6F),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppConsts.primaryColor.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: AppConsts.secondaryColor,
                  unselectedLabelColor:
                      isDark ? Colors.white70 : AppConsts.primaryColor,
                  unselectedLabelStyle: TextStyle(
                    fontSize: AppConsts.normal,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppConsts.font,
                  ),
                  labelStyle: TextStyle(
                    fontSize: AppConsts.normal,
                    fontWeight: FontWeight.w800,
                    fontFamily: AppConsts.font,
                    letterSpacing: 0.3,
                  ),
                  tabs: [
                    Tab(text: "One Way".tr),
                    Tab(text: "Round Trip".tr),
                    Tab(text: "Multi City".tr),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ───── Form card ─────
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                  border: Border.all(
                    color: AppConsts.secondaryColor.withValues(
                      alpha: isDark ? 0.35 : 0.22,
                    ),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppConsts.primaryColor.withValues(
                        alpha: isDark ? 0.30 : 0.08,
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
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
    
                    icon: ctrl.isRequesting
                        ? null
                        : const Icon(
                            Icons.search_rounded,
                            color: AppConsts.secondaryColor,
                            size: 18,
                          ),
                    label: ctrl.isRequesting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppConsts.secondaryColor),
                            ),
                          )
                        : Text(
                            "Search Flight".tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
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
