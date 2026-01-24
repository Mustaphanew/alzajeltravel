import 'package:alzajeltravel/model/profile/profile_model.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/widgets/custom_dialog.dart';
import 'package:alzajeltravel/utils/widgets/custom_snack_bar.dart';
import 'package:alzajeltravel/view/profile/profile_page.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/widgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:alzajeltravel/view/frame/home_widgets/flight_card.dart';
import 'package:get_storage/get_storage.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class Home extends StatefulWidget {
  final PersistentTabController? persistentTabController;
  const Home({super.key, this.persistentTabController});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ProfileModel? profileModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileModel = GetStorage().read('profile') != null ? ProfileModel.fromJson(GetStorage().read('profile')) : null;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final cs = Theme.of(context).colorScheme;
    // Color bgList = Colors.red;
    double listViewHorizontalHeight = 350;
    return CustomScrollView(
      slivers: [

        SliverAppBar(
          pinned: true, 
          expandedHeight: 300,
    
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) async {
                if (value == 'share') {
    
                   
                  final dialog = await CustomDialog.success(context, title: 'Dialog Title', desc: 'Dialog description here', btnOkText: 'Ok');
    
                  print("dialog: $dialog");
    
                  // CustomSnackBar.success(
                  //   context, 'Share clicked 2',
                  //   subtitle: 'If you need to show the user some information in a nice way, you can use this package.',
                  // );
                } else if (value == 'notifications') { 
                  CustomSnackBar.error(context, 'Notifications clicked', detail: 'If you need to show the user some information in a nice way, you can use this package.');
                } else if (value == 'app_rating') {
                  CustomSnackBar.warning(context, "App Rating");
                } else if (value == 'about_us') {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('About Us clicked')));
                } else if (value == 'sign_in') {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in clicked')));
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'share',
                  child: Row(children: [Icon(Icons.share_outlined), SizedBox(width: 8), Text('Share'.tr)]),
                ),
                PopupMenuItem(
                  value: 'notifications',
                  child: Row(children: [Icon(Icons.notifications_outlined), SizedBox(width: 8), Text('Notifications'.tr)]),
                ),
                PopupMenuItem(
                  value: 'app_rating',
                  child: Row(children: [Icon(Icons.star_border_outlined), SizedBox(width: 8), Text('App Rating'.tr)]),
                ),
                PopupMenuItem(
                  value: 'about_us',
                  child: Row(children: [Icon(Icons.info_outlined), SizedBox(width: 8), Text('About Us'.tr)]),
                ),
                PopupMenuDivider(height: 1),
                PopupMenuItem(
                  value: 'sign_in',
                  child: Row(children: [Icon(Icons.login_outlined), SizedBox(width: 8), Text('Sign in'.tr)]),
                ),
              ],
            ),
          ],
    
          leading: TextButton(
            style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, shape: CircleBorder()),
            onPressed: () async {
              Scaffold.of(context).openDrawer();
            },
            child: Container(
              decoration: BoxDecoration(
                // color: Colors.red,
              ),
              alignment: Alignment.center,
              child: Icon(Icons.menu, color: Colors.white, size: 28),
            ),
          ),
          leadingWidth: 50,
          titleSpacing: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,

          title: Container(
            width: size.width,
            // height: 120,
            padding: EdgeInsetsDirectional.only(start: 0, end: 0, top: 8, bottom: 8),
            decoration: BoxDecoration(color: Colors.transparent),
            child: Text(
              "Alzajel Travel".tr,
              style: TextStyle(color: Colors.white, fontSize: AppConsts.xxlg, fontWeight: FontWeight.w600),
            ),
          ),
    
          collapsedHeight: 60,


