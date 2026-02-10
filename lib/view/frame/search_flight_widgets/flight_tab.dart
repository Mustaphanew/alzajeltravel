import 'package:alzajeltravel/view/frame/search_flight_widgets/airline.dart';
import 'package:alzajeltravel/view/frame/search_flight_widgets/date_picker/date_picker_range_widget2.dart';
import 'package:alzajeltravel/view/frame/search_flight_widgets/date_picker/date_picker_single_widget2.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    scrollController = ScrollController();
    // if (widget.tmpJourneyType == JourneyType.roundTrip) {
    //   scrollController = searchFlightController.roundTripScrollController;
    // } else if (widget.tmpJourneyType == JourneyType.oneWay) {
    //   scrollController = searchFlightController.oneWayScrollController;
    // } else if (widget.tmpJourneyType == JourneyType.multiCity) {
    //   scrollController = searchFlightController.multiCityScrollController;
    // }
  }

  bool isDirect = false;
  bool isIncludeBaggage = false;

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
                      dense: true,
                      title: Text(
                        "Advanced options".tr, 
                        style: TextStyle(fontFamily: AppConsts.font, fontSize: 16),
                      ),
                      tilePadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                        // side: BorderSide(color: cs.outline, width: 2),
                      ),
                      childrenPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      children: [
                        const SizedBox(height: 8),
                        AirlineIncludeDropDown(), 
                        SizedBox(height: 8),
                        AirlineExcludeDropDown(),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller.txtFlightNoOutbound,
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'))],
                                textCapitalization: TextCapitalization.characters,
                                decoration: InputDecoration(
                                  labelText: "Flight No Outbound".tr,
                                  hintText: "Enter Flight No Outbound".tr,
                                  hintStyle: TextStyle(fontSize: AppConsts.normal),
                                  labelStyle: TextStyle(fontSize: AppConsts.normal),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            if(widget.tmpJourneyType == JourneyType.roundTrip) ...[
                              SizedBox(width: 6),
                              Expanded(
                              child: TextFormField(
                                controller: controller.txtFlightNoReturn,
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'))],
                                textCapitalization: TextCapitalization.characters,
                                decoration: InputDecoration(
                                  labelText: "Flight No Return".tr,
                                  hintText: "Enter Flight No Return".tr,
                                  hintStyle: TextStyle(fontSize: AppConsts.normal),
                                  labelStyle: TextStyle(fontSize: AppConsts.normal),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            ]
                          ],
                        ),
                        SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  controller.changeNonStop();
                                },
                                child: Text(
                                  "Direct flights only".tr,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            LiteRollingPowerSwitch(
                              value: controller.nonStop,
                              onChanged: (value) {
                                controller.changeNonStop();
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  controller.changeIsIncludeBaggage();
                                },
                                child: Text(
                                  "Flights with baggage included only".tr,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            LiteRollingPowerSwitch(
                              value: controller.isIncludeBaggage,
                              onChanged: (value) {
                                controller.changeIsIncludeBaggage();
                              },
                            ),
                          ],
                        ),



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
                          // await Get.to(() => DatePickerRangeWidget2(index: index, initialIndex: 0), transition: Transition.downToUp);

                          await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                contentPadding: const EdgeInsets.all(0),
                                iconPadding: const EdgeInsets.all(0),
                                actionsPadding: const EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                ),
                                insetPadding: EdgeInsets.only(bottom: 60),
                                titlePadding: const EdgeInsets.all(0),
                                buttonPadding: const EdgeInsets.only(),
                                content: DatePickerRangeWidget2(index: index, initialIndex: 0),
                              );
                            }
                          );
                         
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
                          // await Get.to(() => DatePickerRangeWidget2(index: index, initialIndex: 1), transition: Transition.downToUp);

                          await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                contentPadding: const EdgeInsets.all(0),
                                iconPadding: const EdgeInsets.all(0),
                                actionsPadding: const EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                ),
                                insetPadding: EdgeInsets.only(bottom: 60),
                                titlePadding: const EdgeInsets.all(0),
                                buttonPadding: const EdgeInsets.only(),
                                content: DatePickerRangeWidget2(index: index, initialIndex: 1),
                              );
                            }
                          );
                          
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
                  // await Get.to(() => DatePickerSingleWidget2(index: index), transition: Transition.downToUp);

                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        contentPadding: const EdgeInsets.all(0),
                        iconPadding: const EdgeInsets.all(0),
                        actionsPadding: const EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        insetPadding: EdgeInsets.only(bottom: 60),
                        titlePadding: const EdgeInsets.all(0),
                        buttonPadding: const EdgeInsets.only(),
                        content: DatePickerSingleWidget2(index: index),
                      );
                    }
                  );

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


class LiteRollingPowerSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  /// تحكم بالحجم
  final double height;
  final double? width;

  const LiteRollingPowerSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.height = 34,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // اعتمدنا على ألوان الثيم (بدون ألوان ثابتة)
    final inactiveBg = Colors.grey[400];     // عادةً أحمر
    final activeBg = cs.primary.withOpacity(0.9);     // حسب ثيمك
    final knobBg = cs.onError;       // غالبًا أبيض (مناسب لدائرة المؤشر)
    final activeText = cs.onPrimary; // لون النص على primary
    final inactiveText = cs.onError; // لون النص على error

    final w = width ?? (height * 2.0);

    return SizedBox(
      width: w,
      child: AnimatedToggleSwitch<bool>.dual(
        current: value,
        first: false,
        second: true,

        padding: const EdgeInsets.symmetric(horizontal: 4),

        height: height, 
        spacing: 0,
        borderWidth: 0,


        animationDuration: const Duration(milliseconds: 600),
        animationCurve: Curves.easeInOut,

        style: ToggleStyle(
          borderColor: Colors.transparent,
          indicatorColor: knobBg,
          borderRadius: BorderRadius.circular(height),
          indicatorBorderRadius: BorderRadius.circular(height),
        ),

        styleBuilder: (v) => ToggleStyle(
          backgroundColor: v ? activeBg : inactiveBg,
          indicatorColor: Colors.white,
          indicatorBorderRadius: BorderRadius.circular(200),
        ),

        indicatorSize: const Size(24, 24),

        onChanged: onChanged,

        // أيقونة الباور داخل الدائرة (اللون يطابق الخلفية)
        iconBuilder: (v) => Icon(
          v? FontAwesomeIcons.solidCircleCheck : FontAwesomeIcons.solidCircleXmark,
          size: 18,
          color: v ? activeBg : inactiveBg, 
        ),

        // textDirection: TextDirection.ltr,
        // النص داخل الكبسولة
        // textBuilder: (v) => Text(
        //   (v ? 'aa'.tr : 'ii'.tr),
        //   style: TextStyle(
        //     fontFamily: AppConsts.font,
        //     fontWeight: FontWeight.w600,
        //     fontSize: 14,
        //     color: v ? activeText : inactiveText,
        //   ),
        // ),
      ),
      
    );
  }
}

