import 'package:alzajeltravel/model/profile/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:alzajeltravel/model/api.dart';
import 'package:alzajeltravel/model/db/db_helper.dart';

import '../controller/main_controller.dart';

class AppVars {
  static GetStorage getStorage = GetStorage();
  static MainController mainController = Get.put(MainController());
  static Locale? appLocale;
  static String? lang;
  static ThemeMode? appThemeMode;
  static Api api = Api();
  static DbHelper dbHelper = DbHelper();

  static String? apiSessionId;

  static ProfileModel? profile;

}
