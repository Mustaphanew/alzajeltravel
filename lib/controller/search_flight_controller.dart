// search_flight_controller.dart
import 'package:alzajeltravel/model/flight/flight_search_params.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:alzajeltravel/controller/class_type_controller.dart';
import 'package:alzajeltravel/controller/travelers_controller.dart';
import 'package:alzajeltravel/model/class_type_model.dart';
import 'package:alzajeltravel/model/airport_model.dart';
import 'package:alzajeltravel/utils/app_apis.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/enums.dart';
import 'package:alzajeltravel/view/frame/flights/flight_offers_list.dart';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class SimpleDatePickerController {
  DateTime? selectedDate;
  SimpleDatePickerController({this.selectedDate});
}

class SearchFlightForm {
  final TextEditingController txtFrom = TextEditingController();
  AirportModel? fromLocation;

  final TextEditingController txtTo = TextEditingController();
  AirportModel? toLocation;

  final TextEditingController txtDepartureDates = TextEditingController();
  final TextEditingController txtDepartureDate = TextEditingController();
  final TextEditingController txtReturnDate = TextEditingController();

  final SimpleDatePickerController departureDatePickerController = SimpleDatePickerController();
  final SimpleDatePickerController returnDatePickerController = SimpleDatePickerController();

  bool isSwappedIcon = false;

  void dispose() {
    txtFrom.dispose();
    txtTo.dispose();
    txtDepartureDates.dispose();
    txtDepartureDate.dispose();
    txtReturnDate.dispose();
  }
}

class SearchFlightController extends GetxController {
  final ClassTypeController classTypeController = Get.put(ClassTypeController());
  final TravelersController travelersController = Get.put(TravelersController());

  JourneyType journeyType = JourneyType.oneWay;

  final ScrollController roundTripScrollController = ScrollController();
  final ScrollController oneWayScrollController = ScrollController();
  final ScrollController multiCityScrollController = ScrollController();

  final TextEditingController txtClassType = TextEditingController();
  final TextEditingController txtTravelers = TextEditingController();
  final TextEditingController txtTravelersAndClassType = TextEditingController();

  final int maxFlightsForms = 5;
  final List<SearchFlightForm> forms = <SearchFlightForm>[];

  bool nonStop = false;
  void changeNonStop() {
    nonStop = !nonStop;
    safeUpdate();
  }

  bool isIncludeBaggage = false;
  void changeIsIncludeBaggage() {
    isIncludeBaggage = !isIncludeBaggage;
    safeUpdate();
  }

  TextEditingController txtFlightNoOutbound = TextEditingController();
  void changeFlightNoOutbound(String value) {
    txtFlightNoOutbound.text = value;
    safeUpdate();
  }

  TextEditingController txtFlightNoReturn = TextEditingController();
  void changeFlightNoReturn(String value) {
    txtFlightNoReturn.text = value;
    safeUpdate();
  }

  @override
  void onInit() {
    super.onInit();
    // دائمًا جهّز الأقل Form واحد
    if (forms.isEmpty) {
      forms.add(SearchFlightForm());
    }
    // لو multiCity تحتاج أكثر، خليها عندك كما تحب
  }

void safeUpdate([List<Object>? ids]) {
  final phase = SchedulerBinding.instance.schedulerPhase;

  // أثناء build/layout/paint
  final inBuildPhase = phase == SchedulerPhase.persistentCallbacks ||
      phase == SchedulerPhase.midFrameMicrotasks;

  if (inBuildPhase) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isClosed) update(ids);
    });
  } else {
    update(ids);
  }
}

  void ensureMultiCityForms({int minCount = 3}) {
    while (forms.length < minCount) {
      forms.add(SearchFlightForm());
    }
    safeUpdate();
  }

  void addForm() {
    if (forms.length < maxFlightsForms) {
      forms.add(SearchFlightForm());
      safeUpdate();
    }
  }

  void removeForm(int index) {
    if (index < 0 || index >= forms.length) return;
    forms[index].dispose();
    forms.removeAt(index);
    safeUpdate();
  }

  void changeJourneyType(int tabIndex) {
    if (tabIndex == 0) {
      journeyType = JourneyType.oneWay;
    } else if (tabIndex == 1) {
      journeyType = JourneyType.roundTrip;
    } else if (tabIndex == 2) {
      journeyType = JourneyType.multiCity;
      ensureMultiCityForms(minCount: 3);
    }
    safeUpdate();
  }

  void swapCities(int index) {
    if (index < 0 || index >= forms.length) return;
    final form = forms[index];

    form.isSwappedIcon = !form.isSwappedIcon;

    final tmp = form.fromLocation;
    form.fromLocation = form.toLocation;
    form.toLocation = tmp;

    form.txtFrom.text = form.fromLocation == null
        ? ''
        : "${form.fromLocation!.name[AppVars.lang]} - ${form.fromLocation!.code}";
    form.txtTo.text = form.toLocation == null
        ? ''
        : "${form.toLocation!.name[AppVars.lang]} - ${form.toLocation!.code}";

    safeUpdate(['form-$index']);
  }

  Future<void> setTxtDepartureDates(int index) async {
    if (index < 0 || index >= forms.length) return;
    final form = forms[index];

    String formattedLeavingDate = "";
    String formattedGoingDate = "";

    final leaving = form.departureDatePickerController.selectedDate;
    final going = form.returnDatePickerController.selectedDate;

    if (leaving != null) {
      formattedLeavingDate = Jiffy.parseFromDateTime(leaving).format(pattern: 'EEEE, d - MMMM - y');
    }

    if (going != null && leaving != null) {
      if (going.compareTo(leaving) >= 0) {
        formattedGoingDate = Jiffy.parseFromDateTime(going).format(pattern: 'EEEE, d - MMMM - y');
      } else {
        form.returnDatePickerController.selectedDate = null;
      }
    }

    form.txtDepartureDates.text = AppFuns.replaceArabicNumbers("$formattedLeavingDate ⇄ $formattedGoingDate");
    form.txtDepartureDate.text = AppFuns.replaceArabicNumbers(formattedLeavingDate);
    form.txtReturnDate.text = AppFuns.replaceArabicNumbers(formattedGoingDate);

    safeUpdate(['form-$index']);
  }

  Future<void> setTxtTravelersAndClassType() async {
    ClassTypeModel? classType = classTypeController.selectedClassType;
    classType ??= await classTypeController.setDefaultClassType();

    final adults = travelersController.adultsCounter;
    final children = travelersController.childrenCounter;
    final infantsInSeat = travelersController.infantsInSeatCounter;
    final infantsInLap = travelersController.infantsInLapCounter;

    final travelers = adults + children + infantsInSeat + infantsInLap;

    if (classType != null) {
      txtClassType.text = classType.name[AppVars.lang];
      txtTravelers.text = "$travelers ${(travelers > 1) ? 'Travelers'.tr : 'Traveler'.tr}";
      txtTravelersAndClassType.text =
          "$travelers ${(travelers > 1) ? 'Travelers'.tr : 'Traveler'.tr}, ${classType.name[AppVars.lang]}";
    }
    safeUpdate();
  }

  bool isRequesting = false;



