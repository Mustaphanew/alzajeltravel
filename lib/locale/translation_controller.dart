import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class TranslationController extends GetxController {
  GetStorage getStorage = GetStorage();

  changeLang(String codeLang) async {
    getStorage.write("lang", codeLang);
    Locale locale = Locale(codeLang);
    await Get.updateLocale(locale);
  }

}
