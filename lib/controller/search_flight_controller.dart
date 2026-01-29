import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:loader_overlay/loader_overlay.dart';
// import 'package:loader_overlay/loader_overlay.dart';
import 'package:alzajeltravel/controller/class_type_controller.dart';
import 'package:alzajeltravel/controller/travelers_controller.dart';
import 'package:alzajeltravel/model/class_type_model.dart';
import 'package:alzajeltravel/model/airport_model.dart';
import 'package:alzajeltravel/utils/app_apis.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/enums.dart';
import 'package:alzajeltravel/view/frame/flights/flight_offers_list.dart';
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class SimpleDatePickerController {
  DateTime? selectedDate;

  SimpleDatePickerController({this.selectedDate});
}

class SearchFlightForm {
  TextEditingController txtFrom = TextEditingController();
  AirportModel? fromLocation;

  final TextEditingController txtTo = TextEditingController();
  AirportModel? toLocation;

  final TextEditingController txtDepartureDates = TextEditingController();
  final TextEditingController txtDepartureDate = TextEditingController();
  final TextEditingController txtReturnDate = TextEditingController();

  final SimpleDatePickerController departureDatePickerController =
      SimpleDatePickerController();
  final SimpleDatePickerController returnDatePickerController =
      SimpleDatePickerController();


  bool isSwappedIcon = false;

  void dispose() {
    txtFrom.dispose();
    txtTo.dispose();
    txtDepartureDates.dispose();
    txtDepartureDate.dispose();
    // لا يوجد dispose للـ DateRangePickerController
  }
}

class SearchFlightController extends GetxController {
  ClassTypeController classTypeController = Get.put(ClassTypeController());
  TravelersController travelersController = Get.put(TravelersController());
  JourneyType journeyType = JourneyType.oneWay;
  ScrollController roundTripScrollController = ScrollController();
  ScrollController oneWayScrollController = ScrollController();
  ScrollController multiCityScrollController = ScrollController();


  TextEditingController txtClassType = TextEditingController(); 
  TextEditingController txtTravelers = TextEditingController();

  TextEditingController txtTravelersAndClassType = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final oneWayFormKey = GlobalKey<FormState>();
  final roundTripFormKey = GlobalKey<FormState>();
  final multiCityFormKey = GlobalKey<FormState>();

  final maxFlightsForms = 5;
  final forms = <SearchFlightForm>[];

  @override
  void onInit() {
    forms.addAll([SearchFlightForm(), SearchFlightForm(), SearchFlightForm()]);
    super.onInit();
  }

  void addForm() {
    if (forms.length < maxFlightsForms) {
      forms.add(SearchFlightForm());
      update();
    }
  }

  void removeForm(int index) {
    forms.removeAt(index);
    update();
  }

  void swapCities(int index) {
    final form = forms[index];

    // قلّب الأيقونة
    form.isSwappedIcon = !form.isSwappedIcon;

    // سواب للمدن + تحديث النصوص
    final tmp = form.fromLocation;
    form.fromLocation = form.toLocation;
    form.toLocation = tmp;

    form.txtFrom.text = form.fromLocation == null
        ? ''
        : "${form.fromLocation!.name} - ${form.fromLocation!.code}";
    form.txtTo.text = form.toLocation == null
        ? ''
        : "${form.toLocation!.name} - ${form.toLocation!.code}";

    update(['form-$index']); // تحديث جزئي لهذا العنصر فقط
  }

