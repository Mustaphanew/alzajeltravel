import 'package:alzajeltravel/utils/widgets/custom_button.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:alzajeltravel/controller/airline_controller.dart';
import 'package:alzajeltravel/controller/search_flight_controller.dart';
import 'package:alzajeltravel/controller/travelers_controller.dart';
import 'package:alzajeltravel/utils/enums.dart';
import 'package:alzajeltravel/view/frame/search_flight_widgets/flight_tab.dart';
import 'package:alzajeltravel/view/frame/flights/flight_offers_list.dart';
import '../../utils/app_consts.dart';

class SearchFlight extends StatefulWidget {
  final BuildContext frameContext;
  const SearchFlight({super.key, required this.frameContext});

  @override
  State<SearchFlight> createState() => _SearchFlightState();
}

class _SearchFlightState extends State<SearchFlight> with SingleTickerProviderStateMixin {
  SearchFlightController searchFlightController = Get.put(SearchFlightController());
  TravelersController travelersController = Get.put(TravelersController());
  AirlineController airlineController = Get.put(AirlineController());

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    // classTypeAndTravelersController.setDefaultClassType();
    searchFlightController.setTxtTravelersAndClassType();

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _onTabChanged(_tabController.index);
      }
    });
  }

  void _onTabChanged(int index) {
    // نفّذ المطلوب
    print("index: $index");
    searchFlightController.changeJourneyType(index);
    print("journeyType: ${searchFlightController.journeyType}");
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: AppConsts.tertiaryColor[200],
        elevation: 0,
        title: Text("Search Flight".tr),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SizedBox(height: 20),
        
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Material(
                  color: AppConsts.primaryColor.withValues(alpha: 0.4),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    margin: EdgeInsets.all(0),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      // indicatorWeight: 60,
                      dividerHeight: 0,
                      dividerColor: Colors.transparent,
                      padding: EdgeInsets.all(0),
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
                        TabItem(title: "One Way".tr),
                        TabItem(title: "Round Trip".tr),
                        TabItem(title: "Multi City".tr),
                      ],
                      // onTap: (value) {
                      //   print("value TabBar: $value");
                      // },
                      // onFocusChange: (value, focus) {
                      //   print("value onFocusChange: $value, $focus");
                      // },
                      // onHover: (value, hover) {
                      //   print("value onHover: $value, $hover");
                      // },
                    ),
                  ),
                ),
              ),
            ),
        
            SizedBox(height: 16),
        
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                ),
                child: TabBarView(
                  controller: _tabController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FlightTab(frameContext: widget.frameContext, tmpJourneyType: JourneyType.oneWay),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FlightTab(frameContext: widget.frameContext, tmpJourneyType: JourneyType.roundTrip),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 16),
                    //   child: FlightTab(frameContext: widget.frameContext, tmpJourneyType: JourneyType.multiCity),
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Center(child: Text("Not currently available".tr)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: AppConsts.sizeContext(context).width * 0.9,
              height: 50,
              child: GetBuilder<SearchFlightController>(
                builder: (ctrl) {
                  return CustomButton(
                    onPressed: (ctrl.isRequesting)? null : () async {
                      
                      GlobalKey<FormState>? currentKey;
                      bool isValid = false;
                      if (ctrl.journeyType == JourneyType.roundTrip) {
                        currentKey = ctrl.roundTripFormKey;
                      } else if (ctrl.journeyType == JourneyType.oneWay) {
                        currentKey = ctrl.oneWayFormKey;
                      } else if (ctrl.journeyType == JourneyType.multiCity) {
                        currentKey = ctrl.multiCityFormKey;
                      }
                      try {
                        isValid = currentKey?.currentState?.validate() ?? false;
                      } catch (e) {
                        print("error form is not valid: ${e}");
                      }
                      if (!isValid) {
                        print("form is not valid: ${ctrl.journeyType}");
                        return;
                      }
                          
                      if (ctrl.journeyType == JourneyType.roundTrip) {
                        // send data to server
                      } else if (ctrl.journeyType == JourneyType.oneWay) {
                        // send data to server
                      } else if (ctrl.journeyType == JourneyType.multiCity) {
                        // send data to server
                      }
                  
                      ctrl.requestServer(context);
                          
                      // print("searchFlightController.forms: ${searchFlightController.journeyType.toJson()}");
                      // for (var e in searchFlightController.forms) {
                      //   print("Departure Date: ${e.txtDepartureDate.text}");
                      // }
                          
                      // final DateTime? departureDate = searchFlightController.forms[0].departureDatePickerController.selectedDate;
                          
                      // String formattedLeavingDate = DateFormat('yyyy-MM-dd', 'en').format(departureDate!);
                          
                      // print("departureDate: ${formattedLeavingDate}");
                          
                      // final response = await Dio().post(
                      //   "${AppConsts.baseUrl}/appm/amadeus_api.php",
                      //   data: {
                      //     "action": "search",
                      //     "currency": "USD",
                      //     "max": 10,
                      //     "mode": "${searchFlightController.journeyType.toJson()}",
                      //     "adults": travelersController.adultsCounter,
                      //     "children": travelersController.childrenCounter,
                      //     "infants": travelersController.infantsInLapCounter,
                      //     "origin": "${searchFlightController.forms[0].fromLocation!.code}",
                      //     "destination": "${searchFlightController.forms[0].toLocation!.code}",
                      //     "departureDate": "${formattedLeavingDate}", // format date to YYYY-MM-DD
                      //   },
                      // );
                          
                      // print("response: ${response.data}");
                          
                      // Get.to(() => FlightsResults());
                      
                    },
                    label: (ctrl.isRequesting)? SizedBox(height: 24, width: 24, child: CircularProgressIndicator()) : Text("Search Flight".tr),
                  );
                }
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class TabItem extends StatelessWidget {
  final String title;
  const TabItem({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Tab(child: Container(child: Text(title)));
  }
}
