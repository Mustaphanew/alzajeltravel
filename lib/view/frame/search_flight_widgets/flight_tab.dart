import 'package:alzajeltravel/view/frame/search_flight_widgets/airline.dart';
import 'package:alzajeltravel/view/frame/search_flight_widgets/date_picker/date_picker_range_widget2.dart';
import 'package:alzajeltravel/view/frame/search_flight_widgets/date_picker/date_picker_single_widget2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/controller/search_flight_controller.dart';
import 'package:alzajeltravel/model/airport_model.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/enums.dart';
import 'package:alzajeltravel/view/frame/search_flight_widgets/class_type_and_travelers.dart';
import 'package:alzajeltravel/view/frame/search_flight_widgets/airport_search.dart';
import 'package:alzajeltravel/view/frame/search_flight_widgets/swap_widget.dart';

class FlightTab extends StatefulWidget {
  final JourneyType tmpJourneyType;
  final GlobalKey<FormState> formKey;
  const FlightTab({super.key, required this.tmpJourneyType, required this.formKey});

  @override
  State<FlightTab> createState() => _FlightTabState();
}

class _FlightTabState extends State<FlightTab> with AutomaticKeepAliveClientMixin {
  late SearchFlightController searchFlightController;
  late ScrollController scrollController;

  // مهم: احفظ الحالة بين التبويبات
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    searchFlightController = Get.find<SearchFlightController>();
    if (widget.tmpJourneyType == JourneyType.roundTrip) {
      scrollController = searchFlightController.roundTripScrollController;
    } else if (widget.tmpJourneyType == JourneyType.oneWay) {
      scrollController = searchFlightController.oneWayScrollController;
    } else if (widget.tmpJourneyType == JourneyType.multiCity) {
      scrollController = searchFlightController.multiCityScrollController;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cs = Theme.of(context).colorScheme;
    print("widget.tmpJourneyType: ${widget.tmpJourneyType}");
    print("searchFlightController.journeyType: ${searchFlightController.journeyType}");
    return GetBuilder<SearchFlightController>(
      builder: (controller) {
        final bool preventAddFlight = controller.forms.length >= controller.maxFlightsForms;
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 0),
          child: CupertinoScrollbar(
            controller: scrollController,
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.symmetric(vertical: 22),
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.tmpJourneyType == JourneyType.multiCity)
                      Form(
                        key: widget.formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFieldTravelersAndClassType(widget: widget),
                            for (int i = 0; i < controller.forms.length; i++)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(height: 22),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Text(
                                          "${'Flight'.tr} ${i + 1}",
                                          style: TextStyle(
                                            // color: AppConsts.primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: AppConsts.lg,
                                          ),
                                        ),
                                      ),

                                      Expanded(child: Container(child: Divider(height: 1, thickness: 1))),

                                      if (i > 1)
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 0),
                                          child: TextButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              foregroundColor: Colors.pink[800],
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                            onPressed: () {
                                              controller.removeForm(i);
                                            },
                                            icon: Text(
                                              "Remove".tr,
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppConsts.lg),
                                            ),
                                            label: Icon(CupertinoIcons.xmark_circle, color: Colors.pink[800], size: 20),
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  DepartureWidget(index: i, tmpJourneyType: widget.tmpJourneyType),
                                ],
                              ),
                            Column(
                              children: [
                                SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 0),
                                  width: AppConsts.sizeContext(context).width,
                                  child: TextButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      // backgroundColor: Colors.transparent,
                                      // foregroundColor: AppConsts.primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(color: cs.outline, width: 2),
                                      ),
                                    ),
                                    onPressed: (preventAddFlight)
                                        ? null
                                        : () async {
                                            controller.addForm();
                                            await Future.delayed(const Duration(milliseconds: 250));
                                            scrollController.animateTo(
                                              scrollController.position.maxScrollExtent,
                                              duration: const Duration(milliseconds: 500),
                                              curve: Curves.fastOutSlowIn,
                                            );
                                          },
                                    label: Text(
                                      "Add Flight".tr,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppConsts.lg),
                                    ),
                                    icon: Icon(Icons.add, size: 24),
                                  ),
                                ),
                                SizedBox(height: 0),
                              ],
                            ),
                          ],
                        ),
                      ),

                    if (widget.tmpJourneyType == JourneyType.roundTrip || widget.tmpJourneyType == JourneyType.oneWay)
                      Form(
                        key: widget.formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFieldTravelersAndClassType(widget: widget),
                            SizedBox(height: 8),
                            DepartureWidget(index: 0, tmpJourneyType: widget.tmpJourneyType),
                          ],
                        ),
                      ),

                    SizedBox(height: 16),
                    Divider(),
                    ExpansionTile(
                      title: Text("Advanced options".tr),
                      children: [
                        AirlineIncludeDropDown(), 
                        SizedBox(height: 8),
                        AirlineExcludeDropDown(),
                        SizedBox(height: 8),
                      ],
                    ),
                    Divider(),

                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TextFieldTravelersAndClassType extends StatelessWidget {
  const TextFieldTravelersAndClassType({super.key, required this.widget});

  final FlightTab widget;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      child: GetBuilder<SearchFlightController>(
        builder: (controller) {
          return Row(
            children: [
              Expanded(
                child: TextFormField( 
                  controller: controller.txtClassType,
                  readOnly: true,
                  onTap: () async { 
                    await showModalBottomSheet(
                      context: context,
                      useRootNavigator: true,
                      isScrollControlled: true, // يسمح أن تكون القائمة طويلة أو قابلة للتمرير
                      // backgroundColor: Colors.white,
                      backgroundColor: cs.surface,
                      isDismissible: true,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                      builder: (BuildContext context) {
                        return ClassTypeAndTravelers();
                      },
                    );
                    controller.setTxtTravelersAndClassType();
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.class_),
                    hintText: "${'Type Cabin'.tr} ...",
                    labelText: " ${'Type Cabin'.tr} ",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text'.tr;
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextFormField( 
                  controller: controller.txtTravelers,
                  readOnly: true,
                  onTap: () async { 
                    await showModalBottomSheet(
                      context: context,
                      useRootNavigator: true,
                      isScrollControlled: true, // يسمح أن تكون القائمة طويلة أو قابلة للتمرير
                      // backgroundColor: Colors.white,
                      backgroundColor: cs.surface,
                      isDismissible: true,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                      builder: (BuildContext context) {
                        return ClassTypeAndTravelers();
                      },
                    );
                    controller.setTxtTravelersAndClassType();
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(FontAwesomeIcons.users, size: 20,),
                    hintText: "${'Travelers'.tr} ...",
                    labelText: " ${'Travelers'.tr} ",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text'.tr;
                    }
                    return null;
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DepartureWidget extends StatelessWidget {
  final int index;
  final JourneyType tmpJourneyType;
  const DepartureWidget({super.key, required this.index, required this.tmpJourneyType});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchFlightController>(
      id: 'form-$index', // تحديث جزئي لهذا العنصر فقط
      builder: (controller) {
        final form = controller.forms[index];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.transparent,
              height: 75,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  PositionedDirectional(
                    top: 0,
                    end: 0,
                    start: 0,
                    bottom: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: form.txtFrom,
                            readOnly: true,
                            onTap: () async {
                              final AirportModel? airport = await Get.to(() => const AirportSearch());
                              if (airport != null) {
                                form.fromLocation = airport;
                                form.txtFrom.text = "${airport.name[AppVars.lang]} - ${airport.code}";
                                controller.update(['form-$index']);
                              }
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.flight_takeoff_outlined),
                              hintText: "${'Enter Departing From'.tr} ...",
                              hintStyle: TextStyle(fontSize: 12),
                              labelText: " ${'Departing From'.tr} ",
                              floatingLabelBehavior: FloatingLabelBehavior.always, // 👈 المهم
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text'.tr;
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: form.txtTo,
                            readOnly: true,
                            onTap: () async {
                              final AirportModel? airport = await Get.to(() => const AirportSearch());
                              if (airport != null) {
                                form.toLocation = airport;
                                form.txtTo.text = "${airport.name[AppVars.lang]} - ${airport.code}";
                                controller.update(['form-$index']);
                              }
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.flight_land_outlined),
                              hintText: "${'Enter Departing to'.tr} ...",
                              hintStyle: TextStyle(fontSize: 12),
                              labelText: " ${'Departing to'.tr} ",
                              floatingLabelBehavior: FloatingLabelBehavior.always, // 👈 المهم
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text'.tr;
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  PositionedDirectional(
                    bottom: 0,
                    end: 0,
                    top: 0,
                    start: 0,
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        IgnorePointer(ignoring: true, child: Container(width: 75, color: Colors.transparent)),
                        // مرّر الفهرس بدلاً من كائن Controller
                        SwapWidget(
                          isSwapped: form.isSwappedIcon,
                          onTap: () => controller.swapCities(index),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            if (tmpJourneyType == JourneyType.roundTrip)
              ...[


                Row(
                  children: [

                    Expanded(
                      child: TextFormField(
                        onTap: () async {
                          // await Get.to(() => DatePickerRangeWidget(index: index), transition: Transition.downToUp);
                          await Get.to(() => DatePickerRangeWidget2(index: index, initialIndex: 0), transition: Transition.downToUp);
                          await controller.setTxtDepartureDates(index);
                        },
                        readOnly: true,
                        controller: form.txtDepartureDate,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.date_range),
                          hintText: "${'Enter Departure Date'.tr} ...",
                          hintStyle: TextStyle(fontSize: 12),
                          labelText: " ${'Departure Date'.tr} ",
                          floatingLabelBehavior: FloatingLabelBehavior.always, // 👈 المهم
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty || value.endsWith("⇄ ")) {
                            return 'Please enter some text'.tr;
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        onTap: () async {
                          // await Get.to(() => DatePickerRangeWidget(index: index), transition: Transition.downToUp);
                          await Get.to(() => DatePickerRangeWidget2(index: index, initialIndex: 1), transition: Transition.downToUp);
                          await controller.setTxtDepartureDates(index);
                        },
                        readOnly: true,
                        controller: form.txtReturnDate,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.date_range),
                          hintText: "${'Enter Return Date'.tr} ...",
                          hintStyle: TextStyle(fontSize: 12),
                          labelText: " ${'Return Date'.tr} ",
                          floatingLabelBehavior: FloatingLabelBehavior.always, // 👈 المهم
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty || value.endsWith("⇄ ")) {
                            return 'Please enter some text'.tr;
                          }
                          return null;
                        },
                      ),
                    ),


                  ],
                ),

              ],

            if (tmpJourneyType == JourneyType.oneWay || tmpJourneyType == JourneyType.multiCity)
              TextFormField(
                onTap: () async {
                  // await Get.to(() => DatePickerSingleWidget(index: index), transition: Transition.downToUp);
                  await Get.to(() => DatePickerSingleWidget2(index: index), transition: Transition.downToUp);
                  await controller.setTxtDepartureDates(index);
                },
                readOnly: true,
                controller: form.txtDepartureDate,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.date_range),
                  hintText: "${'Enter Departure Date'.tr} ...",
                  
                  labelText: " ${'Departure Date'.tr} ",
                  floatingLabelBehavior: FloatingLabelBehavior.always, // 👈 المهم
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text'.tr;
                  }
                  return null;
                },
              ),
          ],
        );
      },
    );
  }
}
