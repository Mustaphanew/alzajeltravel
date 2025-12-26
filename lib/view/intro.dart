
import 'package:alzajeltravel/view/login/login_page.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:introduction_screen/introduction_screen.dart';
import 'package:alzajeltravel/controller/check_amadeus_controller.dart';
import 'package:alzajeltravel/controller/intro_controller.dart';
import 'package:alzajeltravel/model/into_model.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/widgets.dart';

import 'package:alzajeltravel/view/frame.dart';


class Intro extends StatefulWidget {
  const Intro({super.key});

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  CheckAmadeusController checkAmadeusController = Get.put(CheckAmadeusController());
  IntroController introController = Get.put(IntroController());
  final introKey = GlobalKey<IntroductionScreenState>();

  final _formKey = GlobalKey<FormState>();
  DateTime? dob; // أو تحطه داخل Controller لو تحب
  DateTime? dob2;

  @override
  void initState() {
    super.initState();
    introController.tmpData();

    // AppVars.getStorage.write("first_run", false);
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: GetBuilder<IntroController>(
        builder: (controller) {
          if (controller.loading == true) {
            return SizedBox(height: h, width: w, child: LoadingData());
          } else {
            if (controller.dataList == null) {
              return ErrorData();
            } else if (controller.dataList == []) {
              return EmptyData();
            }
            return SizedBox(
              height: h,
              width: w,
              child: IntroductionScreen(
                key: introKey,
                pages: controller.dataList!.map((e) {
                  final IntroModel item = IntroModel.fromJson(e);
                  return myPageViewModel(
                    context: context,
                    img: item.image,
                    title: item.name,
                    body: item.body,
                    isLast: controller.dataList!.last == e,
                  );
                }).toList(),
                onDone: () {
                  Get.offAll(() => Frame());
                },
                showBackButton: false,
                showSkipButton: true,
                skip: Text(
                  "Skip".tr,
                  style: TextStyle(color: Colors.white, fontSize: AppConsts.normal, fontWeight: FontWeight.w600),
                ),
                next: const Icon(Icons.navigate_next, color: Colors.white, size: 24),
                done: const Icon(Icons.navigate_next, color: Colors.white, size: 24),
                dotsDecorator: DotsDecorator(
                  size: const Size.square(10.0),
                  activeSize: const Size(20.0, 10.0),
                  activeColor: AppConsts.primaryColor,
                  color: Color(0xffcccccc),
                  spacing: const EdgeInsets.symmetric(horizontal: 3.0),
                  activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  PageViewModel myPageViewModel({
    required BuildContext context,
    required String img,
    required String title,
    required String body,
    bool isLast = false,
  }) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    // img = "http://172.16.0.66/newhorizon/storage/images/$img";
    return PageViewModel(
      title: "",
      body: "",
      image: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(width: w, height: h, child: CacheImg(img)),
              Positioned(top: 0, left: 0, right: 0, bottom: 0, child: Container(color: Colors.black.withValues(alpha: 0.3))),
              Positioned(
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(16),
                  width: w,
                  height: (isLast ? h * 0.4 : (h * 0.3)),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(color: Colors.white, fontSize: AppConsts.xxlg, fontWeight: FontWeight.w900),
                        ),
                        SizedBox(height: h * 0.02),
                        Text(
                          body,
                          style: TextStyle(color: Colors.white, fontSize: AppConsts.normal, fontWeight: FontWeight.bold),
                        ),

                        if (isLast) SizedBox(height: h * 0.05),
                        if (isLast)
                          SizedBox(
                            width: w,
                            height: 60,
                            child: GetBuilder<CheckAmadeusController>(
                              builder: (c) {
                                return ElevatedButton(
                                  onPressed: (c.loading == true)
                                      ? null
                                      : () async {
                                          // Dio dio = Dio();
                                          // final response = await dio.post(
                                          //   'http://172.16.0.66/amadeus_api.php',
                                          //   data: {'action': 'health'},
                                          // );
                                          // print("response: ${response.data['amadeus_token_ok']}");

                                          Get.offAll(() => LoginPage());
                                          //// Get.offAll(() => Frame());

                                          // Get.snackbar(
                                          //   'Error'.tr,
                                          //   'Booking request failed, please try again.'.tr,
                                          //   snackPosition: SnackPosition.BOTTOM,
                                          // );

                                          // Get.offAll(() => CountryTmp());

                                          // await c.check().then((value) {
                                          //   if (value == true) {

                                          //   } else {
                                          //     Fluttertoast.showToast(msg: "Token is $value");
                                          //   }
                                          // });

                                          //Get.offAll(() => SettingsPage());
                                          // Get.offAll(() => Auth());

                                          //

                                          // Get.offAll(() => PassportOcrPageT());
                                          // Get.offAll(() => ScannerPage(licenseKey: 'DLS2eyJoYW5kc2hha2VDb2RlIjoiMTA0Njg3NTcxLU1UQTBOamczTlRjeExWUnlhV0ZzVUhKdmFnIiwibWFpblNlcnZlclVSTCI6Imh0dHBzOi8vbWRscy5keW5hbXNvZnRvbmxpbmUuY29tIiwib3JnYW5pemF0aW9uSUQiOiIxMDQ2ODc1NzEiLCJzdGFuZGJ5U2VydmVyVVJMIjoiaHR0cHM6Ly9zZGxzLmR5bmFtc29mdG9ubGluZS5jb20iLCJjaGVja0NvZGUiOi0xMjI1MDM2MzQ0fQ==',));
                                          // Get.offAll(() => MRZScannerPage());
                                          // Get.offAll(() => PassportForm(ageGroup: AgeGroup.adult));
                                          // Get.offAll(() => NotificationDemoPage());
                                          // Get.offAll(() => FareCardsPage(journeyType: JourneyType.oneWay));

                                          // Get.to(() => PassportsFormsPage(
                                          //   adultsCounter: 1,
                                          //   childrenCounter: 1,
                                          //   infantsInLapCounter: 0,
                                          // ));
                                        },
                                  child: Text(
                                    "Get Started".tr,
                                    style: TextStyle(
                                      fontSize: AppConsts.xlg,
                                      fontWeight: FontWeight.bold,
                                      // color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      footer: Text(""),
      decoration: PageDecoration(fullScreen: true),
    );
  }
}