Future<FlightSearchResult?> requestServer(BuildContext context) async {
  if (forms.isEmpty) {
    Get.snackbar("Error".tr, "No form data".tr, snackPosition: SnackPosition.BOTTOM);
    return null;
  }

  final f0 = forms[0];

  if (f0.fromLocation == null || f0.toLocation == null) {
    Get.snackbar("Error".tr, "Please select airports".tr, snackPosition: SnackPosition.BOTTOM);
    return null;
  }

  final departureDate = f0.departureDatePickerController.selectedDate;
  if (departureDate == null) {
    Get.snackbar("Error".tr, "Please select departure date".tr, snackPosition: SnackPosition.BOTTOM);
    return null;
  }

  if (journeyType == JourneyType.roundTrip &&
      f0.returnDatePickerController.selectedDate == null) {
    Get.snackbar("Error".tr, "Please select return date".tr, snackPosition: SnackPosition.BOTTOM);
    return null;
  }

  // Cabin
  if (classTypeController.selectedClassType?.code == null) {
    await setTxtTravelersAndClassType();
  }

  AppVars.apiSessionId = null;

  if(context.mounted) context.loaderOverlay.show(progress: "Search for flights".tr);
  isRequesting = true;
  safeUpdate();

  try {
    final formattedDepartureDate = DateFormat('yyyy-MM-dd', 'en').format(departureDate);

    final returnDate = f0.returnDatePickerController.selectedDate;
    final formattedReturnDate = returnDate == null
        ? null
        : DateFormat('yyyy-MM-dd', 'en').format(returnDate);

    Map<String, dynamic> params = {
      "from": f0.fromLocation!.code,
      "to": f0.toLocation!.code,
      "departure_date": formattedDepartureDate,
      "return_date": formattedReturnDate,
      "journey_type": journeyType.apiValue,
      "adt": travelersController.adultsCounter,
      "chd": travelersController.childrenCounter,
      "inf": travelersController.infantsInLapCounter,
      "cabin": classTypeController.selectedClassType?.code ?? "",
      "nonstop": nonStop ? "1" : "0",
    };

    final response = await AppVars.api.post(
      AppApis.searchFlight,
      params: params,
    );

    if (response == null) {
      Get.snackbar("Error".tr, "Failed to search flights".tr, snackPosition: SnackPosition.BOTTOM);
      return null;
    }

    AppVars.apiSessionId = response['api_session_id'];
    final outbound = (response['outbound'] as List?) ?? const [];

    return FlightSearchResult(
      apiSessionId: AppVars.apiSessionId,
      outbound: outbound,
      params: FlightSearchParams.fromJson(params),
    );
  } finally {
    isRequesting = false;
    safeUpdate();
    if (context.mounted) context.loaderOverlay.hide();
  }
}




  @override
  void onClose() {
    for (final f in forms) {
      f.dispose();
    }
    txtClassType.dispose();
    txtTravelers.dispose();
    txtTravelersAndClassType.dispose();

    roundTripScrollController.dispose();
    oneWayScrollController.dispose();
    multiCityScrollController.dispose();

    super.onClose();
  }

}

class FlightSearchResult {
  final String? apiSessionId;
  final List<dynamic> outbound;
  final FlightSearchParams params;

  const FlightSearchResult({
    required this.outbound,
    required this.apiSessionId,
    required this.params,
  });
}
