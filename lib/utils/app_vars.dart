import 'package:alzajeltravel/model/profile/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:alzajeltravel/model/api.dart';
import '../controller/main_controller.dart';
import 'package:uuid/uuid.dart';

class AppVars {
  static GetStorage getStorage = GetStorage();
  static MainController mainController = Get.put(MainController());
  static Locale? appLocale;
  static String? lang;
  static ThemeMode? appThemeMode;
  static Api api = Api();

  static String? apiSessionId;

  static ProfileModel? profile;

  static Uuid uuid = Uuid();

  static FlutterSecureStorage secureStorage = FlutterSecureStorage();

  static String serverErrMsg = "";
  static String serverErrResponse = "";

}
