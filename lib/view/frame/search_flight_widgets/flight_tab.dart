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

Future<T?> _showDatePickerDialog<T>({
  required BuildContext context,
  required Widget child,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showDialog<T>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (context) {
      return Dialog(
        backgroundColor:
            isDark ? const Color(0xFF0B1430) : Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        clipBehavior: Clip.antiAlias,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: AppConsts.secondaryColor.withValues(alpha: 0.45),
            width: 1,
          ),
        ),
        child: child,
      );
    },
  );
}

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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return GetBuilder<SearchFlightController>(
      builder: (controller) {
        final bool preventAddFlight = controller.forms.length >= controller.maxFlightsForms;
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 0),
          child: CupertinoScrollbar(
            controller: scrollController,
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.symmetric(vertical: 20),
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
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppConsts.secondaryColor,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      side: BorderSide(
                                        color: AppConsts.secondaryColor
                                            .withValues(alpha: 0.8),
                                        width: 1.4,
                                      ),
                                    ),
                                    onPressed: (preventAddFlight)
                                        ? null
                                        : () async {
                                            controller.addForm();
                                            await Future.delayed(
                                                const Duration(
                                                    milliseconds: 250));
                                            scrollController.animateTo(
                                              scrollController
                                                  .position.maxScrollExtent,
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              curve: Curves.fastOutSlowIn,
                                            );
                                          },
                                    icon: const Icon(
                                      Icons.add_circle_outline_rounded,
                                      size: 20,
                                      color: AppConsts.secondaryColor,
                                    ),
                                    label: Text(
                                      "Add Flight".tr,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: AppConsts.normal,
                                        color: AppConsts.secondaryColor,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                ),
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
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppConsts.secondaryColor.withValues(alpha: 0),
                            AppConsts.secondaryColor.withValues(alpha: 0.45),
                            AppConsts.secondaryColor.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Theme(
                      data: theme.copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        dense: true,
                        iconColor: AppConsts.secondaryColor,
                        collapsedIconColor: AppConsts.secondaryColor,
                        title: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 18,
                              decoration: BoxDecoration(
                                color: AppConsts.secondaryColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Advanced options".tr,
                                style: TextStyle(
                                  fontFamily: AppConsts.font,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        tilePadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        shape: const RoundedRectangleBorder(),
                        collapsedShape: const RoundedRectangleBorder(),
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
                                  prefixIcon: const Icon(
                                    Icons.confirmation_number_outlined,
                                    color: AppConsts.secondaryColor,
                                    size: 20,
                                  ),
                                  labelText: "Flight No Outbound".tr,
                                  hintText: "Enter Flight No Outbound".tr,
                                  hintStyle: const TextStyle(fontSize: AppConsts.normal),
                                  labelStyle: const TextStyle(fontSize: AppConsts.normal),
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
                                  prefixIcon: const Icon(
                                    Icons.confirmation_number_outlined,
                                    color: AppConsts.secondaryColor,
                                    size: 20,
                                  ),
                                  labelText: "Flight No Return".tr,
                                  hintText: "Enter Flight No Return".tr,
                                  hintStyle: const TextStyle(fontSize: AppConsts.normal),
                                  labelStyle: const TextStyle(fontSize: AppConsts.normal),
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

                        _AdvancedToggleRow(
                          icon: Icons.flight_takeoff_rounded,
                          label: "Direct flights only".tr,
                          value: controller.nonStop,
                          onTap: controller.changeNonStop,
                        ),

                        const SizedBox(height: 10),

                        _AdvancedToggleRow(
                          icon: Icons.luggage_rounded,
                          label: "Flights with baggage included only".tr,
                          value: controller.isIncludeBaggage,
                          onTap: controller.changeIsIncludeBaggage,
                        ),



                        SizedBox(height: 8),
                      ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppConsts.secondaryColor.withValues(alpha: 0),
                            AppConsts.secondaryColor.withValues(alpha: 0.45),
                            AppConsts.secondaryColor.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),

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
                        return ClassTypeAndTravelers(
                          isCanbin: true,
                        );
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
                        return ClassTypeAndTravelers(
                          isCanbin: false,
                        );
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

                          await _showDatePickerDialog(
                            context: context,
                            child: DatePickerRangeWidget2(
                                index: index, initialIndex: 0),
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

                          await _showDatePickerDialog(
                            context: context,
                            child: DatePickerRangeWidget2(
                                index: index, initialIndex: 1),
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

                  await _showDatePickerDialog(
                    context: context,
                    child: DatePickerSingleWidget2(index: index),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Active = ذهبي (هوية التطبيق) / Inactive = كحلي ناعم متناسق
    final Color activeBg = AppConsts.secondaryColor;
    final Color inactiveBg = isDark
        ? AppConsts.primaryColor.withValues(alpha: 0.45)
        : AppConsts.primaryColor.withValues(alpha: 0.22);

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
          indicatorColor: Colors.white,
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

        iconBuilder: (v) => Icon(
          v
              ? FontAwesomeIcons.solidCircleCheck
              : FontAwesomeIcons.solidCircleXmark,
          size: 18,
          color: v ? activeBg : inactiveBg,
        ),
      ),
    );
  }
}

class _AdvancedToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final VoidCallback onTap;

  const _AdvancedToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    final Color bg = value
        ? AppConsts.secondaryColor.withValues(alpha: isDark ? 0.12 : 0.14)
        : (isDark
            ? Colors.white.withValues(alpha: 0.04)
            : AppConsts.primaryColor.withValues(alpha: 0.04));
    final Color borderColor = value
        ? AppConsts.secondaryColor.withValues(alpha: 0.55)
        : AppConsts.primaryColor.withValues(alpha: isDark ? 0.25 : 0.18);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppConsts.secondaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppConsts.secondaryColor.withValues(alpha: 0.55),
                  width: 1,
                ),
              ),
              child: Icon(icon,
                  size: 18, color: AppConsts.secondaryColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            LiteRollingPowerSwitch(
              value: value,
              onChanged: (_) => onTap(),
            ),
          ],
        ),
      ),
    );
  }
}