  Future<void> setTxtDepartureDates(int index) async {
    final form = forms[index];

    String formattedLeavingDate = "";
    String formattedGoingDate = "";

    if (form.departureDatePickerController.selectedDate != null) {
      final leavingDate = form.departureDatePickerController.selectedDate!;
      formattedLeavingDate = Jiffy.parseFromDateTime(
        leavingDate,
      ).format(pattern: 'EEEE, d - MMMM - y');
    }

    if (form.returnDatePickerController.selectedDate != null &&
        form.departureDatePickerController.selectedDate != null) {
      if (form.returnDatePickerController.selectedDate!.compareTo(
            form.departureDatePickerController.selectedDate!,
          ) >=
          0) {
        final goingDate = form.returnDatePickerController.selectedDate!;
        formattedGoingDate = Jiffy.parseFromDateTime(
          goingDate,
        ).format(pattern: 'EEEE, d - MMMM - y');
      } else {
        form.returnDatePickerController.selectedDate = null;
      }
    }

    form.txtDepartureDates.text = AppFuns.replaceArabicNumbers(
      "$formattedLeavingDate ⇄ $formattedGoingDate",
    );
    form.txtDepartureDate.text = AppFuns.replaceArabicNumbers(
      formattedLeavingDate,
    );
    form.txtReturnDate.text = AppFuns.replaceArabicNumbers(
      formattedGoingDate,
    );

    update(['form-$index']); // حدّث فقط ويدجت هذا السيجمنت
  }

  @override
  void onClose() {
    for (final form in forms) {
      form.dispose();
    }
    txtTravelersAndClassType.dispose();
    super.onClose();
  }

  changeJourneyType(int tabIndex) {
    if (tabIndex == 0) {
      journeyType = JourneyType.oneWay;
    } else if (tabIndex == 1) {
      journeyType = JourneyType.roundTrip;
    } else if (tabIndex == 2) {
      journeyType = JourneyType.multiCity;
    }
    update();
  }

  setTxtTravelersAndClassType() async {
    ClassTypeModel? classType;
    if (classTypeController.selectedClassType == null) {
      classType = await classTypeController.setDefaultClassType();
    } else {
      classType = classTypeController.selectedClassType;
    }
    int adults = travelersController.adultsCounter;
    int children = travelersController.childrenCounter;
    int infantsInSeat = travelersController.infantsInSeatCounter;
    int infantsInLap = travelersController.infantsInLapCounter;
    int travelers = adults + children + infantsInSeat + infantsInLap;
    if (classType != null) {
      txtClassType.text = classType.name[AppVars.lang];
      txtTravelers.text = "$travelers ${(travelers > 1)? 'Travelers'.tr: 'Traveler'.tr}";
      txtTravelersAndClassType.text = "$travelers ${(travelers > 1)? 'Travelers'.tr: 'Traveler'.tr}, ${classType.name[AppVars.lang]}";
    }
    update(); 
  }

  bool isRequesting = false;
  Future requestServer(BuildContext context) async {
    AppVars.apiSessionId = null;
    context.loaderOverlay.show();
    isRequesting = true;
    update();
    List? data;
    
    final DateTime? departureDate = forms[0].departureDatePickerController.selectedDate;
    final String formattedDepartureDate = DateFormat('yyyy-MM-dd', 'en').format(departureDate!);
    final DateTime? returnDate = forms[0].returnDatePickerController.selectedDate;
    final String? formattedReturnDate = returnDate == null ? null : DateFormat('yyyy-MM-dd', 'en').format(returnDate);
    final response = await AppVars.api.post(
      AppApis.searchFlight,
      params: {
        "from": forms[0].fromLocation!.code,
        "to": forms[0].toLocation!.code,
        "departure_date": formattedDepartureDate,
        "return_date": formattedReturnDate,
        'journey_type': journeyType.apiValue,
        "adt": travelersController.adultsCounter,
        "chd": travelersController.childrenCounter,
        "inf": travelersController.infantsInLapCounter,
        "cabin": classTypeController.selectedClassType!.code,
        "nonstop": "0",
      }
    );
    if(response != null) {
      AppVars.apiSessionId = response['api_session_id'];
      data = response['outbound'];
      Get.to(() => FlightOffersList(flightOffers: data!));
    } else {
      Get.snackbar("Error", "Failed to search flights", snackPosition: SnackPosition.BOTTOM);
    }
    print("data ${AppApis.searchFlight}: $data");
    print("apiSessionId: ${AppVars.apiSessionId}");
    
    isRequesting = false;
    update();
    if (context.mounted) context.loaderOverlay.hide();
  }
  
}
