import 'package:alzajeltravel/controller/flight/flight_detail_controller.dart';
import 'package:alzajeltravel/model/flight/flight_offer_model.dart';
import 'package:alzajeltravel/model/flight/other_prices_model.dart';
import 'package:alzajeltravel/model/flight/revalidated_flight_model.dart';
import 'package:alzajeltravel/utils/app_apis.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/view/frame/flights/flight_detail/flight_detail_page.dart';
import 'package:get/get.dart';

class OtherPricesController extends GetxController {
  final FlightDetailApiController flightDetailApiController = Get.find();
  String? errorMessage;
  List<OtherPriceOffer> offers = [];
  OtherPriceOffer? selectedOffer;

  FlightOfferModel? currentOffer; // ✅ نخزن بيانات الرحلة الأساسية لعرضها في الصفحة

  Future<bool> fetchOtherPrices({required FlightOfferModel offer}) async {
    currentOffer = offer;
    errorMessage = null;
    offers = [];
    selectedOffer = null;
    update();

    try {
      final res = await AppVars.api.post(
        AppApis.otherPricesFlight,
        params: {"id": offer.id},
      );

      if (res == null) {
        errorMessage = 'No response from server'.tr;
        update();
        return false;
      }

      if (res is! Map<String, dynamic>) {
        errorMessage = 'Invalid server response'.tr;
        update();
        return false;
      }

      final parsed = OtherPricesResponse.fromJson(res);

      final outerStatus = parsed.status?.toLowerCase();
      final innerStatus = parsed.data?.status?.toLowerCase();

      if (outerStatus != 'success' || innerStatus != 'success') {
        errorMessage = 'Failed to load other prices'.tr;
        update();
        return false;
      }

      offers = parsed.data?.offers ?? [];
      if (offers.isEmpty) {
        errorMessage = 'No other prices found'.tr;
        update();
        return false;
      }

      update();
      return true;
    } catch (err) {
      errorMessage = 'Something went wrong'.tr;
      update();
      print("Error ${AppApis.otherPricesFlight}: $err");
      return false;
    }
  }

  void select(OtherPriceOffer offer) {
    selectedOffer = offer;
    update();
  }

  Future<void> selectAndOpen(OtherPriceOffer offer) async {
    selectedOffer = offer;
    
    final res = await AppVars.api.post(
      AppApis.revalidateFlight,
      params: {
        "api_session_id": AppVars.apiSessionId,
        "id": currentOffer!.id,
        "return_id": null,
        "upsell_index": offer.index,
        "upsell_family": offer.familyName,
        "upsell_offerRef": offer.offerRef,
        "upsell_bookingClass": offer.bookingClass
      },
    );

    if (res == null) {
      errorMessage = 'No response from server'.tr;
      update();
      return;
    }

    if (res is! Map<String, dynamic>) {
      errorMessage = 'Invalid server response'.tr;
      update();
      return;
    }

    final parsed = RevalidatedFlightModel.fromResponseJson(res);
    flightDetailApiController.revalidatedDetails.value = parsed;

    // فتح صفحة تفاصيل الرحلة
    Get.to(() => FlightDetailPage(detail: flightDetailApiController.revalidatedDetails.value!, showContinueButton: true));

  }

}
