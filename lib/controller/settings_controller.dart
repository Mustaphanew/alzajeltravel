import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/utils/app_vars.dart';

class SettingsController extends GetxController {
  // الحالة العامة
  Locale locale = AppVars.appLocale?? Locale('en');
  Map<String, dynamic> language = {};
  // ThemeMode themeMode = Get.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  ThemeMode themeMode = AppVars.appThemeMode?? ThemeMode.system;
  String currency = 'USD';

  // تغييرات الحالة
  void setLanguage(Locale l) {
    locale = l;
    Get.updateLocale(l);
    if(l == Get.deviceLocale) {
      AppVars.getStorage.remove("lang");
    } 
    else {
      AppVars.getStorage.write("lang", l.languageCode);
    }
    update();
  }

  void setThemeMode(ThemeMode m) {
    themeMode = m;
    Get.changeThemeMode(m);
    print("theme_mode: ${m.name.toString()}");
    AppVars.getStorage.write("theme_mode", m.name.toString());
    update();
  }

  void setCurrency(String code) {
    currency = code;
    update();
  }

  // --------------------------
  // قوائم بشكل List<Map> (key,value)
  // --------------------------

  /// لغات (key = Locale, value = label)
  final List<Map<String, dynamic>> languages = [
    {'key': Locale('en'), 'value': 'English', 'image': '/settings/en.png'},
    {'key': Locale('ar'), 'value': 'Arabic', 'image': '/settings/ar.png'},
  ]..insert(0, {'key': Get.deviceLocale, 'value': 'System', 'image': '/settings/system.png'});

  /// عملات (key = String code, value = label)
  final List<Map<String, dynamic>> currencies = const [
    {'key': 'USD', 'value': 'USD – \$ (US Dollar)', 'image': '/settings/usd.png'},
    {'key': 'EUR', 'value': 'EUR – € (Euro)', 'image': '/settings/euro.png'},
    {'key': 'QAR', 'value': 'QAR – ﷼ (Qatari Riyal)', 'image': '/settings/qatar.png'},
    {'key': 'SAR', 'value': 'SAR – ﷼ (Saudi Riyal)', 'image': '/settings/saudi.png'},
    {'key': 'AED', 'value': 'AED – د.إ (UAE Dirham)', 'image': '/settings/uae.png'},
  ];

  /// الثيمات (اتركها كما هي كـ Map)
  final Map<ThemeMode, String> themes = const {
    ThemeMode.system: 'System',
    ThemeMode.light:  'Light',
    ThemeMode.dark:   'Dark',
  };

  // --------------------------
  // Getters للعرض
  // --------------------------

  String get currentLanguage =>
      _labelFromList(languages, locale, 'English');

  String get currentTheme =>
      (themes[themeMode] ?? 'System').tr;

  String get currentCurrency =>
      _labelFromList(currencies, currency, 'USD – \$ (US Dollar)');

  // --------------------------
  // Helpers
  // --------------------------

  /// يرجع label من مصفوفة [{key, value}] بناءً على key + fallback
  String _labelFromList(
    List<Map<String, dynamic>> list,
    dynamic key,
    String fallback,
  ) {
    for (final item in list) {

      if (item['key'] == key) {
        final label = (item['value'] ?? '').toString();
        return label.tr;
      }

    }
    return fallback.tr;
  }

}
