import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/utils/routes.dart';
import 'package:alzajeltravel/utils/app_vars.dart';

class RootDecider extends StatelessWidget {
  const RootDecider({super.key});

  @override
  Widget build(BuildContext context) {
    final firstRun = AppVars.getStorage.read("first_run") == null;

    // نقل بعد أول فريم لتجنب مشاكل build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (firstRun) {
        Get.offAllNamed(Routes.intro.path);
      } else {
        Get.offAllNamed(Routes.login.path);
      }
    });

    return const SizedBox.shrink();
  }
}
