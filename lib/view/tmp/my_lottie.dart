import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class MyLottie extends StatelessWidget {
  const MyLottie({super.key});

  @override
  Widget build(BuildContext context) {
    final gifColor = Get.context?.theme.brightness == Brightness.light ? AppConsts.primaryColor : AppConsts.secondaryColor;
    final txtColor = Get.context?.theme.brightness == Brightness.light ? Colors.black : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: Get.context?.theme.brightness == Brightness.light ? Colors.white : Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox.shrink(),
          Image.asset(AppConsts.planeAroundEarthGif, color: gifColor,),
          SizedBox.shrink(),
          Text(
            "Search for flights".tr + " ...",
            style: TextStyle(
              color: txtColor,
              fontSize: 16,
            ),
          ),
          SizedBox.shrink(),
        ],
      ),
    );
  }
}