flexibleSpace: Stack(
  fit: StackFit.expand,
  children: [
    // 🔵 الخلفية المتدرجة
    Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff0f1a3f), // أغمق
            Color(0xff132057), // اللون الأساسي
            Color(0xff1b2f6f), // أفتح
          ],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
      ),
    ),

    // 🖼️ المحتوى السابق (الصور + الكاروسيل)
    FlexibleSpaceBar(
      titlePadding: const EdgeInsets.symmetric(horizontal: 52, vertical: 90),
      centerTitle: true,
      expandedTitleScale: 1.5,
      title: const Text(""),
      background: CarouselSlider.builder(
        itemCount: 5,
        itemBuilder: (context, index, realIndex) {
          return Stack(
            fit: StackFit.expand,
            children: [
              CacheImg(
                AppConsts.imageUrl + "1${index + 1}.jpg",
                boxFit: BoxFit.cover,
              ),
              Container(color: Colors.black.withValues(alpha: 0.35)),
            ],
          );
        },
        options: CarouselOptions(
          viewportFraction: 1,
          aspectRatio: 1,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 5),
        ),
      ),
    ),
  ],
),


          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 24, end: 24),
              child: SizedBox(
                height: 70,
                child: TextFormField(
                  onTap: () {
                    if (widget.persistentTabController != null) {
                      widget.persistentTabController!.jumpToTab(1);
                    }
                  },
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: "Find destinations".tr,
                    prefixIcon: Icon(Icons.travel_explore_outlined, color: cs.tertiary),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                  ),
                ),
              ),
            ),
          ),
        ),
    
        // ✅ Carousel Slider
        // SliverToBoxAdapter(
        //   child: Padding(
        //     padding: const EdgeInsets.only(top: 18, bottom: 12),
        //     child: CarouselSlider(
        //       options: CarouselOptions(
        //         height: 140,
        //         enlargeCenterPage: true,
        //         enableInfiniteScroll: true,
        //         autoPlay: true,
        //         autoPlayInterval: const Duration(seconds: 3),
        //         viewportFraction: 0.6,
        //       ),
        //       items: List.generate(6, (index) {
        //         return Builder(
        //           builder: (BuildContext context) {
        //             return Padding(
        //               padding: const EdgeInsets.symmetric(vertical: 8),
        //               child: Card(
        //                 elevation: 1,
        //                 color: Colors.white,
        //                 shape: RoundedRectangleBorder(
        //                   borderRadius: BorderRadius.circular(20),
        //                 ),
        //                 child: Center(
        //                   child: Padding(
        //                     padding: const EdgeInsets.all(8.0),
        //                     child: CacheImg(AppConsts.imageSliderUrl + "${index + 1}.png"),
        //                   ),
        //                 ),
        //               ),
        //             );
        //           },
        //         );
        //       }),
        //     ),
        //   ),
        // ),
        if(profileModel != null) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: BalanceCard(data: profileModel!, context: context),
            ),
          ),
        ],
    
        // ✅ نص رئيسي وفرعي بشكل افقي
        SliverToBoxAdapter(
          child: Column(
            children: [
              Divider(),
              Container(
                color: Colors.transparent,
                padding: const EdgeInsetsDirectional.only(start: 16, end: 16, top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Featured Flight Destinations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            "Whether you are travelling for work, business or pleasure, be rest assured we will get you there",
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                    Container(child: Icon(Icons.navigate_next, size: 32)),
                  ],
                ),
              ),
            ],
          ),
        ),
    
        SliverToBoxAdapter(
          child: Container(
            // color: bgList,
            color: Colors.transparent,
            height: listViewHorizontalHeight,
            padding: EdgeInsetsDirectional.only(top: 0, bottom: 0),
            child: ListView.separated(
              padding: const EdgeInsetsDirectional.only(start: 8, end: 8),
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return FlightCardHorizontal(
                  listViewHorizontalHeight: listViewHorizontalHeight,
                  imageUrl: "1${index + 1}.jpg",
                  from: "Berlin (BER)",
                  to: "Palma de Mallorca (PMI)",
                  price: "USD 350",
                );
              },
            ),
          ),
        ),
    
        SliverToBoxAdapter(child: Container(height: 26, color: Colors.transparent)),
    
        // ✅ نص رئيسي وفرعي بشكل عمودي
        SliverToBoxAdapter(
          child: Column(
            children: [
              Divider(),
              Container(
                // color: Colors.red,
                padding: const EdgeInsetsDirectional.only(start: 16, end: 16, top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Worldwide Destinations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            "Whether you are travelling for work, business or pleasure, be rest assured we will get you there",
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                    Container(child: Icon(Icons.navigate_next, size: 32, color: Colors.grey[700])),
                  ],
                ),
              ),
            ],
          ),
        ),
    
        // ✅  قائمة الاماكن بشكل عمودي (SliverList.separated)
        SliverList.separated(
          itemCount: 6,
    
          // scrollDirection: Axis.vertical,
          separatorBuilder: (context, index) {
            return Container(
              height: 8,
              // color: Colors.red,
            );
          },
    
          itemBuilder: (context, index) {
            return FlightCardVertical(
              from: "Berlin (BER)",
              to: "Palma de Mallorca (PMI)",
              imageUrl: "1${index + 1}.jpg",
              price: 350 + index * 20,
              // bgList: bgList,
            );
          },
        ),
    
        SliverToBoxAdapter(
          child: Container(
            height: 32,
            // color: bgList,
          ),
        ),
      ],
    );
  }
}
