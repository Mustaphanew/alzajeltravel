import 'package:alzajeltravel/controller/bookings_report/trip_detail/booking_detail.dart';
import 'package:alzajeltravel/controller/bookings_report/trip_detail/flight_detail.dart';
import 'package:alzajeltravel/controller/bookings_report/trip_detail/travelers_detail.dart';
import 'package:alzajeltravel/model/bookings_report/bookings_report_model.dart';
import 'package:alzajeltravel/model/contact_model.dart';
import 'package:alzajeltravel/model/profile/profile_model.dart';
import 'package:alzajeltravel/utils/app_apis.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/enums.dart';
import 'package:alzajeltravel/utils/widgets.dart';
import 'package:alzajeltravel/view/frame/issuing/issuing_page.dart';
import 'package:alzajeltravel/view/profile/profile_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class Home2 extends StatefulWidget {
  const Home2({super.key, required this.persistentTabController});

  final PersistentTabController persistentTabController;

  @override
  State<Home2> createState() => _Home2State();
}

class _Home2State extends State<Home2> {
  ProfileModel? profileModel;
  BookingsReportData? latestBookings;
  LatestBookingsController latestBookingsController = Get.put(LatestBookingsController());

  @override
  void initState() {
    // TODO: implement initState
    services = [
      {
        'icon': Icons.flight_outlined,
        'title': 'Flight',
        'onTap': () {
          widget.persistentTabController.jumpToTab(1);
        },
      },
      {'icon': Icons.hotel_outlined, 'title': 'HOTELS', 'onTap': () {}},
      {'icon': Icons.car_rental_outlined, 'title': 'Cars', 'onTap': () {}},
      {'icon': Icons.train_outlined, 'title': 'Train', 'onTap': () {}},
      {'icon': Icons.card_giftcard_outlined, 'title': 'Packages', 'onTap': () {}},
      {'icon': Icons.card_travel_outlined, 'title': 'Visa', 'onTap': () {}},
    ];
    super.initState();
    profileModel = GetStorage().read('profile') != null ? ProfileModel.fromJson(GetStorage().read('profile')) : null;
  }

  List<Map> services = [];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Alzajel Travel'.tr),
        leading: TextButton(
          style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, shape: CircleBorder()),
          onPressed: () async {
            Scaffold.of(context).openDrawer();
          },
          child: Icon(Icons.menu, size: 24),
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: IconButton(onPressed: () {}, icon: SvgPicture.asset(AppConsts.logo, width: 38)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: BalanceCard(data: profileModel!, context: context),
            ),

            // ✅ Carousel Slider
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 12),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 80,
                  // enlargeCenterPage: true,
                  // enableInfiniteScroll: true,
                  autoPlay: true,
                  // autoPlayInterval: const Duration(seconds: 3),
                  // viewportFraction: 0.6,
                  // enlargeFactor: 0.4,
                  viewportFraction: 1,
                ),
                items: List.generate(6, (index) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
                          elevation: 0,
                          margin: EdgeInsets.zero,
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                          child: Center(
                            // child: CacheImg(AppConsts.imageSliderUrl + "${index + 1}.png"),
                            child: Image.asset(
                              "assets/tmp/1.jpg", 
                              fit: BoxFit.fill,
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),

            const SizedBox(height: 6),
            Divider(),
            const SizedBox(height: 12),
            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1, // مربع
              ),
              itemBuilder: (context, index) {
                final service = services[index];
                return ServiceCard(icon: service['icon'], title: service['title'], onTap: service['onTap']);
              },
            ),
            const SizedBox(height: 16),
            ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      "Latest operations",
                      style: TextStyle(fontSize: AppConsts.xlg, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: GetBuilder<LatestBookingsController>(
                  builder: (controller) {
                    if (controller.loading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (controller.error != null) {
                      return Center(child: Text("${controller.error}"));
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.latestBookings!.items.length,
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                      itemBuilder: (context, index) {
                        final item = controller.latestBookings!.items[index];
                        Color bgStatus = Colors.green[800]!.withOpacity(0.2);
                        if(item.flightStatus == BookingStatus.canceled || item.flightStatus == BookingStatus.expiry){
                          bgStatus = Colors.red[800]!.withOpacity(0.2); 
                        } else if(item.flightStatus == BookingStatus.confirmed){
                          bgStatus = Colors.green[800]!.withOpacity(0.2);
                        } else if(item.flightStatus == BookingStatus.preBooking){
                          bgStatus = Colors.yellow[800]!.withOpacity(0.2);
                        } else if(item.flightStatus == BookingStatus.notFound){
                          bgStatus = Colors.black.withOpacity(0.2);
                        }
                        return Container(
                          margin: const EdgeInsets.only(bottom: 0),
                          child: Column(
                            children: [
                              TextButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                                ),
                                onPressed: () async {
                                  context.loaderOverlay.show();
                                  try {
                                    final insertId = item.tripApi.split("/").last;
                                    final response = await AppVars.api.get(AppApis.tripDetail + insertId);

                                    final pnr = response['flight']['UniqueID'];
                                    final booking = BookingDetail.bookingDetail(response['booking']);
                                    final flight = FlightDetail.flightDetail(response['flight']);
                                    final travelers = TravelersDetail.travelersDetail(response['flight'], response['passengers']);

                                    final contact = ContactModel.fromApiJson({
                                      'title': "MR",
                                      'first_name': booking.customerId.split("@").first,
                                      'last_name': "_",
                                      'email': booking.customerId,
                                      'phone': booking.mobileNo,
                                      'country_code': booking.countryCode,
                                      'nationality': "ye",
                                    });

                                    Get.to(() => IssuingPage(offerDetail: flight, travelers: travelers, contact: contact, pnr: pnr, booking: booking));
                                  } catch (e) {
                                    // ممكن تعرض Dialog بدل print
                                    print("error: $e");
                                  }
                                  if (context.mounted) context.loaderOverlay.hide();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  child: Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text("${item.origin.name[AppVars.lang]}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                              Icon(Icons.navigate_next, size: 24),
                                              Text("${item.destination.name[AppVars.lang]}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                          Text("${item.createdAt}", style: TextStyle(fontSize: 14)),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: bgStatus,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(item.flightStatus.name.tr, style: TextStyle(fontSize: 14)),
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                      Text(
                                        AppFuns.priceWithCoin(item.totalAmount, item.currency),
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                ),
              ),
              Container(
                // alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                child: TextButton(
                  onPressed: () {
                    widget.persistentTabController.jumpToTab(2);
                  }, 
                  child: Text("View all".tr + " ...",
                    style: TextStyle(fontSize: AppConsts.xlg),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const ServiceCard({super.key, required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: const Color(0xff132057)),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class LatestBookingsController extends GetxController {
  BookingsReportData? latestBookings;
  bool loading = false;
  String? error;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      loading = true;
      latestBookings = null;
      error = null;

      print("Fetching latest bookings...");
      final response = await AppVars.api.post(
        AppApis.bookingsReport,
        params: {
          "api_session_id": AppVars.apiSessionId,
          "status": BookingStatus.all.apiValue,
          "date_from": null,
          "date_to": null,
          "full_details": 0,
          "limit": 30,
          "offset": 0,
        },
        asJson: true,
      );

      if ((response['status'] ?? '').toString() != 'success') {
        throw Exception((response['message'] ?? 'Request failed'.tr).toString());
      }

      final dataJson = (response['data'] ?? {}) as Map<String, dynamic>;
      print("Latest bookings data: ${dataJson['items']}"); 
      latestBookings = BookingsReportData.fromJson(dataJson);

      update();


    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
    }
  }



}
