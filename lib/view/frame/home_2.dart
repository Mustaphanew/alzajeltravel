import 'package:alzajeltravel/model/profile/profile_model.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/widgets.dart';
import 'package:alzajeltravel/view/profile/profile_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class Home2 extends StatefulWidget {
  const Home2({super.key});

  @override
  State<Home2> createState() => _Home2State();
}

class _Home2State extends State<Home2> {
  ProfileModel? profileModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileModel = GetStorage().read('profile') != null ? ProfileModel.fromJson(GetStorage().read('profile')) : null;
  }

  List<Map> services = [
    {
      'icon': Icons.flight,
      'title': 'Flight',
    },
    {
      'icon': Icons.hotel,
      'title': 'HOTELS',
    },
    {
      'icon': Icons.car_rental,
      'title': 'Cars',
    },
    {
      'icon': Icons.train,
      'title': 'Train',
    },
    {
      'icon': Icons.card_giftcard,
      'title': 'Packages',
    },
    {
      'icon': Icons.card_travel,
      'title': 'Visa',
    },
  ];

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
          child: Icon(Icons.menu, size: 28),
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
                  // autoPlay: true,
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
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CacheImg(AppConsts.imageSliderUrl + "${index + 1}.png"),
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
                return ServiceCard(
                  icon: service['icon'],
                  title: service['title'],
                  onTap: () {},
                );
              },
            ),
            const SizedBox(height: 16),
            ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Latest operations",
                  style: TextStyle(
                    fontSize: AppConsts.xlg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 10,
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 8);
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 0),
                      child: Column(
                        children: [
                          Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text("DXB", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                          Icon(Icons.navigate_next, size: 24),
                                          Text("JFK", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Text("23-02-2026 16:00", style: TextStyle(fontSize: 14,)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[800]!.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text("Pre-Booking", style: TextStyle(fontSize: 14,)),
                                      ), 
                                    ],
                                  ),
                                  Spacer(),
                                  Text(
                                    "471.03 USD", 
                                    style: TextStyle(
                                      color: Colors.green[800],
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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

  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

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
              Icon(
                icon,
                size: 32,
                color: const Color(0xff132057),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

